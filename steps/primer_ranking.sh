#! /bin/bash

usage() {
echo "
Required parameters:
    -v|--vcf		    Path to vcf file
    -p|--primers    Path to primers file

Optional parameters:
    -h|--help       Shows help
    -s|--script     Path to rank_primers.py [$SCRIPT]
    -o|--output     Primers output file [$OUTPUT]
    -e|--venv       Path to virtual environment[$VENV]
"
}

POSITIONAL=()

#DEFAULT

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

if [ -z $PRIMERS ]; then
    echo "Missing -p|--primers parameter"
    usage
    exit
fi

echo `date`: Running on `uname -n`

. $VENV

python $SCRIPT -v $VCF -p $PRIMERS -o $OUTPUT
