#!/usr/bin/env bash

set -e

VERSION=1.0
CURRENT_PATH=$(pwd)
FABRIC_SAMPLE_PATH=${CURRENT_PATH}/fabric-samples
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "${CURRENT_PATH}"
export CONFIG_PATH=${CURRENT_PATH}

fabric-cli chaincode invoke --cid mychannel --ccid=broker \
  --args='{"Func":"initialize"}' \
  --user Admin --orgid org2 --payload --config ./config.yaml
