#!/bin/bash

goaccess ./1_day.log ./2_day.log ./3_day.log ./4_day.log ./5_day.log \
        -o report.html \
        --log-format='%h %^[%d:%t %^] "%r" %s %b "%R" "%u"' \
        --date-format=%d/%b/%Y \
        --time-format=%T
