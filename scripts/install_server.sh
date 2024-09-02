#!/bin/bash

# Parse parameters
for i in "$@"
do
  case $i in
    --base-dir=*)
      BASE_DIR="${i#*=}"
      shift
      ;;

    --src-dir=*)
      SRC_DIR="${i#*=}"
      shift
      ;;

    --install-dir=*)
      INSTALL_DIR="${i#*=}"
      shift
      ;;

    --compile-option=*)
      COMPILE_OPTION="${i#*=}"
      shift
      ;;

    --configure)
      CONFIGURE=YES
      shift
      ;;

    *)
      # unknown option
      ;;
  esac
done

# Check for postgres source directory
if [[ ! -d ${SRC_DIR} ]]
then
  cd ${BASE_DIR}

  # Clone the postgres source files
  git clone https://github.com/postgres/postgres.git

  cd ./postgres

  # Initial configure
  git switch REL_15_STABLE
  ./configure

  # Go back to the previous directory
  cd - > /dev/null 2>&1
fi

# Postgres source directory
cd ${SRC_DIR}

# Cleanup
make clean -j$((`nproc`/2)) -s

# Configure
if [[ ${CONFIGURE}==YES ]]
then
  ./configure --silent --prefix=${INSTALL_DIR}
fi

# Build & Install
make -j$((`nproc`/2)) -s
make install -j$((`nproc`/2)) -s

