#!/bin/bash
unset premisinsert
while getopts ":i:I:T:d:D:E:N:l:L:r:s:S:o:O:" opt; do
    case $opt in
        i)
            eventIdentifierType="$OPTARG"
            ;;
        I)
            eventIdentifierValue="$OPTARG"
            ;;
        T)
            eventType="$OPTARG"
            ;;
        d)
            eventDateTime="$OPTARG"
            if [ "$eventDateTime" = "now" ] ; then
                eventDateTime=`date "+%Y-%m-%dT%H:%M:%S"`
            fi
            ;;
        D)
            eventDetail="$OPTARG"
            ;;
        E)
            eventOutcome="$OPTARG"
            ;;
        N)
            eventOutcomeDetailNote="$OPTARG"
            ;;
        l)
            linkingAgentIdentifierType="$OPTARG"
            ;;
        L)
            linkingAgentIdentifierValue="$OPTARG"
            ;;
        r)
            linkingAgentRole="$OPTARG"
            ;;
        s)
            sourceLinkingObjectIdentifierType="$OPTARG"
            ;;
        S)
            sourceLinkingObjectIdentifierValue="$OPTARG"
            ;;
        o)
            outcomeLinkingObjectIdentifierType="$OPTARG"
            ;;
        O)
            outcomeLinkingObjectIdentifierValue="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done
shift $(( ${OPTIND} - 1 ))
xmlfile="$1"
if [ "${xmlfile#*.}" != "xml" ] ; then
    echo "An xml input must be provided."
    exit 2
fi
if [ ! -f "${xmlfile}" ] ; then
    echo "${xmlfile} does not appear to be a file."
    exit 3
fi

for requiredargument in \
    eventIdentifierType \
    eventIdentifierValue \
    eventType \
    eventDateTime ;
do
    if [ -z "${!requiredargument}" ] ; then
        echo "${requiredargument} is set to \"${!requiredargument}\""
        echo The mandatory arguments are not set.
        exit 4
    fi
done

