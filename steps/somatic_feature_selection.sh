#!/bin/bash

usage() {
echo "
Required parameters:
    -v|--vcf		    Path to vcf file
    -c|--cancer_type  Cancer type examined
    -a|--attributes_output  Output for feature table

Optional parameters:
    -h|--help       Shows help
    -s|--script     Path to vcf_primer_filter.py [$SCRIPT]
    -o|--output     VCF output file [$OUTPUT]
    -f|--flank      Added region around BND to compare to genes [$FLANK]
    -id|--icgc_database_directory   Directory containing ICGC files for genes in cancer types[$ICGC_DATABASE_DIRECTORY]
    -cb|--cosmic_breakpoints  COSMIC .csv containing known breakpoints for a specific cancer type [$COSMIC_BREAKPOINTS]
    -p|--support    Minimal fraction of patients needed to annotate as cancer gene [$SUPPORT]
    -e|--venv       Path to virtual environment[$VENV]
"
}

POSITIONAL=()

#DEFAULT
SCRIPT="/hpc/cog_bioinf/kloosterman/common_scripts/sharc/scripts/somatic_feature_selection.py"
OUTPUT="/dev/stdout"
ICGC_DATABASE_DIRECTORY="/hpc/cog_bioinf/kloosterman/common_scripts/sharc/files/"
COSMIC_BREAKPOINTS=None
SUPPORT=None
FLANK=200
VENV='/hpc/cog_bioinf/kloosterman/common_scripts/sharc/venv/bin/activate'

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
    -c|--cancer_type)
    TYPE="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--attributes_output)
    ATTRIBUTES_OUTPUT="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--script)
    SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--flank)
    FLANK="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--support)
    SUPPORT="$2"
    shift # past argument
    shift # past value
    ;;
    -id|--icgc_database_directory)
    ICGC_DATABASE_DIRECTORY="$2"
    shift # past argument
    shift # past value
    ;;
    -cb|--cosmic_breakpoints)
    COSMIC_BREAKPOINTS="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--venv)
    VENV="$2"
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
elif [ -z $TYPE ]; then
    echo "Missing -c|--cancer_type parameter"
    usage
    exit

elif [ -z $ATTRIBUTES_OUTPUT ]; then
    echo "Missing -a|--attributes_output"
    usage
    exit
fi

echo `date`: Running on `uname -n`

. $VENV

if [ $SUPPORT == None ];then
  python $SCRIPT -c $TYPE -a $ATTRIBUTES_OUTPUT -f $FLANK -id $ICGC_DATABASE_DIRECTORY -cb $COSMIC_BREAKPOINTS -o $OUTPUT $VCF
elif [ $COSMIC_BREAKPOINTS == None ];then
  python $SCRIPT -c $TYPE -a $ATTRIBUTES_OUTPUT -f $FLANK -s $SUPPORT -id $ICGC_DATABASE_DIRECTORY -o $OUTPUT $VCF
elif [ $SUPPORT == None ] && [ $COSMIC_BREAKPOINTS == None ];then
  python $SCRIPT -c $TYPE -a $ATTRIBUTES_OUTPUT -f $FLANK -id $ICGC_DATABASE_DIRECTORY -o $OUTPUT $VCF
else
  python $SCRIPT -c $TYPE -a $ATTRIBUTES_OUTPUT -f $FLANK -s $SUPPORT -id $ICGC_DATABASE_DIRECTORY -cb $COSMIC_BREAKPOINTS -o $OUTPUT $VCF

echo `date`: Done
