#!/bin/bash

usage() {
echo "
Required parameters:
    -b|--bam		      Path to bam file

Optional parameters:
    -h|--help		      Shows help
    -bed|--bed_file	  Path to bed file [$MINIMAP2]
    -t|--threads	    Number of threads [$THREADS]
    -p|--parameters   Sambamba depth parameters [$SETTINGS]
    -s|--sambamba	    Path to sambamba [$SAMBAMBA]
    -o|--output		    Path to coverage output file [$OUTPUT]
"
}

POSITIONAL=()

# DEFAULTS
THREADS=1
BED='/hpc/cog_bioinf/cuppen/project_data/Jose_SHARC/sharc/files/human_hg19.bed'
SAMBAMBA='/hpc/local/CentOS7/cog_bioinf/sambamba_v0.6.5/sambamba'
OUTPUT='/dev/stdout'
SETTINGS='base --min-coverage=0'

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
    -h|--help)
    usage
    shift # past argument
    ;;
    -b|--bam)
    BAM="$2"
    shift # past argument
    shift # past value
    ;;
    -bed|--bed_file)
    BED="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--threads)
    THREADS="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--parameters)
    SETTINGS="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--sambamba)
    SAMBAMBA="$2"
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
if [ -z $BAM ]; then
    echo "Missing -b|--bam parameter"
    usage
    exit
fi

echo `date`: Running on `uname -n`

$SAMBAMBA depth $SETTINGS -t $THREADS -L $BED $BAM > $OUTPUT
awk '{ if (NR!=1) total += $3 } END { print "#MEAN COVERAGE="total/(NR-1) }' $OUTPUT | cat - $OUTPUT > temp && mv temp $OUTPUT

echo `date`: Done
