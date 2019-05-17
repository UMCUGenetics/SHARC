#! /bin/bash

usage() {
echo "
Required parameters:
    -v|--vcf		    Path to vcf file
    -f|--FEATURES   Path to vcf features file

Optional parameters:
    -h|--help       Shows help
    -s|--script     Path to vcf_primer_filter.py [$SCRIPT]
    -o|--output     VCF output file [$OUTPUT]
    -e|--venv       Path to virtual environment[$VENV]
"
}

POSITIONAL=()

#DEFAULT
SCRIPT="/hpc/cog_bioinf/cuppen/project_data/Jose_SHARC/sharc/scripts/vcf_rank_somatic.py"
VENV='/hpc/cog_bioinf/cuppen/project_data/Jose_SHARC/sharc/venv/bin/activate'
OUTPUT="/dev/stdout"

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
    -s|--script)
    SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--venv)
    VENV="$2"
    shift # past argument
    shift # past value
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

python $SCRIPT -v $VCF -o $OUTPUT

echo `date`: Done
