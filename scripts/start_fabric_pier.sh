#!/usr/bin/env bash

set -e

CURRENT_PATH=$(pwd)
PIER_ROOT=${CURRENT_PATH}/.pier
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

BITXHUB_ADDR="localhost:60011"
FABRIC_IP=localhost
PPROF_PORT=44555

if [ $1 ]; then
  BITXHUB_ADDR=$1
fi

if [ $2 ]; then
  FABRIC_IP=$2
fi

if [ $3 ]; then
  PPROF_PORT=$3
fi

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
  rm -rf "${CURRENT_PATH}"/.pier
}

function compile_pier() {
  rm -rf "${CURRENT_PATH}"/pier
  git clone git@git.hyperchain.cn:dmlab/pier.git
  cd pier
  make install
}

function compile_fabric_plugin() {
  cd "${CURRENT_PATH}"
  rm -rf "${CURRENT_PATH}"/pier-client-fabric
  git clone git@git.hyperchain.cn:dmlab/pier-client-fabric.git
  cd pier-client-fabric
  make fabric1.4
}

function prepare_config() {
  pier --repo="${PIER_ROOT}" init
  mkdir -p "${PIER_ROOT}"/plugins
  cp "${CURRENT_PATH}"/pier-client-fabric/build/fabric-client-1.4.so "${PIER_ROOT}"/plugins/
  cp -rf "${CURRENT_PATH}"/pier-client-fabric/config "${PIER_ROOT}"/fabric
  cp -rf "${CURRENT_PATH}"/crypto-config "${PIER_ROOT}"/fabric/
  cp -rf "${CURRENT_PATH}"/config.yaml "${PIER_ROOT}"/fabric/
  cp "${PIER_ROOT}"/fabric/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/signcerts/peer1.org2.example.com-cert.pem \
    "${PIER_ROOT}"/fabric/fabric.validators

  x_replace "s/44555/${PPROF_PORT}/g" "${PIER_ROOT}"/pier.toml
  x_replace "s/localhost:60011/${BITXHUB_ADDR}/g" "${PIER_ROOT}"/pier.toml
  x_replace "s/localhost/${FABRIC_IP}/g" "${PIER_ROOT}"/fabric/fabric.toml
  x_replace "s/localhost/${FABRIC_IP}/g" "${PIER_ROOT}"/fabric/config.yaml

}

function register() {
  pier --repo "${PIER_ROOT}" appchain register \
    --name chainA \
    --type fabric \
    --desc chainA-description \
    --version 1.4.3 \
    --validators "${PIER_ROOT}"/fabric/fabric.validators
}

function deploy_rule() {
  pier --repo "${PIER_ROOT}" rule deploy --path "${CURRENT_PATH}"/fabric-rule.wasm
}

function start() {
  export CONFIG_PATH=${PIER_ROOT}/fabric
  pier --repo "${PIER_ROOT}" start
}

print_blue "===> BITXHUB_ADDR: $BITXHUB_ADDR, FABRIC_IP: $FABRIC_IP, pprof: $PPROF_PORT"

prepare

print_blue "===> 1. Clone and compile pier"
compile_pier

print_blue "===> 2. Clone and compile fabric1.4 plugin"
compile_fabric_plugin

print_blue "===> 3. Prepare pier config"
prepare_config

print_blue "===> 4. Register to bitxhub"
register

print_blue "===> 5. Deploy rule to bitxhub"
deploy_rule

print_blue "===> 6. Run pier"
start
