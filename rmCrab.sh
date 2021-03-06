#!/bin/bash
# Crabjob Management Script v1.60

if [ -a TaskInfo.CMS ]; then
    crab -get all
    crab -clean
    RH=$(sed -n 's/Remote Host://p' TaskInfo.CMS)
    TN=$(sed -n 's/TaskName://p' TaskInfo.CMS)
    gsissh $RH rm -rf ./$TN
fi

rm -rf nohup.out
rm -rf ./log
rm -rf ./*.log
rm -rf ./*.CMS
rm -rf crab_*
rm -rf crab.history
