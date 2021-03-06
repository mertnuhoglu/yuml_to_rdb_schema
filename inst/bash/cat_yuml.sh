#!/bin/sh
# <url:file:///~/Dropbox (BTG)/teuis project 80-support/system_admin/scripts/build_datamodel_sdb>
# usage:
# 1. cd to data_models/ directory
# build_datamodel_sdb

# process data models
# DATA_MODEL_DIR="$HOME/Dropbox (BTG)/TEUIS PROJECT 05-ANALYSIS/working_library/data_models"
echo "The script you are running has basename `basename $0`, dirname `dirname $0`"
DATA_MODEL_DIR=$1
#SCRIPT_DIR=`dirname $0`
#SCRIPT_DIR="${0%/*}"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cd "${DATA_MODEL_DIR}"
echo "running $0"
echo "DATA_MODEL_DIR = ${DATA_MODEL_DIR}"
echo "SCRIPT_DIR = ${SCRIPT_DIR}"

mkdir -p data/view
find . -iname "data*" | ack 'data_model|datamodel' | ack '\.md' | xargs cat > data/view/datamodel_sdb_p01.yuml
dos2unix data/view/datamodel_sdb_p01.yuml

cd "${SCRIPT_DIR}"
./convert_yuml_markdown_2_clean_yuml.sh "${DATA_MODEL_DIR}/data/view/datamodel_sdb_p01.yuml"
#vim -c "ConvertYumlMarkdown2CleanYuml" -c wq data/view/datamodel_sdb.yuml
vim -S YumlFixFormat.vim -c "YumlFixFormat" -c "w! ${DATA_MODEL_DIR}/data/view/datamodel_sdb.yuml" -c 'q!' "${DATA_MODEL_DIR}/data/view/datamodel_sdb_p01.yuml"

# update rdb_data
# Process for updating rdb_data <url:file:///~/Dropbox (BTG)/TEUIS PROJECT 90-TEMPORARY/10-Users/Mert/study/study_cyclic_data_update_problem_20160506.md#r=g_10018>
# <url:file:///~/Dropbox (BTG)/TEUIS PROJECT 05-ANALYSIS/working_library/requirements_database/scripts/prepare_rdb_data_operations.R>

./build_conceptmodel_sdb.sh
