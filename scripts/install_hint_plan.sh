#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
BASE_DIR=${SCRIPT_DIR}/..

cd ${BASE_DIR}

PGCONFIG=${BASE_DIR}/pgsql/bin/pg_config

if [[ ! -d "pg_hint_plan" ]]
then
    git clone https://github.com/ossc-db/pg_hint_plan.git
    
    cd pg_hint_plan

    make PG_CONFIG=${PGCONFIG}
    make PG_CONFIG=${PGCONFIG} install
fi