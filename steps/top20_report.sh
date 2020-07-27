#! /bin/bash

usage() {
echo "
Required parameters:
    -v|--vcf		    Path to vcf file
    -p|--primers    Path to primers file
    -ov|--outvcf     VCF output file [$OUTVCF]
    -ot|--outtsv     Table output file [$OUTTSV]

Optional parameters:
    -h|--help       Shows help
    -s|--script     Path to rank_primers.py [$SCRIPT]
    -e|--venv       Path to virtual environment[$VENV]
"
}

POSITIONAL=()

#DEFAULT
SCRIPT="/hpc/cog_bioinf/cuppen/project_data/Jose_SHARC/sharc/scripts/top20_report.py"
VENV='/hpc/cog_bioinf/cuppen/project_data/Jose_SHARC/sharc/venv/bin/activate'


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
    -p|--primers)
    PRIMERS="$2"
    shift # past argument
    shift # past value
    ;;
    -ov|--outvcf)
    OUTVCF="$2"
    shift # past argument
    shift # past value
    ;;
    -ot|--outtsv)
    OUTTSV="$2"
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

if [ -z $PRIMERS ]; then
    echo "Missing -p|--primers parameter"
    usage
    exit
fi

if [ -z $OUTVCF ]; then
    echo "Missing -ov|--outvcf parameter"
    usage
    exit
fi

if [ -z $OUTTSV ]; then
    echo "Missing -ot|--outtsv parameter"
    usage
    exit
fi

echo `date`: Running on `uname -n`

. $VENV

python $SCRIPT $VCF $PRIMERS $OUTVCF $OUTTSV
