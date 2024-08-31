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

    --logfile=*)
      LOGFILE="${i#*=}"
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

rm $LOGFILE > /dev/null 2>&1

# Server start
${BIN_DIR}/pg_ctl -D ${DATA_DIR} -l ${LOGFILE} start

