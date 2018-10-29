#!/bin/bash

usage() {
echo "
Required parameters:
    -f|--fastq		    Path to fastq file

Optional parameters:
    -h|--help		      Shows help
    -m|--minimap2	    Path to minimap2 [$MINIMAP2]
    -t|--threads	    Number of threads [$THREADS]
    -r|--ref		      Path to reference fasta file [$REF]
    -p|--parameters   Minimap2 parameters [$SETTINGS]
    -s|--sambamba	    Path to sambamba [$SAMBAMBA]
    -n|--sample_name  Sample name [$SAMPLE]
    -o|--output		    Path to sorted bam output file [$OUTPUT]
"
}

POSITIONAL=()

# DEFAULTS
MINIMAP2='/hpc/cog_bioinf/kloosterman/tools/minimap2_v2.12/minimap2'
THREADS=1
REF='/hpc/cog_bioinf/GENOMES/Homo_sapiens.GRCh37.GATK.illumina/Homo_sapiens.GRCh37.GATK.illumina.fasta'
SAMBAMBA='/hpc/local/CentOS7/cog_bioinf/sambamba_v0.6.5/sambamba'
OUTPUT='/dev/stdout'
SETTINGS='-x map-ont -a --MD'
#SETTINGS='-a --MD --no-long-join -r50'

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
    -h|--help)
    usage
    shift # past argument
    ;;
    -f|--fastq)
    FASTQ="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--minimap2)
    MINIMAP2="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--threads)
    THREADS="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--ref)
    REF="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--sambamba)
    SAMBAMBA="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--parameters)
    SETTINGS="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--sample_name)
    SAMPLE="$2"
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
if [ -z $FASTQ ]; then
    echo "Missing -f|--fastq parameter"
    usage
    exit
fi

echo `date`: Running on `uname -n`
if [ ! $SAMPLE ]; then
  if [ "$(head -n 1 $FASTQ | cut -d " " -f 3 | cut -d "=" -f 1)" == "sampleid" ]; then
    SAMPLE=$(head -n 1 $FASTQ | cut -d " " -f 3 | cut -d "=" -f 2)
  else
    echo "No sample name found in fastq file - Please manually enter a sample name"
    exit
  fi
fi

FASTQ_ID=${FASTQ#*_}
FASTQ_ID=${FASTQ_ID%.fastq}

SETTINGS="$SETTINGS -R @RG\tID:$FASTQ_ID\tSM:$SAMPLE"

$MINIMAP2 -t $THREADS $SETTINGS $REF $FASTQ | \
$SAMBAMBA view -h -S --format=bam -t 8 /dev/stdin | \
$SAMBAMBA sort -m9G -t $THREADS --tmpdir=./ /dev/stdin \
-o $OUTPUT

if [ -e $OUTPUT ]; then
    NUMBER_OF_READS_IN_FASTQ=$(grep "^@" $FASTQ | sort | uniq | wc -l)
    NUMBER_OF_READS_IN_BAM=$($SAMBAMBA view $OUTPUT | cut -f 1 | sort | uniq | wc -l)
    if [ "$NUMBER_OF_READS_IN_FASTQ" == "$NUMBER_OF_READS_IN_BAM" ]; then
        touch $OUTPUT.done
    else
        echo "Number of reads in the fastq file ($NUMBER_OF_READS_IN_FASTQ) is different than the number of reads in the bam file ($NUMBER_OF_READS_IN_BAM)" >&2
    fi
fi

echo `date`: Done
