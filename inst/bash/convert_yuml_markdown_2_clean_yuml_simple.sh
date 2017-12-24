#!/bin/sh
# <url:file:///~/Dropbox (BTG)/TEUIS PROJECT 80-SUPPORT/system_admin/scripts/convert_yuml_markdown_2_clean_yuml>
# usage:
# convert_yuml_markdown_2_clean_yuml data/view/datamodel_sdb.yuml
# corresponds to the following function:
# <url:/Users/mertnuhoglu/.vim/bundle/vim-infoman/plugin/vim-infoman.vim#tn=command! ConvertYumlMarkdown2CleanYuml call ConvertYumlMarkdown2CleanYuml()>
filepath=$1
mkdir -p tmp
cp $filepath ./tmp/temp
cd tmp
sed -i 's/^\s*/    /' temp
grep -v '[<>:#`"()]' temp >temp2 
grep -v '\. \w' temp2 >temp3 
grep ']\s*$' temp3 >temp4 
grep ']\s*;.*$' temp3 >>temp4 
grep '^ \+\[' temp4 >temp5 
sort -u temp5 >temp6 
>temp7 ed -s temp6 <<< $'g/|/m$\n,p'
cd ..
cp -f tmp/temp7 $filepath
rm -rf tmp/

