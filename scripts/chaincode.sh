#!/usr/bin/env bash

set -e

VERSION=1.0
CURRENT_PATH=$(pwd)
FABRIC_SAMPLE_PATH=${CURRENT_PATH}/fabric-samples
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# The sed commend with system judging
# Examples:
# sed -i 's/a/b/g' bob.txt => x_replace 's/a/b/g' bob.txt
function x_replace() {
  system=$(uname)

  if [ "${system}" = "Linux" ]; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

function print_blue() {
  printf "${BLUE}%s${NC}\n" "$1"
}

function print_red() {
  printf "${RED}%s${NC}\n" "$1"
}

function printHelp() {
  print_blue "Usage:  "
  echo "  chaincode.sh <mode>"
  echo "    <mode> - one of 'up', 'down', 'restart'"
  echo "      - 'install' - install chaincode"
  echo "      - 'upgrade' - upgrade chaincode"
  echo "  chaincode.sh -h (print this message)"
}

function prepare() {
  if ! type fabric-cli >/dev/null 2>&1; then
    print_blue "===> Install fabric-cli"
    go get github.com/securekey/fabric-examples/fabric-cli/cmd/fabric-cli
  fi

  if [ ! -d contracts ]; then
    print_blue "===> Download chaincode"
    wget https://github.com/4ever9/kooka/raw/master/scripts/contracts.zip
    unzip -q contracts.zip
    rm contracts.zip
  fi

  if [ ! -f config.yaml ]; then
    print_blue "===> Download config.yaml"
    wget https://raw.githubusercontent.com/4ever9/kooka/master/scripts/config.yaml
  fi

  if [ ! -d crypto-config ]; then
    print_red "===> Please provide the 'crypto-config'"
    exit 1
  fi
}

function installChaincode() {
  prepare

  FABRIC_IP=localhost
  if [ $1 ]; then
    FABRIC_IP=$1
  fi

  print_blue "===> Install chaincode at $FABRIC_IP"

  cd "${CURRENT_PATH}"
  export CONFIG_PATH=${CURRENT_PATH}
  x_replace "s/localhost/${FABRIC_IP}/g" "${CURRENT_PATH}"/config.yaml

  print_blue "===> 1. Deploying broker, transfer and data_swapper chaincode"
  fabric-cli chaincode install --gopath ./contracts --ccp broker --ccid broker --config ./config.yaml --orgid org2 --user Admin --cid mychannel
  fabric-cli chaincode instantiate --ccp broker --ccid broker --config ./config.yaml --orgid org2 --user Admin --cid mychannel
  fabric-cli chaincode install --gopath ./contracts --ccp transfer --ccid transfer --config ./config.yaml --orgid org2 --user Admin --cid mychannel
  fabric-cli chaincode instantiate --ccp transfer --ccid transfer --config ./config.yaml --orgid org2 --user Admin --cid mychannel
  fabric-cli chaincode install --gopath ./contracts --ccp data_swapper --ccid data_swapper --config ./config.yaml --orgid org2 --user Admin --cid mychannel
  fabric-cli chaincode instantiate --ccp data_swapper --ccid data_swapper --config ./config.yaml --orgid org2 --user Admin --cid mychannel

  print_blue "===> 2. Set Alice 10000 amout in transfer chaincode"
  fabric-cli chaincode invoke --cid mychannel --ccid=transfer \
    --args='{"Func":"setBalance","Args":["Alice", "10000"]}' \
    --user Admin --orgid org2 --payload --config ./config.yaml

  print_blue "===> 3. Set (key: path, value: ${CURRENT_PATH}) in data_swapper chaincode"
  fabric-cli chaincode invoke --cid mychannel --ccid=data_swapper \
    --args='{"Func":"set","Args":["path", "'"${CURRENT_PATH}"'"]}' \
    --user Admin --orgid org2 --payload --config ./config.yaml

  print_blue "===> 4. Register transfer and data_swapper chaincode to broker chaincode"
  fabric-cli chaincode invoke --cid mychannel --ccid=transfer \
    --args='{"Func":"register"}' --user Admin --orgid org2 --payload --config ./config.yaml
  fabric-cli chaincode invoke --cid mychannel --ccid=data_swapper \
    --args='{"Func":"register"}' --user Admin --orgid org2 --payload --config ./config.yaml

  print_blue "===> 6. Audit transfer and data_swapper chaincode"
  fabric-cli chaincode invoke --cid mychannel --ccid=broker \
    --args='{"Func":"audit", "Args":["mychannel", "transfer", "1"]}' \
    --user Admin --orgid org2 --payload --config ./config.yaml
  fabric-cli chaincode invoke --cid mychannel --ccid=broker \
    --args='{"Func":"audit", "Args":["mychannel", "data_swapper", "1"]}' \
    --user Admin --orgid org2 --payload --config ./config.yaml

}

function upgradeChaincode() {
  prepare

  FABRIC_IP=localhost
  if [ $1 ]; then
    FABRIC_IP=$1
  fi

  CHAINCODE_VERSION=v1
  if [ $1 ]; then
    FABRIC_IP=$1
  fi

  print_blue "Upgrade chaincode at $FABRIC_IP"
  print_blue "Upgrade to version: $CHAINCODE_VERSION"

  cd "${CURRENT_PATH}"
  export CONFIG_PATH=${CURRENT_PATH}
  x_replace "s/localhost/${FABRIC_IP}/g" "${CURRENT_PATH}"/config.yaml

  print_blue "===> 1. Deploying broker, transfer and data_swapper chaincode"
  fabric-cli chaincode install --gopath ./contracts --ccp broker --ccid broker \
    --v $CHAINCODE_VERSION \
    --config ./config.yaml --orgid org2 --user Admin --cid mychannel
  fabric-cli chaincode upgrade --ccp broker --ccid broker \
    --v $CHAINCODE_VERSION \
    --config ./config.yaml --orgid org2 --user Admin --cid mychannel

  fabric-cli chaincode install --gopath ./contracts --ccp transfer --ccid transfer \
    --v $CHAINCODE_VERSION \
    --config ./config.yaml --orgid org2 --user Admin --cid mychannel
  fabric-cli chaincode upgrade --ccp transfer --ccid transfer \
    --v $CHAINCODE_VERSION \
    --config ./config.yaml --orgid org2 --user Admin --cid mychannel

  fabric-cli chaincode install --gopath ./contracts --ccp data_swapper --ccid data_swapper \
    --v $CHAINCODE_VERSION \
    --config ./config.yaml --orgid org2 --user Admin --cid mychannel
  fabric-cli chaincode upgrade --ccp data_swapper --ccid data_swapper \
    --v $CHAINCODE_VERSION \
    --config ./config.yaml --orgid org2 --user Admin --cid mychannel

  print_blue "===> 2. Set Alice 10000 amout in transfer chaincode"
  fabric-cli chaincode invoke --cid mychannel --ccid=transfer \
    --args='{"Func":"setBalance","Args":["Alice", "10000"]}' \
    --user Admin --orgid org2 --payload --config ./config.yaml

  print_blue "===> 3. Set (key: path, value: ${CURRENT_PATH}) in data_swapper chaincode"
  fabric-cli chaincode invoke --cid mychannel --ccid=data_swapper \
    --args='{"Func":"set","Args":["path", "'"${CURRENT_PATH}"'"]}' \
    --user Admin --orgid org2 --payload --config ./config.yaml

  print_blue "===> 4. Register transfer and data_swapper chaincode to broker chaincode"
  fabric-cli chaincode invoke --cid mychannel --ccid=transfer \
    --args='{"Func":"register"}' --user Admin --orgid org2 --payload --config ./config.yaml
  fabric-cli chaincode invoke --cid mychannel --ccid=data_swapper \
    --args='{"Func":"register"}' --user Admin --orgid org2 --payload --config ./config.yaml

  print_blue "===> 6. Audit transfer and data_swapper chaincode"
  fabric-cli chaincode invoke --cid mychannel --ccid=broker \
    --args='{"Func":"audit", "Args":["mychannel", "transfer", "1"]}' \
    --user Admin --orgid org2 --payload --config ./config.yaml
  fabric-cli chaincode invoke --cid mychannel --ccid=broker \
    --args='{"Func":"audit", "Args":["mychannel", "data_swapper", "1"]}' \
    --user Admin --orgid org2 --payload --config ./config.yaml
}

MODE=$1

if [ "$MODE" == "install" ]; then
  shift
  installChaincode $1
elif [ "$MODE" == "upgrade" ]; then
  shift
  upgradeChaincode $1 $2
else
  printHelp
  exit 1
fi
