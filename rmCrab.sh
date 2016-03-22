#!/bin/bash
# Crabjob Management Script v1.50

if [ -a TaskInfo.CMS ]; then
    RH=$(sed -n 's/Remote Host://p' TaskInfo.CMS)
    TN=$(sed -n 's/TaskName://p' TaskInfo.CMS)
    gsissh $RH rm -rf ./$TN
fi

crab -clean
rm -rf nohup.out
rm -rf ./log
rm -rf ./*.log
rm -rf ./*.CMS
rm -rf crab_*
rm -rf crab.history
