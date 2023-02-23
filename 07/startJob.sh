#!/bin/bash

. ../module.sh

function checkStatus {
    for service in "$@"; do
        status=$(sudo systemctl status $service | grep Active | awk '{print $2}')
        if [[ $status == "active" ]]; then
            printf "\nThe status of $service - ${GREEN}$status${NC}\n"
        else
            printf "\nThe status of $service - ${RED}$status${NC}\n\n"
        fi
    done
}

function activateStatus {
    for service in "$@"; do
        sudo systemctl start $service
    done
}

function checkOption {
    if ! [[ $(validateOption $1 $2 $option) -eq $RIGHT ]]; then
        printf "\n${RED}Usage: Options start from 1(one) to 5(five)${NC}\n"
        printf "${RED}Try again ..${NC}\n"
        askOfStatus
    fi
}


function askOfStatus {
    printf "\nDo you wanna activate all servers or only particular one?\n\n"
    echo "1. All"
    echo "2. grafana-server.service"
    echo "3. prometheus"
    echo "4. node_exporter"
    printf "5. Exit\n\n"
    echo -n "Your answer ... "; read option
    checkOption 1 5
}

function executeOption {
    [[ $option ]] && {
        if [[ $option -eq 1 ]]; then
            activateStatus ${services[@]}
        else
            activateStatus ${services[$option - 2]}
        fi
    }
}

function setServices {
    declare -ag services=("grafana-server.service" "prometheus" "node_exporter")
}

function askOfOpen {
    printf "\nDo you wanna activate all websites or only particular one?\n\n"
    echo "1. All"
    echo "2. grafana-server.service"
    echo "3. prometheus"
    printf "4. Exit\n\n"
    echo -n "Your answer ... "; read option
    checkOption 1 4
}

function openSytes {
    for sytes in "$@"; do
        python3 -m webbrowser $sytes
    done
}

function openWebsyte {
    begin="http://localhost:"
    [[ $option -eq 1 ]] && openSytes { ${begin}3000 ${begin}9090 }
    [[ $option -eq 2 ]] && openSytes { ${begin}3000 }
    [[ $option -eq 3 ]] && openSytes { ${begin}9090 }
}


setServices
setCodes
setColor

checkStatus ${services[@]}
askOfStatus
executeOption
checkStatus ${services[@]}

askOfOpen
openWebsyte


