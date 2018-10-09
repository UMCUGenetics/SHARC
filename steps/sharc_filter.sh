#!/bin/bash

usage() {
echo "
Required parameters:
    -v|--vcf		Path to vcf file

Optional parameters:
    -h|--help		Shows help
    -f|--filter		Filter query [$FILTER]
    -o|--output		Path to vcf output file [$OUTPUT]
"
}

POSITIONAL=()

# DEFAULTS
THREADS=1
FILTER='grep "PREDICT_LABEL=1" | grep -v "SHARCDBFILTER" | grep -v "REFDBFILTER"'
OUTPUT='/dev/stdout'

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
    -h|--help)
    usage
    shift # past argument
    ;;
    -v|--vcf)
    VCF="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--filter)
    FILTER="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--output)
    OUTPUT="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
if [ -z $VCF ]; then
    echo "Missing -v|--vcf parameter"
    usage
    exit
fi

echo `date`: Running on `uname -n`

grep "^#" $VCF > $OUTPUT
AWK="grep -v \"^#\" $VCF | $FILTER >> $OUTPUT"
eval $AWK

echo `date`: Done
