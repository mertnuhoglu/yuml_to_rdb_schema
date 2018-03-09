#!/bin/sh
# usage:
DATA_MODEL_DIR=$1
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

cd "${DATA_MODEL_DIR}"
echo "running $0"
echo "DATA_MODEL_DIR = ${DATA_MODEL_DIR}"
echo "SCRIPT_DIR = ${SCRIPT_DIR}"

datafiller --size=5 "${DATA_MODEL_DIR}/data/view/ddl_m.sql" > "${DATA_MODEL_DIR}/data/view/data.sql" 
psql -d $PGDATABASE -h $PGHOST -p $PGPORT -U $PGUSER -f "${DATA_MODEL_DIR}/data/view/init.sql"
