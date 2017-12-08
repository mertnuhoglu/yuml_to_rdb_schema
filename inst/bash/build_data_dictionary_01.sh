#!/bin/sh
# @deprecated: replaced with
# <url:/Users/mertnuhoglu/Dropbox (BTG)/TEUIS PROJECT 05-ANALYSIS/working_library/requirements_database/scripts/prepare_rdb_data_operations.R#tn=build_data_dictionary_01 = function() {>
# <url:file:///~/Dropbox (BTG)/teuis project 80-support/system_admin/scripts/build_data_dictionary_01>
# usage:
# 1. cd to data_models/ directory
# output:
# dd_01.csv

# generate data_dictionary: dd01.csv
# ConvertYuml2DataDictionary works in Vim but not when called from terminal
#vim -c "silent! ConvertYuml2DataDictionary" -c "sav! view/dd_00.csv" -c "q! " view/datamodel_sdb.yuml
# awk 'BEGIN{FS=OFS=","} NR==1{nc=NF} NF{$nc=$nc} 1' view/dd_00.csv | sponge view/dd_01.csv
# next: prepare_rdb_data_operations.R rdb_data_operations_01() <url:/Users/mertnuhoglu/Dropbox (BTG)/TEUIS PROJECT 05-ANALYSIS/working_library/requirements_database/scripts/prepare_rdb_data_operations.R#tn=rdb_data_operations_01 = function() {>


