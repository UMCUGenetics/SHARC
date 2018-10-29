#!/bin/bash

usage() {
echo "
Required parameters:
    -v|--vcf		    Path to vcf file
    -c|--cancer_type  Cancer type examined

Optional parameters:
    -h|--help       Shows help
    -s|--script     Path to vcf_primer_filter.py [$SCRIPT]
    -o|--output     VCF output file [$OUTPUT]
    -f|--flank      Added region around BND to compare to genes [$FLANK]
    -p|--support    Minimal fraction of patients needed to annotate as cancer gene [$SUPPORT]
"
}

POSITIONAL=()

#DEFAULT
SCRIPT="/hpc/cog_bioinf/kloosterman/common_scripts/sharc/scripts/gene_annotation_ICGC.py"
OUTPUT="/dev/stdout"
FLANK=200
SUPPORT=0.05

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
fi

echo `date`: Running on `uname -n`

##### I USED PYTHON 3.6.1 ... NOT SURE IF IT WORKS ON PYTHON 2

#module load python 3.6.1
python $SCRIPT -c $TYPE -f $FLANK -s $SUPPORT -o $OUTPUT $VCF
#module load python 2
