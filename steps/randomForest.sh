#!/bin/bash

usage() {
echo "
Required parameters:
    -v|--vcf		Path to vcf file
    -m|--meancov		Mean coverage

Optional parameters:
    -h|--help		Shows help
    -o|--output		Path to vcf output file [$OUTPUT]
    -d|--outdir		Path to output directory [$OUTDIR]
    -e|--venv   Path to virtual env of NanoSV [$VENV]
    -ft|--ft_script Path to create_features_table.pl script [$CREATE_FEATURE_TABLE_SCRIPT]
    -rf|--rf_script Path to run_randomForest.R script [$RANDOM_FOREST_SCRIPT]
    -ap|--ap_script Path to add_predict_annotation.py script [$ADD_PREDICT_SCRIPT]
"
}

POSITIONAL=()

# DEFAULTS
CREATE_FEATURE_TABLE_SCRIPT='/hpc/cog_bioinf/kloosterman/common_scripts/sharc/scripts/create_features_table.py'
RANDOM_FOREST_SCRIPT='/hpc/cog_bioinf/kloosterman/common_scripts/sharc/scripts/run_randomForest.R'
ADD_PREDICT_SCRIPT='/hpc/cog_bioinf/kloosterman/common_scripts/sharc/scripts/add_predict_annotation.py'
OUTPUT='/dev/stdout'
OUTDIR='./'
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
    -m|--meancov)
    MEANCOV="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--outdir)
    OUTDIR="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--output)
    OUTPUT="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--venv)
    VENV="$2"
    shift # past argument
    shift # past value
    ;;
    -ft|--ft_scripts)
    CREATE_FEATURE_TABLE_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
    -rf|--rf_script)
    RANDOM_FOREST_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
    -ap|--ap_script)
    ADD_PREDICT_SCRIPT="$2"
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
elif [ -z $MEANCOV ]; then
    echo "Missing -m|--meancov parameter"
    usage
    exit

fi

echo `date`: Running on `uname -n`

. $VENV

python $CREATE_FEATURE_TABLE_SCRIPT $VCF > $OUTDIR/features_table.txt

Rscript $RANDOM_FOREST_SCRIPT $OUTDIR/features_table.txt $MEANCOV

python $ADD_PREDICT_SCRIPT $VCF $OUTDIR/predict_labels.txt > $OUTPUT

echo `date`: Done
