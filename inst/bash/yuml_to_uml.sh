#!/bin/sh
# usage:
# sh yuml_to_uml.sh ./datamodel_gis.md
# note that you have to prepend "./" directory even if it is current directory
filepath=$1
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
echo "running $0"
echo "DATA_MODEL_DIR = ${DATA_MODEL_DIR}"
echo "SCRIPT_DIR = ${SCRIPT_DIR}"
# echo $filepath
# ./gis/datamodel_gis.md
basepath=${filepath%/*}
# echo $basepath
# ./gis/datamodel_gis
filename=${filepath##*/}
# echo $filename
# datamodel_gis.md
basename=${filename%.*}
# echo $basename
# datamodel_gis
basepath_nodot=${basepath#*/}
# echo $basepath_nodot
# gis
folder=${basepath_nodot%/*}
# echo $folder
# gis
targetfolder=${folder}/img
# echo $targetfolder
# gis/img
target_text=${targetfolder}/${basename}_yuml.txt
simple_target_text=${targetfolder}/simple_${basename}_yuml.txt
# echo $target_text
# gis/img/datamodel_gis_yuml.txt
target_img=${targetfolder}/${basename}.png
simple_target_img=${targetfolder}/simple_${basename}.png
echo $target_img
# gis/img/datamodel_gis.png

mkdir -p $targetfolder
cp $filepath $target_text
# optional:
sed -i 's/#\s*$//' $target_text
sed -i 's/]\s*;.*$//' $target_text
sh "${SCRIPT_DIR}/convert_yuml_markdown_2_clean_yuml.sh" $target_text
# yuml from: https://github.com/wandernauta/yuml
yuml -f png -t class -s plain -i $target_text -o $target_img

cp $target_text $simple_target_text
sh "${SCRIPT_DIR}/convert_yuml_markdown_2_clean_yuml_simple.sh" $simple_target_text
yuml -f png -t class -s plain --dir=LR -i $simple_target_text -o $simple_target_img
