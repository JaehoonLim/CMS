#!/bin/bash
# Crabjob Management Script v1.60

if [ -a TaskInfo.CMS ]; then
    RH=$(sed -n 's/Remote Host://p' TaskInfo.CMS)
    TN=$(sed -n 's/TaskName://p' TaskInfo.CMS)
    gsissh -t $RH "cd $TN;exec /bin/bash"
fi
