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

while getopts ":i:I:n:T:N:l:L:" opt; do
    case $opt in
        i)  agentIdentifierType="$OPTARG" ;;
        I)  agentIdentifierValue="$OPTARG" >&2 ;;
        n)  agentName="$OPTARG" ;;
        T)  agentType="$OPTARG" ;;
        N)  agentNote="$OPTARG" ;;
        l)  linkingEventIdentifierType="$OPTARG" ;;
        L)  linkingEventIdentifierValue="$OPTARG" ;;
        \?) echo "Invalid option: -$OPTARG" ; exit 1 ;;
        :)  echo "Option -$OPTARG requires an argument." ; exit 1 ;;
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

if [ -n "${agentIdentifierType}" -o -n "${agentIdentifierValue}" ] ; then
    premisinsert+=(-s "/P:premis/agent[last()]" -t elem -n "agentIdentifier")
fi
if [ -n "${agentIdentifierType}" ] ; then
    premisinsert+=(-s "/P:premis/agent[last()]/agentIdentifier[last()]" -t elem -n "agentIdentifierType" -v "$agentIdentifierType")
fi
if [ -n "${agentIdentifierValue}" ] ; then
    premisinsert+=(-s "/P:premis/agent[last()]/agentIdentifier[last()]" -t elem -n "agentIdentifierValue" -v "$agentIdentifierValue")
fi
if [ -n "${agentName}" ] ; then
    premisinsert+=(-s "/P:premis/agent[last()]" -t elem -n "agentName" -v "$agentName")
fi
if [ -n "${agentType}" ] ; then
    premisinsert+=(-s "/P:premis/agent[last()]" -t elem -n "agentType" -v "$agentType")
fi
if [ -n "${agentNote}" ] ; then
    premisinsert+=(-s "/P:premis/agent[last()]" -t elem -n "agentNote" -v "$agentNote")
fi
if [ -n "${linkingEventIdentifierType}" -o -n "${linkingEventIdentifierValue}" ] ; then
    premisinsert+=(-s "/P:premis/agent[last()]" -t elem -n "linkingEventIdentifier")
fi
if [ -n "${linkingEventIdentifierType}" ] ; then
    premisinsert+=(-s "/P:premis/agent[last()]/linkingEventIdentifier[last()]" -t elem -n "linkingEventIdentifierType" -v "$linkingEventIdentifierType")
fi
if [ -n "${linkingEventIdentifierValue}" ] ; then
    premisinsert+=(-s "/P:premis/agent[last()]/linkingEventIdentifier[last()]" -t elem -n "linkingEventIdentifierValue" -v "$linkingEventIdentifierValue")
fi

xml ed -L -N P="info:lc/xmlns/premis-v2" -a "(/P:premis/P:agent|P:event)[last()]" -t elem -n "agent" "${premisinsert[@]}" "$xmlfile"
