#!/bin/bash

# Parse parameters
for i in "$@"
do
  case $i in
    --bin-dir=*)
      BIN_DIR="${i#*=}"
      shift
      ;;

    --lib-dir=*)
      LIB_DIR="${i#*=}"
      shift
      ;;

    --data-dir=*)
      DATA_DIR="${i#*=}"
      shift
      ;;

    --configfile=*)
      CONFIGFILE="${i#*=}"
      shift
      ;;

    *)
      # unknown option
      ;;
  esac
done

if [[ -f ${DATA_DIR}/postmaster.pid ]]
then
  echo "The server is running, shutdown the server first";
  exit 1
fi

# Init server (create data directory, etc.)
rm -rf ${DATA_DIR} > /dev/null 2>&1
${BIN_DIR}/initdb -D ${DATA_DIR}

cp ${CONFIGFILE} ${DATA_DIR}

