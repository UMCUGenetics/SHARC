#!/bin/bash

usage() {
echo "
Required parameters:
#     -j|--jobnames		Jobnames
    -f|--bedfiles		Path to directory with bed files
    -v|--vcfsplitdir  Path to vcf split directory
    -o|--outputdir  Path to output directory
    -s|--stepsdir Path to sharc steps directory
    -b|--bedscript		Path to get_closest_feature.py
    -i|--jobid  Job id
    -m|--mail   Mail
    -e|--venv   Path to virtual env of NanoSV [$VENV]

Optional parameters:
    -h|--help		Shows help
"
}

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
    -h|--help)
    usage
    shift # past argument
    ;;
#     -j|--jobnames)
#     HOLDJOBNAMES="$2"
#     shift # past argument
#     shift # past value
#    ;;
    -f|--bedfiles)
    BEDFILES="$2"
    shift # past argument
    shift # past value
    ;;
    -v|--vcfsplitdir)
    VCF_SPLIT_OUTPUTDIR="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--outputdir)
    OUTPUTDIR="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--stepsdir)
    STEPSDIR="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--bedscript)
    BED_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--mail)
    MAIL="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--venv)
    VENV="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--jobid)
    JOBID="$2"
    shift # past argument
    shift # past value
    ;;
    -vm|--vmem)
    BED_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -rt|--runtime)
    BED_TIME="$2"
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
# if [ -z $HOLDJOBNAMES ]; then
#     echo "Missing -j|--jobnames parameter"
#     usage
#     exit
# elif [ -z $BEDFILES ]; then
if [ -z $BEDFILES ]; then
    echo "Missing -f|--bedfiles parameter"
    usage
    exit
elif [ -z $VCF_SPLIT_OUTPUTDIR ]; then
    echo "Missing -v|--vcfsplitdir parameter"
    usage
    exit
elif [ -z $OUTPUTDIR ]; then
    echo "Missing -o|--outputdir parameter"
    usage
    exit
elif [ -z $STEPSDIR ]; then
    echo "Missing -s|--stepsdir parameter"
    usage
    exit
elif [ -z $BED_SCRIPT ]; then
    echo "Missing -b|--bedscript parameter"
    usage
    exit
elif [ -z $MAIL ]; then
    echo "Missing -m|--mail parameter"
    usage
    exit
elif [ -z $VENV ]; then
    echo "Missing -e|--venv parameter"
    usage
    exit
elif [ -z $JOBID ]; then
    echo "Missing -i|--jobid parameter"
    usage
    exit
elif [ -z $BED_MEM ]; then
    echo "Missing -vm|--vmem parameter"
    usage
    exit
elif [ -z $BED_TIME ]; then
    echo "Missing -rt|--runtime parameter"
    usage
    exit
fi

JOBDIR=$OUTPUTDIR/jobs
LOGDIR=$OUTPUTDIR/logs
JOBNAMES=(`echo $HOLDJOBNAMES | sed 's/,/ /g'`)
NUMBER_OF_SPLIT_FILES=$(ls -l $VCF_SPLIT_OUTPUTDIR/*.vcf | wc -l)
i=1


for BED in $BEDFILES/*.feature.bed; do
  BEDNAME=($(basename $BED | tr '.' ' '))
  BEDNAME=${BEDNAME[0]}
#   BED_JOBNAME=${JOBNAMES[i]}
#   BED_SH=$JOBDIR/$BED_JOBNAME.sh
#   BED_ERR="$LOGDIR/${BED_JOBNAME}_\$ID.err"
#   BED_LOG="$LOGDIR/${BED_JOBNAME}_\$ID.log"
  BED_IN="$VCF_SPLIT_OUTPUTDIR/\$ID.vcf"
  BED_OUT="$VCF_SPLIT_OUTPUTDIR/\$ID.$BEDNAME.vcf"

cat << EOF > $BED_SH
#!/bin/bash

ID="\$1"

echo \`date\`: Running on \`uname -n\`

if [ -e $BED_IN ]; then
    if [ ! -e $BED_OUT.done ]; then
         bash $STEPSDIR/bed_annotation.sh \\
          -v $BED_IN \\
        -b $BED \\
        -s $BED_SCRIPT \\
        -e $VENV \\
        -o $BED_OUT
    else
         echo $BED_OUT already exists
    fi
else
    echo $BED_IN does not exists
fi

echo \`date\`: Done
EOF

  chmod +x $BED_SH
  for j in $(seq 1 $NUMBER_OF_SPLIT_FILES); do
    $BED_SH "$j"
  done

  ((i=i+1))
done