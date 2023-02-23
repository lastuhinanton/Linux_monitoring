#!/bin/bash

. ../module.sh

setData
setCodes
startCalculateTime

isCorect=$(validateDataSecond $# $1 $2 $3)

if [[ $isCorect -eq 1 ]]; then
    setData $(getRandomPath) $(getRandomNumber) $1 121 $2 $3
    createNames $listFolders "nameFolders.tmp" $numberSubfolders 0
    createNames $listFiles "nameFiles.tmp" $numberFiles 1
    createFilesFolders "nameFolders.tmp" "nameFiles.tmp" $numberSubfolders $numberFiles $maximumSize 1 M
else
    echo "################################################################################################"
    echo "#                                                                                              #"
    echo "#                                                                                              #"
    echo "#    Usage: bash/sh main.sh <list of English letters> <list of English letters> <file size>    #"
    echo "#                                                                                              #"
    echo "#                                                                                              #"
    echo "################################################################################################"
fi

endCalculateTime
