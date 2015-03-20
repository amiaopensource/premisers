#!/bin/bash
unset premisinsert
version=0.1
dependencies=(xml)

# check_dependencies(){
for i in "${dependencies[@]}" ; do
    if [ ! $(which "$i") ] ; then
        echo This script requires "${i}."
        echo hi "$i"
        exit 1
    fi
done

usage(){
echo
echo "$(basename ${0}) ${version}"
echo "This script will add an event to an existing PREMIS XML. It is tested with PREMIS version 2.0."
echo "Dependencies: ${dependencies[@]}"
echo "Usage: $(basename $0) -i eventIDType -I eventIDValue -T eventType -d datetime [ other options ] premis.xml"
echo " -i ( eventIdentifierType )"
echo " -I ( eventIdentifierValue )"
echo " -T ( eventType )"
echo " -d ( eventDateTime [ enter now to express the run time system timestamp ] )"
echo " -D ( eventDetail )"
echo " -E ( eventOutcome )"
echo " -N ( eventOutcomeDetailNote )"
echo " -l ( linkingAgentIdentifierType )"
echo " -L ( linkingAgentIdentifierValue )"
echo " -s ( sourceLinkingObjectIdentifierType )"
echo " -S ( sourceLinkingObjectIdentifierValue )"
echo " -o ( outcomeLinkingObjectIdentifierType )"
echo " -O ( outcomeLinkingObjectIdentifierValue )"
echo " -h ( display this help )"
echo ""
echo "Examples:"
echo "$(basename $0) -i "Local Event Identification Sytem" -I u812 -T contemplation -d now premis.xml"
echo
exit
}

while getopts ":i:I:T:d:D:E:N:l:L:r:s:S:o:O:h" opt; do
    case $opt in
        i)  eventIdentifierType="$OPTARG" ;;
        I)  eventIdentifierValue="$OPTARG" ;;
        T)  eventType="$OPTARG" ;;
        d)  eventDateTime="$OPTARG"
            if [ "$eventDateTime" = "now" ] ; then
                eventDateTime=`date "+%Y-%m-%dT%H:%M:%S"`
            fi;;
        D)  eventDetail="$OPTARG" ;;
        E)  eventOutcome="$OPTARG" ;;
        N)  eventOutcomeDetailNote="$OPTARG" ;;
        l)  linkingAgentIdentifierType="$OPTARG" ;;
        L)  linkingAgentIdentifierValue="$OPTARG" ;;
        r)  linkingAgentRole="$OPTARG" ;;
        s)  sourceLinkingObjectIdentifierType="$OPTARG" ;;
        S)  sourceLinkingObjectIdentifierValue="$OPTARG" ;;
        o)  outcomeLinkingObjectIdentifierType="$OPTARG" ;;
        O)  outcomeLinkingObjectIdentifierValue="$OPTARG" ;;
        h)  usage ;;
        \?) echo "Invalid option: -$OPTARG" ; usage ;;
        :)  echo "Option -$OPTARG requires an argument." ; usage ;;
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
if [ -n "${eventIdentifierType}" -o -n "${eventIdentifierValue}" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]" -t elem -n "eventIdentifier")
fi
if [ -n "${eventIdentifierType}" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]/eventIdentifier[last()]" -t elem -n "eventIdentifierType" -v "$eventIdentifierType")
fi
if [ -n "${eventIdentifierValue}" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]/eventIdentifier[last()]" -t elem -n "eventIdentifierValue" -v "$eventIdentifierValue")
fi
if [ -n "${eventType}" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]" -t elem -n "eventType" -v "$eventType")
fi
if [ -n "${eventDateTime}" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]" -t elem -n "eventDateTime" -v "$eventDateTime")
fi
if [ -n "${eventDetail}" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]" -t elem -n "eventDetail" -v "$eventDetail")
fi
if [ -n "${eventOutcome}" -o -n "${eventOutcomeDetailNode}" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]" -t elem -n "eventOutcomeInformation")
fi
if [ -n "${eventOutcome}" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]/eventOutcomeInformation[last()]" -t elem -n "eventOutcome" -v "$eventOutcome")
fi
if [ -n "${eventOutcomeDetailNote}" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]/eventOutcomeInformation[last()]" -t elem -n "eventOutcomeDetail")
    premisinsert+=(-s "/P:premis/event[last()]/eventOutcomeInformation[last()]/eventOutcomeDetail[last()]" -t elem -n "eventOutcomeDetailNote" -v "$eventOutcomeDetailNote")
fi
if [ -n "$linkingAgentIdentifierType" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]" -t elem -n "linkingAgentIdentifier")
    premisinsert+=(-s "/P:premis/event[last()]/linkingAgentIdentifier[last()]" -t elem -n "linkingAgentIdentifierType" -v "$linkingAgentIdentifierType")
fi
if [ -n "$linkingAgentIdentifierValue" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]/linkingAgentIdentifier[last()]" -t elem -n "linkingAgentIdentifierValue" -v "$linkingAgentIdentifierValue")
fi
if [ -n "$linkingAgentRole" ] ; then
    premisinsert+=(-s "/P:premis/event[last()]/linkingAgentIdentifier[last()]" -t elem -n "linkingAgentRole" -v "$linkingAgentRole")
fi
if [ -n "$sourceLinkingObjectIdentifierType" -a -n "$sourceLinkingObjectIdentifierType" ] ; then
    if [ -n "$sourceLinkingObjectIdentifierType" ] ; then
        premisinsert+=(-s "/P:premis/event[last()]" -t elem -n "linkingObjectIdentifier")
        premisinsert+=(-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectIdentifierType" -v "$sourceLinkingObjectIdentifierType")
    fi
    if [ -n "$sourceLinkingObjectIdentifierValue" ] ; then
        premisinsert+=(-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectIdentifierValue" -v "$sourceLinkingObjectIdentifierValue")
        premisinsert+=(-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectRole" -v "source")
    fi
fi
if [ -n "$outcomeLinkingObjectIdentifierType" -a -n "$sourceLinkingObjectIdentifierType" ] ; then
    if [ -n "$outcomeLinkingObjectIdentifierType" ] ; then
        premisinsert+=(-s "/P:premis/event[last()]" -t elem -n "linkingObjectIdentifier")
        premisinsert+=(-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectIdentifierType" -v "$outcomeLinkingObjectIdentifierType")
    fi
    if [ -n "$outcomeLinkingObjectIdentifierValue" ] ; then
        premisinsert+=(-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectIdentifierValue" -v "$outcomeLinkingObjectIdentifierValue")
        premisinsert+=(-s "/P:premis/event[last()]/linkingObjectIdentifier[last()]" -t elem -n "linkingObjectRole" -v "outcome")
    fi
fi

xml ed -L -N P="info:lc/xmlns/premis-v2" -a "(/P:premis/P:event|P:object)[last()]" -t elem -n "event" "${premisinsert[@]}" "$xmlfile"
