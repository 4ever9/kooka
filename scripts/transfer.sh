#!/usr/bin/env bash

set -e

CURRENT_PATH=$(pwd)
PIER_ROOT=${CURRENT_PATH}/.pier

TARGET_APPCHAIN_ID=$1
TARGET_CHAINCODE_ID="mychannel&transfer"
CHANNEL_ID=mychannel
CHAINCODE_NAME=transfer

if [ ! $1 ]; then
  echo "Please input target appchain id at first arg"
  exit 1
fi

export CONFIG_PATH=${PIER_ROOT}/fabric

echo "===> Alice transfer token from appchain A to appchain B"
echo "===> Target appchain id: $TARGET_APPCHAIN_ID"

fabric-cli chaincode invoke --ccid="${CHAINCODE_NAME}" \
  --args '{"Func":"transfer","Args":["'"${TARGET_APPCHAIN_ID}"'", "'"${TARGET_CHAINCODE_ID}"'", "Alice","Alice","1"]}' \
  --config="${PIER_ROOT}"/fabric/config.yaml --payload \
  --orgid=org2 --user=Admin --cid=${CHANNEL_ID}
