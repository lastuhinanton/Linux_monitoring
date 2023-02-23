#!/bin/bash

. ../module.sh
. ../04/module_04.sh

function selectOption {
    echo
    echo "Choise the type of output:"
    echo "1. All entries sorted by response code"
    echo "2. All unique IPs found in the entries"
    echo "3. All requests with errors"
    echo "4. All unique IPs found among the erroneous requests"
    echo -n "Your answer ... "; read option
}

function preOutputProcess {
    [[ $(find . | grep .log | wc -l) -eq 0 ]] && {
        isCorrect=$ERROR
        echo "##################################################################################################"
        echo "#                                                                                                #"
        echo "#                                                                                                #"
        echo "#          Warning: You need to have files with .log extension to activate this option           #"
        echo "#                                                                                                #"
        echo "#                                                                                                #"
        echo "##################################################################################################"
    }
}

function formatOutput {
    echo
    echo "Do you wanna print logs? (Y/N)"
    echo -n "Your answer ... "; read printLog
    if [[ $printLog == "Y" ]] || [[ $printLog == "y" ]]; then
        printLog=1
    else
        printLog=0
    fi
}

function outputProcess {
    deleteTmpFiles logs.tmp output.tmp
    find . | grep .log >> logs.tmp
    formatOutput
    while read file; do
        cat $file| grep .log -v >> output.tmp
    done < logs.tmp
    if [[ $1 -eq 1 ]]; then
        oneOption $printLog
    elif [[ $1 -eq 2 ]]; then
        twoOption $printLog
    elif [[ $1 -eq 3 ]]; then
        threeOption $printLog
    elif [[ $1 -eq 4 ]]; then
        fourOption $printLog
    fi
    deleteTmpFiles logs.tmp output.tmp
}

function oneOption {
    deleteArgument result.tmp
    awk '{print $0 | "sort -k 6 -o result.tmp"}' output.tmp
    [[ $1 -eq 1 ]] && cat result.tmp && deleteArgument result.tmp
}

function twoOption {
    deleteArgument result.tmp
    cat output.tmp | awk '{print $1}' | uniq >> result.tmp
    [[ $1 -eq 1 ]] && cat result.tmp && deleteArgument result.tmp
}

function threeOption {
    deleteArgument result.tmp
    regular=^[45][0-9]{2}$
    while read line; do
        [[ $(echo $line | awk '{print $9}') =~ $regular ]] && echo $(echo $line | awk '{print $11}') >> result.tmp
    done < output.tmp
    deleteArgument tmp.tmp
    [[ $1 -eq 1 ]] && cat result.tmp && deleteArgument result.tmp
}

function fourOption {
    deleteArgument result.tmp
    regular=^[45][0-9]{2}$
    while read line; do
        [[ $(echo $line | awk '{print $9}') =~ $regular ]] && echo $(echo $line | awk '{print $1}') >> tmp.tmp
    done < output.tmp
    cat tmp.tmp | awk '{print $1}' | uniq >> result.tmp
    deleteArgument tmp.tmp
    [[ $1 -eq 1 ]] && cat result.tmp && deleteArgument result.tmp
}