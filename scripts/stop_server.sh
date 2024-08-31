#!/bin/bash

# Parse parameters
for i in "$@"
do
  case $i in
    --bin-dir=*)
      BIN_DIR="${i#*=}"
      shift
      ;;

    --data-dir=*)
      DATA_DIR="${i#*=}"
      shift
      ;;

    *)
      # unknown option
      ;;
  esac
done

if [[ ! -f ${DATA_DIR}/postmaster.pid ]]
then
  echo "There are no servers currently running";
  exit 1
fi

# Server stop
${BIN_DIR}/pg_ctl -D ${DATA_DIR} stop

