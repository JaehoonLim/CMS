#!/bin/bash
# Crabjob Management Script v1.30

crab -clean
rm -rf nohup.out
rm -rf ./log
rm -rf ./*.log
rm -rf ./*.CMS
rm -rf crab_*
rm -rf crab.history