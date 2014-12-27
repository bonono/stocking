#!/usr/bin/env bash

if [ $# -ne 1 ]; then
   echo "Please specify zip file name will be outputed."
   exit 1:
fi

PACKAGE=$1

# CoffeeScriptのコンパイル
coffee -o script/js/ -c script/coffee/
rm -rf script/coffee/

# SASSのコンパイル
sass --no-cache --update style/sass:style/css
rm -rf style/sass style/.sass-cache style/css/*.map

# 不要ファイル削除
rm -rf .git .gitignore node_modules "test/" karma.conf.js package.json README.md

find . -name ".DS_Store" -exec rm {} \;
find . -name "Thumbs.db" -exec rm {} \;

zip -r $PACKAGE ./

