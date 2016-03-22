#!/bin/bash
# Crabjob Management Script v1.60

source ./cmsHEADER

if [ "$#" -gt 1 ]; then
    echo "ERROR : Argument" 1>&2
    exit
fi

clear
echo ""
echo " CMS  : Crabjob Management Scrpit start"
echo ""
echo -n "PASSWD: Input your voms password : " 1>&2
stty -echo
read MyPass
stty echo
echo -e "\t" 1>&2

CheckPass $MyPass
if [ -a TaskInfo.CMS ]; then
    :
else
    CrabStatus $MyPass log.CMS
    rm -rf log.CMS
fi

STARTPOINT=0
ENDPOINT=0
TJ=$(sed -n 's/Total jobs://p' TaskInfo.CMS)
IJ_old=$(sed -n 's/Submit at once://p' TaskInfo.CMS)
STARTPOINT_old=0
ENDPOINT_old=$(sed -n 's/Submitted jobs://p' TaskInfo.CMS)

if [ $IJ_old ]; then
    :
else
    IJ_old=0
fi

if [ "$#" -eq 0 ]; then
    if [ "$IJ_old" -gt 0 ]; then
	IJ=$IJ_old
    else
	IJ=$TJ
    fi
else
    if [ "$1" = "all" ]; then
	IJ=$TJ
    else
	IJ=$1
    fi
fi

if [ "$TJ" -lt "$IJ" ]; then
    IJ=$TJ
fi

if [ "$ENDPOINT_old" ]; then
    if [ "$ENDPOINT_old" -ne "$TJ" ]; then
        STARTPOINT_old=$((ENDPOINT_old-IJ_old+1))
    else
        while [ "$STARTPOINT_old" -lt "$TJ" ]; do
            STARTPOINT_old=$((STARTPOINT_old+IJ_old))
        done
        STARTPOINT_old=$((STARTPOINT_old-IJ_old+1))
        IJ_old=$((ENDPOINT_old-STARTPOINT_old+1))
    fi
else
    IJ_old=0
    STARTPOINT_old=0
    ENDPOINT_old=0
fi

if [ "$STARTPOINT_old" -lt 0 ]; then
    STARTPOINT_old=1
    IJ_old=$((ENDPOINT_old))
fi

echo "" 1>&2
echo -e "STATUS: Total job      : $TJ" 1>&2
echo -e "STATUS: Submit at once : $IJ" 1>&2
echo -e "STATUS: Previous jobs  : $STARTPOINT_old-$ENDPOINT_old ($IJ_old jobs)" 1>&2
echo "" 1>&2
echo "DANGER: Do not Ctrl+c between status 'START' and status 'END'" 1>&2
echo "DANGER: Do not remove 'TaskInfo.CMS'" 1>&2
echo -n "CHECK : Press 'Enter' to continue (or Ctrl+c to exit)" 1>&2
stty -echo
read DangerCheck
stty echo
echo -e "\t" 1>&2

sed -e '/Submit at once:/d' TaskInfo.CMS > TaskInfo.temp
rm -rf TaskInfo.CMS
mv TaskInfo.temp TaskInfo.CMS
echo -e "Submit at once:$IJ" >> TaskInfo.CMS

BigDIV=$((TJ/IJ))
BigMOD=$((TJ%IJ))
BigDIVIndex=0

SmallDIV=$((IJ/500))
SmallMOD=$((IJ%500))
SmallDIVIndex=0

    while [ "$BigDIVIndex" -lt "$BigDIV" ]; do
	if [ "$IJ" -gt 500 ]; then
	    while [ "$SmallDIVIndex" -lt "$SmallDIV" ]; do
		ENDPOINT=$((ENDPOINT+500))
		STARTPOINT=$((ENDPOINT-499))
		SmallDIVIndex=$((SmallDIVIndex+1))
		CrabSubmit $ENDPOINT_old $STARTPOINT $ENDPOINT $MyPass
	    done
	    SmallDIVIndex=0
	    if [ "$SmallMOD" -ne 0 ]; then
		ENDPOINT=$((ENDPOINT+SmallMOD))
		STARTPOINT=$((ENDPOINT-SmallMOD+1))
		CrabSubmit $ENDPOINT_old $STARTPOINT $ENDPOINT $MyPass
	    fi
	    CrabResubmit $STARTPOINT_old $ENDPOINT_old $ENDPOINT $MyPass
	    CrabGetoutput $STARTPOINT_old $ENDPOINT_old $((ENDPOINT-IJ+1)) $ENDPOINT $MyPass
	    if [ "$STARTPOINT_old" -lt "$ENDPOINT" ]; then
		STARTPOINT_old=$((ENDPOINT_old+1))
	    fi
	else
	    ENDPOINT=$((ENDPOINT+IJ))
	    STARTPOINT=$((ENDPOINT-IJ+1))
	    CrabSubmit $ENDPOINT_old $STARTPOINT $ENDPOINT $MyPass
	    CrabResubmit $STARTPOINT_old $ENDPOINT_old $ENDPOINT $MyPass
	    CrabGetoutput $STARTPOINT_old $ENDPOINT_old $((ENDPOINT-IJ+1)) $ENDPOINT $MyPass
	    if [ "$STARTPOINT_old" -lt "$ENDPOINT" ]; then
		STARTPOINT_old=$((ENDPOINT_old+1))
	    fi
	fi
	BigDIVIndex=$((BigDIVIndex+1))

    done

    if [ "$BigMOD" -gt 500 ]; then

	SmallDIV=$((BigMOD/500))
	SmallMOD=$((BigMOD%500))
	SmallDIVIndex=0
	while [ "$SmallDIVIndex" -lt "$SmallDIV" ]; do
	    ENDPOINT=$((ENDPOINT+500))
	    STARTPOINT=$((ENDPOINT-499))
	    SmallDIVIndex=$((SmallDIVIndex+1))
	    CrabSubmit $ENDPOINT_old $STARTPOINT $ENDPOINT $MyPass
	done
	SmallDIVIndex=0
	if [ "$SmallMOD" -ne 0 ]; then
	    ENDPOINT=$((ENDPOINT+SmallMOD))
	    STARTPOINT=$((ENDPOINT-SmallMOD+1))
	    CrabSubmit $ENDPOINT_old $STARTPOINT $ENDPOINT $MyPass
	fi
	CrabResubmit $STARTPOINT_old $ENDPOINT_old $ENDPOINT $MyPass
	CrabGetoutput $STARTPOINT_old $ENDPOINT_old $((ENDPOINT-BigMOD+1)) $ENDPOINT $MyPass
	if [ "$STARTPOINT_old" -lt "$ENDPOINT" ]; then
	    STARTPOINT_old=$((ENDPOINT_old+1))
	fi

    else

	if [ "$BigMOD" -ne 0 ]; then
	    ENDPOINT=$((ENDPOINT+BigMOD))
	    STARTPOINT=$((ENDPOINT-BigMOD+1))
	    CrabSubmit $ENDPOINT_old $STARTPOINT $ENDPOINT $MyPass
	    CrabResubmit $STARTPOINT_old $ENDPOINT_old $ENDPOINT $MyPass
	    CrabGetoutput $STARTPOINT_old $ENDPOINT_old $((ENDPOINT-BigMOD+1)) $ENDPOINT $MyPass
	    if [ "$STARTPOINT_old" -lt "$ENDPOINT" ]; then
		STARTPOINT_old=$((ENDPOINT_old+1))
	    fi
	fi

    fi

echo ""
echo " CMS  : Crabjob Management Scrpit end"
echo ""
