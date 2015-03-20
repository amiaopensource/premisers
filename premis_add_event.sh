#!/bin/bash
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

xml ed -L -N P="info:lc/xmlns/premis-v2" \
-a "(/P:premis/P:event|P:object)[last()]" -t elem -n "event" -v "" \
-s "/P:premis/event[last()]" -t elem -n "eventIdentifier" -v "" \
-s "/P:premis/event[last()]/eventIdentifier[last()]" -t elem -n "eventIdentifierType" -v "$eventIdentifierType" \
-s "/P:premis/event[last()]/eventIdentifier[last()]" -t elem -n "eventIdentifierValue" -v "$eventIdentifierValue" \
-s "/P:premis/event[last()]" -t elem -n "eventType" -v "$eventType" \
-s "/P:premis/event[last()]" -t elem -n "eventDateTime" -v "$eventDateTime" \
-s "/P:premis/event[last()]" -t elem -n "eventDetail" -v "$eventDetail" \
-s "/P:premis/event[last()]" -t elem -n "eventOutcomeInformation" -v "" \
-s "/P:premis/event[last()]/eventOutcomeInformation[last()]" -t elem -n "eventOutcome" -v "$eventOutcome" \
-s "/P:premis/event[last()]/eventOutcomeInformation[last()]" -t elem -n "eventOutcomeDetail" -v "" \
-s "/P:premis/event[last()]/eventOutcomeInformation[last()]/eventOutcomeDetail[last()]" -t elem -n "eventOutcomeDetailNote" -v "$eventOutcomeDetailNote" \
-s "/P:premis/event[last()]" -t elem -n "linkingAgentIdentifier" -v "" \
-s "/P:premis/event[last()]/linkingAgentIdentifier[last()]" -t elem -n "linkingAgentIdentifierType" -v "$linkingAgentIdentifierType" \
-s "/P:premis/event[last()]/linkingAgentIdentifier[last()]" -t elem -n "linkingAgentIdentifierValue" -v "$linkingAgentIdentifierValue" \
-s "/P:premis/event[last()]/linkingAgentIdentifier[last()]" -t elem -n "linkingAgentRole" -v "$linkingAgentRole" \
-s "/P:premis/event[last()]" -t elem -n "linkingObjectIdentifier" -v "" \
-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectIdentifierType" -v "$sourceLinkingObjectIdentifierType" \
-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectIdentifierValue" -v "$sourceLinkingObjectIdentifierValue" \
-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectRole" -v "source" \
-s "/P:premis/event[last()]" -t elem -n "linkingObjectIdentifier" -v "" \
-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectIdentifierType" -v "$outcomeLinkingObjectIdentifierType" \
-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectIdentifierValue" -v "$outcomeLinkingObjectIdentifierValue" \
-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectRole" -v "outcome" \
"$xmlfile"
