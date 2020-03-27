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

function prepare() {
  print_blue "===> Script version: $VERSION"
  if [ ! -d "${FABRIC_SAMPLE_PATH}"/bin ]; then
    curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/master/scripts/bootstrap.sh | bash -s -- 1.4.3 1.4.3 0.4.18
  fi

  if ! type fabric-cli >/dev/null 2>&1; then
    go get github.com/securekey/fabric-examples/fabric-cli/cmd/fabric-cli
  fi

  rm -rf contracts contracts.zip
  wget https://github.com/4ever9/kooka/raw/master/scripts/contracts.zip
  unzip -q contracts.zip
  rm contracts.zip

  rm -rf config.yaml
  wget https://raw.githubusercontent.com/4ever9/kooka/master/scripts/config.yaml
}

function start() {
  cd ${FABRIC_SAMPLE_PATH}/first-network

  ./byfn.sh generate
  ./byfn.sh down
  ./byfn.sh up -n

  cp -rf ${FABRIC_SAMPLE_PATH}/first-network/crypto-config "${CURRENT_PATH}"

  cd "${CURRENT_PATH}"
  export CONFIG_PATH=${CURRENT_PATH}

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

prepare
start
