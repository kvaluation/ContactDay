#!/bin/sh

# coding: utf-8
# Dropbox: 処理本体; GoogleDrive: 外部共有用
# probeCOCOATEK: https://github.com/rocaz/probeCOCOATek
# home directory
# on MacOS
# probeCOCOATEKを使って、DropboxとGoogleDriveにTEKの毎日のリストであるlist.jsonと、TEKの入ったzipファイルをダウンロードする。


#listYYYYMMDD.txt
/Users/home/Library/Python/3.8/bin/probeCOCOATEK list -nk  > \
/Users/home/Dropbox/EN/List/list`date "+%Y%m%d"`.txt 

# /Users/home/Library/Python/3.8/bin/probeCOCOATEK list -nk  > \
# /Volumes/GoogleDrive/共有ドライブ/home/ENonGoogleDrive/List/list`date "+%Y%m%d"`.txt 

#TEK zip files
/Users/home/Library/Python/3.8/bin/probeCOCOATEK dl \
/Users/home/Dropbox/EN/Zipfiles

# /Users/home/Library/Python/3.8/bin/probeCOCOATEK dl \
# /Volumes/GoogleDrive/共有ドライブ/home/ENonGoogleDrive/Zipfiles
