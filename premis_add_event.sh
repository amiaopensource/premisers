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
echo
exit
}

while getopts ":i:I:T:d:D:E:N:l:L:r:s:S:o:O:h" opt; do
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
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            usage
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

