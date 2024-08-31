#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

INSTALL_DIR="${BASE_DIR}/pgsql"
BIN_DIR="${INSTALL_DIR}/bin"

# DB Config
USER=$(whoami)
DATABASE=${USER}
PORT=5678

# Parse parameters
for i in "$@"
do
  case $i in
    --database=*)
      DATABASE="${i#*=}"
      shift
      ;;

    *)
      # unknown option
      ;;
  esac
done

# Connect Client
${BIN_DIR}/psql -p ${PORT} -d ${DATABASE} -U ${USER}
