#!/bin/sh
# <url:file:///~/Dropbox (BTG)/TEUIS PROJECT 80-SUPPORT/system_admin/scripts/build_conceptmodel_sdb>
# usage:
# 1. cd to data_models/ directory
# build_conceptmodel_sdb

# process conceptual models
mkdir -p view
find . -iname "conceptmodel*.md" | ack -v 'huseyin|arif|rdm|intro|audit|2016|alexey|temp|datamodel_bps_02|/tr/|/en/' | xargs cat > view/conceptmodel_sdb.yuml
dos2unix view/conceptmodel_sdb.yuml
convert_yuml_markdown_2_clean_yuml view/conceptmodel_sdb.yuml

