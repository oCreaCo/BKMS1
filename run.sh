#!/bin/bash
if [[ "$1" == "-h" ]]; then
  echo "Usage: `basename $0` [options]"
  echo "Options:"
  echo "  --install           compile and install postgres source"
  echo "  --initdb            initialize database using initdb command"
  echo "  --start             start the main server process"
  echo "  --createdb          create a new user $(whoami), and create a database $(whoami) owned by user $(whoami)"
  echo "  --stop              terminate the main server process"
  exit 0
fi

# Directories
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

SCRIPT_DIR="${BASE_DIR}/scripts"

SRC_DIR="${BASE_DIR}/postgres"

INSTALL_DIR="${BASE_DIR}/pgsql"
BIN_DIR="${INSTALL_DIR}/bin"
LIB_DIR="${INSTALL_DIR}/lib"

DATA_DIR="${BASE_DIR}/data"

CONFIG_DIR="${BASE_DIR}/config"

# Scripts
INSTALL_SCRIPT="${SCRIPT_DIR}/install_server.sh"
INIT_SERVER_SCRIPT="${SCRIPT_DIR}/init_server.sh"
START_SERVER_SCRIPT="${SCRIPT_DIR}/start_server.sh"
CREATE_DB_SCRIPT="${SCRIPT_DIR}/create_db.sh"
STOP_SERVER_SCRIPT="${SCRIPT_DIR}/stop_server.sh"

LOGFILE="${BASE_DIR}/logfile"
CONFIGFILE="${CONFIG_DIR}/postgresql.conf"

# DB Config
USER=$(whoami)
DATABASE=${USER}
PORT=5678 # If you change the port, you must change the postgresql.conf file in config directory

# Parse parameters
for i in "$@"
do
  case $i in
    --install)
      INSTALL=YES
      shift
      ;;

    --initdb)
      INITDB=YES
      shift
      ;;

    --start)
      START=YES
      shift
      ;;

    --createdb)
      CREATEDB=YES
      shift
      ;;

    --stop)
      STOP=YES
      shift
      ;;

    *)
      # unknown option
      ;;
  esac
done

echo "INSTALL           = ${INSTALL}"
echo "INITDB            = ${INITDB}"
echo "START             = ${START}"
echo "CREATEDB          = ${CREATEDB}"
echo "STOP              = ${STOP}"

# Install Postgres
if [[ "${INSTALL}" == "YES" ]]
then
    ${INSTALL_SCRIPT} \
      --base-dir=${BASE_DIR} \
      --src-dir=${SRC_DIR} \
      --install-dir=${INSTALL_DIR} \
      --compile-option="" \
      --configure
fi

# Init Server
if [[ "${INITDB}" == "YES" ]]
then
    ${INIT_SERVER_SCRIPT} \
      --bin-dir=${BIN_DIR} \
      --lib-dir=${LIB_DIR} \
      --data-dir=${DATA_DIR} \
      --configfile=${CONFIGFILE}
fi

# Start Server
if [[ "${START}" == "YES" ]]
then
    PID_FILE="$DATA_DIR/postmaster.pid"
    if [[ -f "$PID_FILE" ]]; then
        POSTMASTER_PID=$(head -n 1 "$PID_FILE")
        if ps -p "$POSTMASTER_PID" > /dev/null; then
            echo "The PostgreSQL server is already running with PID $POSTMASTER_PID."
            exit 1
        else
            echo "The PID file exists, but no process is found with PID $POSTMASTER_PID. Deleting the stale file."
            rm "$PID_FILE"
        fi
    fi
    ${START_SERVER_SCRIPT} \
      --bin-dir=${BIN_DIR} \
      --data-dir=${DATA_DIR} \
      --logfile=${LOGFILE}
fi

# Create User & Database
if [[ "${CREATEDB}" == "YES" ]]
then
    ${CREATE_DB_SCRIPT} \
      --bin-dir=${BIN_DIR} \
      --data-dir=${DATA_DIR} \
      --user=${USER} \
      --port=${PORT} \
      --database=${DATABASE}
fi

# Stop Server
if [[ "${STOP}" == "YES" ]]
then
    ${STOP_SERVER_SCRIPT} \
      --bin-dir=${BIN_DIR} \
      --data-dir=${DATA_DIR}
fi
