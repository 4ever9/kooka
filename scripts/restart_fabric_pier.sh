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

function start() {
  export CONFIG_PATH=${PIER_ROOT}/fabric
  pier --repo "${PIER_ROOT}" start
}

print_blue "===> BITXHUB_ADDR: $BITXHUB_ADDR, FABRIC_IP: $FABRIC_IP, pprof: $PPROF_PORT"
print_blue "===> Restart pier"
start
