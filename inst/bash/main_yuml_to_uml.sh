#!/bin/sh
# usage:
# sh /Users/mertnuhoglu/projects/yumltordbschema/inst/bash/main_yuml_to_uml.sh /Users/mertnuhoglu/projects/itr/itr_documentation/data_model

DATA_MODEL_DIR=$1
#SCRIPT_DIR=`dirname $0`
#SCRIPT_DIR="${0%/*}"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cd "${DATA_MODEL_DIR}"
echo "running $0"
echo "DATA_MODEL_DIR = ${DATA_MODEL_DIR}"
echo "SCRIPT_DIR = ${SCRIPT_DIR}"

find . -iname "data*" | ack 'data_model|datamodel' | ack '\.md' | ack -v 'temp|datamodel_bps_02|/tr/|/en/' | xargs -n1 -d '\n' -I {} sh "${SCRIPT_DIR}/yuml_to_uml.sh" {}
find . -iname "conceptmodel*.md" | ack -v 'temp|datamodel_bps_02|/tr/|/en/' | xargs -n1 -d '\n' -I {} sh "${SCRIPT_DIR}/yuml_to_uml.sh" {}
