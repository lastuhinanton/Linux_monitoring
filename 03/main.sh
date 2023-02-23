#!/bin/bash

. ../module.sh

# bash ../02/main.sh abc abc.exe 1

setCodes
startCalculateTime

selectOption

isCorrect=$(validateOption 1 3 $option)
[[ $isCorrect -eq $RIGHT ]] && preExecutingProcess $option
[[ $isCorrect -eq $RIGHT ]] && ExecutingProcess $option

endCalculateTime
