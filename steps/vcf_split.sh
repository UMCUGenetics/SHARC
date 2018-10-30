#!/bin/bash

usage() {
echo "
Required parameters:
    -v|--vcf		Path to vcf file

Optional parameters:
    -h|--help     Shows help
    -l|--lines		Number of lines per split [$LINES]
    -o|--outputdir  Path to output directory [$OUTPUTDIR]
"
}

POSITIONAL=()

# DEFAULTS
LINES=100
OUTPUTDIR=./tmp

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
    -l|--lines)
    LINES="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--outputdir)
    OUTPUTDIR="$2"
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

HEADER=$(grep "^#" $VCF)
AWK="grep -v \"^#\" $VCF | awk -v HEADER=\"\$HEADER\" 'NR%$LINES==1 { file = \"$OUTPUTDIR/\" int(NR/$LINES)+1 \".vcf\"; print HEADER > file } { print > file }'"
eval $AWK

echo `date`: Done
