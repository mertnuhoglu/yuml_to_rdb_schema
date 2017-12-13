#!/bin/sh
# <url:file:///~/Dropbox (BTG)/TEUIS PROJECT 80-SUPPORT/system_admin/scripts/convert_yuml_2_table_list>
# usage:
# convert_yuml_2_table_list model.md
# corresponds to the following function:
# <url:/Users/mertnuhoglu/.vim/bundle/vim-infoman/plugin/vim-infoman.vim#tn=function! ConvertYuml2TableList()>
# filepath=view/datamodel_sdb.yuml
filepath=$1
mkdir -p tmp
cp $filepath tmp/temp
cd tmp/
grep -oh '^\s*\[\w\+[|\]]' temp
>temp2 ed -s temp <<< $'g/[.:#]/d\n,p'  
>temp3 ed -s temp2 <<< $'v/]/d\n,p'
>temp4 sort -u temp3 
>temp5 ed -s temp4 <<< $'g/|/m0\n,p'
cd ..
cp -f tmp/temp5 $filepath
rm -rf tmp/
