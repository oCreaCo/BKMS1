#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
BASE_DIR=${SCRIPT_DIR}/..

cd ${BASE_DIR}

USER=$(whoami)
PSQL=$(pwd)/pgsql/bin/psql

if [[ ! -d "citus-benchmark" ]]
then
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
    sudo apt-get -y update

    git clone https://github.com/citusdata/citus-benchmark.git

    cd citus-benchmark

    # build.sh
    # Add the path to the psql executable to the psql command
    sed -i "s|psql|${PSQL}|g" ./build.sh

    # parse-arguments.sh
    # Modify default values for environment variables
    sed -i "131s|.*|export PGPORT=\${PGPORT:-5678}|g" ./parse-arguments.sh
    sed -i "132s|.*|export PGUSER=\${PGUSER:-${USER}}|g" ./parse-arguments.sh
    sed -i "133s|.*|export PGDATABASE=\${PGDATABASE:-chbenchmark}|g" ./parse-arguments.sh
    sed -i "134,137s|^|# |" ./parse-arguments.sh
    sed -i "138s|.*|export PGPASSWORD=\${PGPASSWORD:-${USER}}|g" ./parse-arguments.sh

    # run.sh
    # Add the path to the psql executable to the psql command
    sed -i "s|psql|${PSQL}|g" ./run.sh

    # ch_benchmark.py
    # Add the path to the psql executable to the psql command
    sed -i "s|psql|${PSQL}|g" ./ch_benchmark.py
fi
