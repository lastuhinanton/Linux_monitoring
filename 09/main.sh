#!/bin/bash


function setUtilitis {
    sudo apt install mpstat
}

while true; do
    my_path=/var/www/html/index.html
    
    echo "cpu_usage $(mpstat | tail -n 1 | awk '{print $12}')" > $my_path
    echo "total_ram $(free -m | awk '/Mem:/ {printf $2}')" >> $my_path
    echo "used_ram $(free -m | awk '/Mem:/ {printf $3}')" >> $my_path
    echo "total_capacity $(( $(df / | tail -n 1 | awk '{print $2}') / 1024 / 1024 ))" >> $my_path
    echo "used_capacity $(( $(df / | tail -n 1 | awk '{print $3}') / 1024 / 1024 ))" >> $my_path

    sleep 3
done 

