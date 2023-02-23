#!/bin/bash

function setCodes {
    RIGHT=1
    ERROR=0
}

function endExecTime {
    end_sub=$(date +%s.%N)
}

function printExecutionTime {
    runtime_sub=$( echo "$end_sub - $start_sub" | bc -l )
    echo "Script execution time (in seconds) = ${runtime_sub} with ${allFolders} folders and ${allFiles} files"
}

function startCalculateTime {
    start_sub=$(date +%s.%N)
}

function setData {
    absolutePath=$1
    numberSubfolders=$2
    listFolders=$3
    numberFiles=$4
    listFiles=$(echo $5 | awk -F. '{print $1}')
    extension=$(echo $5 | awk -F. '{print $2}')
    maximumSize=$6
    allFolders=$numberSubfolders
    allFiles=0
    Day=$(date +%d%m)$(date | awk '{print $NF}' | awk '{print substr($0,3,2)}')
}

function deleteArgument {
    sudo rm -rf $1 2> /dev/null
}

function deleteTmpFiles {
    for i in "$@"; do
        deleteArgument $i
    done
}

function numberEnough {
    status=$RIGHT
    if [[ $3 -eq $RIGHT ]]; then
        if ! [ $1 -eq $2 ]; then
            status=$ERROR
        fi
    else
        status=$ERROR
    fi
    echo $status
}

function sizeEnough {
    status=$(isNumber $1 $3)
    if [[ $status -eq $RIGHT ]]; then
        if [ $1 -lt 1 ] || [ $1 -gt $2 ]; then
            status=$ERROR
        fi
    else
        status=$ERROR
    fi
    echo $status
}

function isPathExisted {
    status=$RIGHT
    if [[ $2 -eq $RIGHT ]]; then
        if ! [ -d $1 ]; then
            status=$ERROR
        fi
    else
        status=$ERROR
    fi
    echo $status  
}

function isNumber {
    status=$RIGHT
    if [[ $2 -eq $RIGHT ]]; then
        if ! [[ $1 =~ ^[0-9]+$ ]] || [[ $1 == 0 ]]; then
            status=$ERROR
        fi
    else
        status=$ERROR
    fi
    echo $status
}

function countSymbol {
    if [ $2 == '.' ] || [ $2 == '^' ]; then
        pattern='\'$2
    else
        pattern=$2
    fi
    echo $(echo $1 | grep -o $pattern | wc -l)
}

function isNameCorrect {
    status=$RIGHT
    regular=^[a-zA-Z]+$
    if [[ $1 -eq $RIGHT ]]; then
        if [[ $2 -eq 1 ]]; then
            count=$(countSymbol $3 '.')
            if [[ $count -eq 1 ]]; then
                name=$(echo $3 | awk -F. '{print $1}')
                extension=$(echo $3 | awk -F. '{print $2}')
                if ! [ $name ] || ! [ $count ]; then
                    status=$ERROR
                fi
            else
                status=$ERROR
            fi
        else
            name=$3
        fi
        if [[ $status -eq $RIGHT ]]; then
            countName=${#name}
            if [[ $countName -lt 1 ]] || [[ $countName -gt $4 ]] || ! [[ $name =~ $regular ]]; then
                status=$ERROR
            fi
            if [[ $2 -eq 1 ]]; then
                countExtension=${#extension}
                if [[ $countExtension -lt 1 ]] || [[ $countExtension -gt $5 ]] || ! [[ $extension =~ $regular ]]; then
                    status=$ERROR
                fi
            fi
        fi
    else
        status=$ERROR
    fi
    echo $status
}

function validateDataFirst {
    status=$(numberEnough $1 6 $RIGHT)
    status=$(isPathExisted $2 $status)
    status=$(isNumber $3 $status)
    status=$(isNameCorrect $status 0 $4 7)
    status=$(isNumber $5 $status)
    status=$(isNameCorrect $status 1 $6 7 3)
    status=$(sizeEnough $7 100 $status)
    echo $status
}

function validateDataSecond {
    status=$(numberEnough $1 3 $RIGHT)
    status=$(isNameCorrect $status 0 $2 7)
    status=$(isNameCorrect $status 1 $3 7 3)
    status=$(sizeEnough $4 100 $status)
    echo $status
}

function getUniqCharactersArray {
    echo "$1" | grep -o . | uniq
}

function joinBy {
    local result=""
    for i in $1; do
        result=$result$i
    done
    echo $result
}

function getUniqStr {
    local uniqStr=$(getUniqCharactersArray $1)
    echo $(joinBy "${uniqStr[@]}")
}
    
function generateNames {
    file=$absolutePath/$2.tmp
    deleteArgument $file
    sudo touch $file
    sudo chmod 777 $file
    for (( x=1; x<=$1; x++ ))
    do
        string=""
        for (( y=4; y<=$x+4; y++ ))
        do
            string=$string$2
        done
        echo $string >> $file
    done
}

function generateRecursive {
    [[ $1 == 1 ]] && {
        while read line; do
            local name=$4${line}
            [[ ${#name} -ge 4 ]] && {
                [[ $type -eq 0 ]] && echo $4${line}_$Day
                [[ $type -eq 1 ]] && echo $4${line}_$Day.$extension
                countObjects=$(( $countObjects + 1 ))
                [[ $countObjects -eq $endObjects ]] && flag=1
                [[ $flag == 1 ]] && break
            }
        done < $absolutePath/$2.tmp
        return
    }
    while read line; do
        generateRecursive $(( $1 - 1 )) ${uniqueString:(( $3 )):1} $(( $3 + 1 )) $4$line
        [[ $flag == 1 ]] && break
    done < $absolutePath/$2.tmp
}

function createNames {
    type=$4
    flag=0
    countObjects=0
    endObjects=$3
    uniqueString=$(getUniqStr $1)
    for char in $(getUniqCharactersArray $uniqueString); do
        generateNames 65 $char
    done
    deleteArgument $absolutePath/$2
    sudo touch $absolutePath/$2
    sudo chmod 777 $absolutePath/$2
    generateRecursive $(( ${#uniqueString} )) ${uniqueString:0:1} 1  >> $absolutePath/$2
    for char in $(getUniqCharactersArray $uniqueString); do
        deleteArgument $absolutePath/$char.tmp
    done
}

function checkSpace {
    space=$(df / | awk 'NR==2 {print $4}')
    space=$(( $space / 1024 / 1024 ))
    [[ $space -lt 1 ]] && {
        echo "################################################################################################"
        echo "#                                                                                              #"
        echo "#                                                                                              #"
        echo "#           Warning: The space of the '/' directory has just became less than 1GB              #"
        echo "#                                                                                              #"
        echo "#                                                                                              #"
        echo "################################################################################################"
    } && exit
}

function makeLog {
    time=$(date +"%T")
    day=$(date | awk '{print $NF}')"-"$(date +%m)"-"$(date +%d)
    path=$1
    sudo echo "$path $day $time $maximumSize" >> file.log
}

function giveAllPermToFile {
    sudo touch $1
    sudo chmod 777 $1
}

function giveAllPermToDir {
    sudo mkdir $1
    sudo chmod 777 $1
}

function createFilesFolders { 
    deleteArgument file.log
    giveAllPermToFile file.log
    countFolders=0
    while read folder; do
        [[ $countFolders == $3 ]] && break
        countFolders=$(( countFolders + 1 ))
        deleteArgument $absolutePath/$folder
        giveAllPermToDir $absolutePath/$folder
        countFiles=0
        endFiles=$(getRandomNumber)
        while read file; do
            sudo fallocate -l $5$7 $absolutePath/$folder/$file
            makeLog $absolutePath/$folder/$file
            countFiles=$(( countFiles + 1 ))
            allFiles=$(( $allFiles + 1 ))
            [[ $6 -eq 0 ]] && [[ $countFiles == $4 ]] && break
            [[ $6 -eq 1 ]] && [[ $countFiles == $endFiles ]] && break
            checkSpace
        done < $absolutePath/$2
    done < $absolutePath/$1
    deleteTmpFiles $absolutePath/$1 $absolutePath/$2
}

function getRandomPath {
    local randomNumber=$(find / -type d 2> /dev/null | grep -v -e "bin" -e "sbin" -e "etc" -e "sys" -e "proc" -e "dev" -e "snap" | wc -l)
    sudo find / -type d 2> /dev/null | grep -v -e "bin" -e "sbin" -e "etc" -e "sys" -e "proc" -e "dev" -e "snap" > paths.tmp
    numberLine=$(( RANDOM % $randomNumber ))
    echo $(cat paths.tmp | sed -n "${numberLine}p")
    rm -rf paths.tmp
}

function getRandomNumber {
    echo $(( RANDOM % 100 + 21 ))
}

function endCalculateTime {
    endExecTime
    printExecutionTime >> file.log
}

function selectOption {
    echo "Clear the system by:"
    echo "1. By log file"
    echo "2. By creation date and time"
    echo "3. By name mask (i.e. characters, underlining and date)"
    echo -n "Your answer ... "; read option
}

function validateOption {
    status=$ERROR
    for i in $(seq $1 $2); do
        [[ $i -eq $3 ]] && { status=$RIGHT; break; }
    done
    echo $status
}

function preExecutingProcess {
if [[ $1 -eq 1 ]]; then
        (! [[ -f file.log ]] || [[ $(cat file.log | wc -l) -eq 0 ]]) && {
            echo
            echo "#####################################################################################################"
            echo "#                                                                                                   #"
            echo "#                                                                                                   #"
            echo "#           Warning: The file.log has to be created with logs before selecting this option          #"
            echo "#                                                                                                   #"
            echo "#                                                                                                   #"
            echo "#####################################################################################################"
            isCorrect=$ERROR
        }
    elif [[ $1 -eq 2 ]]; then
        regular="^([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})$"
        echo
        read -p "Enter START time of range in format of YYYY-MM-DD HH:MM:SS ... " startTimeRange
        read -p "Enter END time of range in format of YYYY-MM-DD HH:MM:SS ... " endTimeRange
        ! [[ $startTimeRange =~ $regular ]] && isCorrect=$ERROR
        ! [[ $endTimeRange =~ $regular ]] && isCorrect=$ERROR
    elif [[ $1 -eq 3 ]]; then
        regular="^.*[a-zA-Z]*_([0-9]{2})([0-9]{2})([0-9]{2}).*$"
    fi
}

function ExecutingProcess {
    if [[ $1 -eq 1 ]]; then
        firstOption
    elif [[ $1 -eq 2 ]]; then
        secondOption
    elif [[ $1 -eq 3 ]]; then
        thirdOption
    fi
}

function firstOption {
    parrentDirectory=""
    while read logLine; do
        path=$(echo $logLine | awk '{print $1}')
        [[ -f $path ]] && {
            deleteArgument $path
            parrentDirectory=$(dirname $(dirname $path))
            deleteArgument $(dirname $path)
        }
    done < file.log
    deleteArgument $parrentDirectory/nameFiles.tmp
    deleteArgument $parrentDirectory/nameFolders.tmp
}

function secondOption {
    regular="^.*[a-zA-Z]*_([0-9]{2})([0-9]{2})([0-9]{2}).*$"
    deleteArgument directory.tmp
    sudo find / -type d 2> /dev/null | grep -v -e "bin" -e "sbin" -e "etc" -e "sys" -e "proc" -e "dev" -e "snap" >> directories.tmp
    dayStart=$(echo $startTimeRange | awk '{print $1}')
    dayEnd=$(echo $endTimeRange | awk '{print $1}')
    timeStart=$(echo $startTimeRange | awk '{print $2}')
    timeEnd=$(echo $endTimeRange | awk '{print $2}')
    left=$(date -d "$dayStart $timeStart" +%s)
    right=$(date -d "$dayEnd $timeEnd" +%s)
    while read directory; do
        directory=$(echo $directory | awk '{print $1}')
        time=$(echo $( stat -c %y $directory 2> /dev/null ) | awk '{print $2}' | awk -F"." '{print $1}')
        day=$(echo $( stat -c %y $directory 2> /dev/null ) | awk '{print $1}')
        middle=$(date -d "$day $time" +%s)
        if [[ $left -le $middle ]] && [[ $right -ge $middle ]] && [[ $directory =~ $regular ]]; then
            deleteArgument $directory
            deleteArgument $(dirname $directory)/nameF*
        fi
    done < directories.tmp
    deleteArgument directories.tmp
}

function thirdOption {
    deleteArgument directory.tmp
    sudo find / -type d 2> /dev/null | grep -v -e "bin" -e "sbin" -e "etc" -e "sys" -e "proc" -e "dev" -e "snap" >> directories.tmp
    while read directory; do
        directory=$(echo $directory | awk '{print $1}')
        if [[ $directory =~ $regular ]]; then
            deleteArgument $directory
            deleteArgument $(dirname $directory)/nameF*
        fi
    done < directories.tmp
}

function setColor {
    RED='\033[1;31m'
    NC='\033[0m'
    GREEN='\033[1;32m'
}