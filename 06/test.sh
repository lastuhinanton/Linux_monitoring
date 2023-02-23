#!/bin/bash

while read line; do
    echo $line >> 2_day.log
    sleep 1
done < 1_day.log