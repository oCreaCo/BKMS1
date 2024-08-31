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

    --user=*)
      USER="${i#*=}"
      shift
      ;;

    --port=*)
      PORT="${i#*=}"
      shift
      ;;

    --database=*)
      DATABASE="${i#*=}"
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

# Create User & Database
${BIN_DIR}/createdb -O ${USER} -h localhost -p ${PORT} -U ${USER} -w ${DATABASE}

