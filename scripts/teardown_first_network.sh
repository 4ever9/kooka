#!/usr/bin/env bash

set -e

CURRENT_PATH=$(pwd)
FABRIC_SAMPLE_PATH=${CURRENT_PATH}/fabric-samples

cd "${FABRIC_SAMPLE_PATH}"/first-network

./byfn.sh down
