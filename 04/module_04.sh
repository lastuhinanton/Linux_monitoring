#!/bin/bash

. ../module.sh

function generateRanNum {
    echo $(( RANDOM % ($2 - $1) + $1 ))
}

function generateIPs {
    for i in $(seq 1 $1); do
        echo "$(generateRanNum 0 255).$(generateRanNum 0 255).$(generateRanNum 0 255).$(generateRanNum 0 255)"
    done >> ips.tmp
}

function setResponseCodes {
    declare -ag codes=("200" "201" "400" "401" "403" "404" "500" "501" "502" "503")
}

function generateRespCodes {
    setResponseCodes
    for i in $(seq 1 $1); do
        echo ${codes[$(generateRanNum 1 10)]}
    done >> codes.tmp
}

function setMethods {
    declare -ag methods=("GET /a.gif HTTP/1.1" "POST /b.gif HTTP/1.1" "PUT /c.jpg HTTP/1.1" "PATCH /d.gif HTTP/1.0" "DELETE /e.gif HTTP/1.0")
}

function generateMethods {
    setMethods
    for i in $(seq 1 $1); do
        echo ${methods[$(generateRanNum 1 5)]}
    done >> methods.tmp
}

function normalizeNumber {
    number=$(( $1 / 10 ))
    if [ $number -eq 0 ]; then
        echo 0$1
    else
        echo $1
    fi
}

function generateDateTime {
    year=$(generateRanNum 2000 2024)
    mounth=$(normalizeNumber $(generateRanNum 1 12))
    day=$(normalizeNumber $(generateRanNum 1 30))
    for i in $(seq 1 $1); do
        hours=$(normalizeNumber $(generateRanNum 0 24))
        minutes=$(normalizeNumber $(generateRanNum 0 60))
        seconds=$(normalizeNumber $(generateRanNum 0 60))
        time="$hours:$minutes:$seconds"
        echo "$year-$mounth-$day $time"
    done >> date.tmp
    sort -k 2 -o dateTime.tmp date.tmp
    deleteArgument date.tmp
}

function setAgentUrls {
    main="https://edu.21-school.ru/"
    declare -ag urls=("calendar/" "index.html" "graph/basis/main.png" "penalties" "bonuses/achievements/index.html" \
                      "my-profile/index.html" "projects" "projects/recommended" "competition/coalition/index.html"
                      "calendar/events/main.png" "contacts" "my-profile/main.png" "notifications" "wallet")
}

function generateUrls {
    setAgentUrls
    for i in $(seq 1 $1); do
        echo $main${urls[$(generateRanNum 1 14)]}
    done >> urls.tmp

}

function setAgents {
    declare -ag agents=("Mozilla/1.6.0 (Linux; U; Android 4.3; SC-02E Build/JSS15J)" \
                        "Google/1.6.0 (Linux; U; Android 4.4.2; HUAWEI Y625-U21 Build/HUAWEIY625-U21)" \
                        "Chrome/1.6.0 (Linux; U; Android 4.4.2; Predator7 Build/KOT49H)" \
                        "Opera/2.1.0 (Linux; U; Android 10; M2003J15SC MIUI/V12.0.4.0.QJOINXM)" \
                        "Safari/2.1.0 (Linux; U; Android 10; Realme 5 Pro Build/QQ3A.200605.002)" \
                        "Internet Explorer/2.1.0 (Linux; U; Android 11; CPH2061 Build/RKQ1.200903.002)" \
                        "Microsoft Edge/2.1.0 (Linux; U; Android 11; RMX3201 Build/RP1A.200720.011)" \
                        "Amazonbot/2.1.0 (Linux; U; Android 5.1.1; LG-H961N Build/LMY47V)" \
                        "Bingbot/2.1.0 (Linux; U; Android 5.1; CUBOT_NOTE_S Build/LMY47I)" \
                        "DuckDuckBot/2.1.0 (Linux; U; Android 6.0.1; ONE E1001 Build/MMB29M)" \
                        "Googlebot/2.1.0 (Linux; U; Android 6.0; Primo D8i Build/Primo_D8i_S005_05082017)" \
                        "Yahoo Slurp/2.1.0 (Linux; U; Android 6.0; RCT6K03W13 Build/MRA58K)" \
                        "Yandex Bot/2.1.0 (Linux; U; Android 7.0; BQ-1082G Build/NRD90M)")
}

function generateAgents {
    setAgents
    for i in $(seq 1 $1); do
        echo ${agents[$(generateRanNum 1 13)]}
    done >> agents.tmp
}

function getLogPart {
    cat $1 | sed -n "$2p"
}

function generateLogs {
    deleteTmpFiles "ips.tmp" "codes.tmp" "methods.tmp" "dateTime.tmp" "urls.tmp" "agents.tmp" 
    for i in $(seq 1 5); do
        file="${i}_day.log"
        number=$(generateRanNum 100 1000)
        generateIPs $number
        generateRespCodes $number
        generateMethods $number
        generateDateTime $number
        generateUrls $number
        generateAgents $number
        for j in $(seq 1 $number); do
            echo -n "$(getLogPart "ips.tmp" $j)" >> tmp.tmp
            echo -n " - - " >> tmp.tmp
            echo -n $(date -d "$(getLogPart dateTime.tmp $j)" +'[%d/%b/%Y:%H:%M:%S %z]') >> tmp.tmp
            echo -n " \"$(getLogPart "methods.tmp" $j)\" " >> tmp.tmp
            echo -n "$(getLogPart "codes.tmp" $j)" >> tmp.tmp
            echo -n " $(generateRanNum 0 34412) " >> tmp.tmp
            echo -n "\"$(getLogPart "urls.tmp" $j)\"" >> tmp.tmp
            echo " \"$(getLogPart "agents.tmp" $j)\" " >> tmp.tmp
        done
        cat tmp.tmp >> $file 
        deleteTmpFiles "ips.tmp" "codes.tmp" "methods.tmp" "dateTime.tmp" "urls.tmp" "agents.tmp" 
        deleteArgument "tmp.tmp"
    done
}