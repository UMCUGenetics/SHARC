#!/bin/bash

usage() {
echo "
Required parameters:
    -v|--vcf		Path to vcf file

Optional parameters:
    -h|--help		Shows help
    -o|--output		Path to vcf output file [$OUTPUT]
    -e|--venv Path to virtual env [$VENV]
    -f|--flank  Flank to increase filter search space [$FLANK]
    -n|--name   Filter name [$NAME]
    -db|--db_script  Path to vcfexplorer.py [$DB_SCRIPT]
"
}

POSITIONAL=()

# DEFAULTS
VENV='/hpc/cog_bioinf/kloosterman/users/mroosmalen/vcf-explorer/vcf-explorer/env/bin/activate'
DB_SCRIPT='/hpc/cog_bioinf/kloosterman/users/mroosmalen/vcf-explorer/vcf-explorer/vcfexplorer.py'
NAME='DBFILTER'
FLANK=10
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
    -o|--output)
    OUTPUT="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--flank)
    FLANK="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--venv)
    VENV="$2"
    shift # past argument
    shift # past value
    ;;
    -db|--db_script)
    DB_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--name)
    NAME="$2"
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

. $VENV

python $DB_SCRIPT filter -n $NAME -f $FLANK $VCF > $OUTPUT

deactivate

echo `date`: Done
