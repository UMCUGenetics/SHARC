#!/bin/bash

usage() {
echo "
Required parameters:
    -v|--vcf		Path to vcf file
    -b|--bed		Path to feature bed file
    
Optional parameters:
    -h|--help		Shows help
    -s|--script		Path to python script [$SCRIPT]
    -o|--output		Path to vcf output file [$OUTPUT]
"
}

POSITIONAL=()

# DEFAULTS
SCRIPT='/hpc/cog_bioinf/kloosterman/common_scripts/sharc/scripts/get_closest_feature.py'
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
    -b|--bed)
    BED="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--script)
    SCRIPT="$2"
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
elif [ -z $BED ]; then
    echo "Missing -b|--bed parameter"
    usage
    exit

fi

echo `date`: Running on `uname -n`

grep '^#' $VCF > $OUTPUT
python $SCRIPT $BED $VCF >> $OUTPUT

if [ -e $OUTPUT ]; then
    NUMBER_OF_LINES_IN_VCF=$(wc -l $VCF | grep -oP "(\d+)")
    NUMBER_OF_LINES_IN_SPLIT=$(wc -l $OUTPUT | grep -oP "(\d+)")
    if [ "$NUMBER_OF_LINES_IN_VCF" == "$NUMBER_OF_LINES_IN_SPLIT" ]; then
        touch $OUTPUT.done
    fi
fi

echo `date`: Done
