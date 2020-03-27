#!/usr/bin/env bash

set -e

CURRENT_PATH=$(pwd)
PIER_ROOT=${CURRENT_PATH}/.pier
CHANNEL_ID=mychannel
CHAINCODE_NAME=data_swapper

export CONFIG_PATH=${PIER_ROOT}/fabric

echo "===> Query path value"

fabric-cli chaincode invoke --ccid=${CHAINCODE_NAME} \
  --args '{"Func":"get","Args":["path"]}' \
  --config="${PIER_ROOT}"/fabric/config.yaml --payload \
  --orgid=org2 --user=Admin --cid=${CHANNEL_ID}
