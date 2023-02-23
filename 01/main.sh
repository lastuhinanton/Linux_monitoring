#!/bin/bash

. ../module.sh

setData
setCodes
startCalculateTime

isCorrect=$(validateDataFirst $# $1 $2 $3 $4 $5 $6)

if [[ $isCorrect == $RIGHT ]]; then
    setData $1 $2 $3 $4 $5 $6
    createNames $listFolders "nameFolders.tmp" $numberSubfolders 0
    createNames $listFiles "nameFiles.tmp" $numberFiles 1
    createFilesFolders "nameFolders.tmp" "nameFiles.tmp" $numberSubfolders $numberFiles $maximumSize 0 K
else
    echo "##################################################################################"
    echo "#                                                                                #"
    echo "#                                                                                #"
    echo "#    Usage: bash/sh main.sh                                                      #"
    echo "#    <absolute path> <number of subfolders>                                      #"
    echo "#    <list of English letters> <number of files>                                 #"
    echo "#    <list of English letters> <file size>                                       #"
    echo "#                                                                                #"
    echo "#                                                                                #"
    echo "##################################################################################"
fi

endCalculateTime