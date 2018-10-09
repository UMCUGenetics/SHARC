#!/bin/bash

usage() {
echo "
Required parameters:
    -f|--fastqdir                                Path to fastq directory
    -m|--mail                                    Email adress
    -mc|--meancov                                Mean coverage

Optional parameters:

GENERAL
    -h|--help		                                 Shows help
    -sd|--sharc_dir                              Path to sharc directory [$SHARCDIR]
    -v|--venv		                                 Path to virtual env [$VENV]
    -o|--outputdir	                             Path to output directory [$OUTPUTDIR]

MAPPING
    -mt|--mapping_threads	                       Number of threads [$MAPPING_THREADS]
    -mhv|--mapping_h_vmem                        Mapping memory [$MAPPING_MEM]
    -mhr|--mapping_h_rt                          Mapping time [$MAPPING_TIME]
    -mr|--mapping_ref		                         Path to reference fasta file [$MAPPING_REF]
    -mm|--minimap2	                             Path to minimap2 [$MAPPING_MINIMAP2]
    -mms|--minimap2_settings                     minimap2 settings [$MAPPING_MINIMAP2_SETTINGS]
    -msb|--mapping_sambamba	                     Path to sambamba [$MAPPING_SAMBAMBA]

MAPPING MERGE
    -mmt|--mapping_merge_threads	               Number of threads [$MAPPING_MERGE_THREADS]
    -mmhv|--mapping_merge_h_vmem                 Mapping merge memory [$MAPPING_MERGE_MEM]
    -mmhr|--mapping_merge_h_rt                   Mapping merge time [$MAPPING_MERGE_TIME]
    -mms|--mapping_merge_sambamba	               Path to sambamba [$MAPPING_MERGE_SAMBAMBA]

SV_CALLING
    -svt|--sv_threads                            Number of threads [$SV_THREADS]
    -svhv|--sv_h_vmem                            Mapping memory [$SV_MEM]
    -svhr|--sv_h_rt                              Mapping time [$SV_TIME]
    -svc|--sv_config		                         Path to config file [$SV_CONFIG]
    -svs|--sv_sambamba	                         Path to sambamba [$SV_SAMBAMBA]

VCF_FILTER
    -vfhv|--vcf_filter_h_vmem                    Mapping memory [$VCF_FILTER_MEM]
    -vfhr|--vcf_filter_h_rt                      Mapping time [$VCF_FILTER_TIME]
    -vfq|--vcf_filter_query                      VCF Filter query [$VCF_FILTER_QUERY]

VCF_SPLIT
    -vshv|--vcf_split_h_vmem                     Mapping memory [$VCF_SPLIT_MEM]
    -vshr|--vcf_split_h_rt                       Mapping time [$VCF_SPLIT_TIME]
    -vsl|--vcf_split_lines		                   Number of lines per split [$VCF_SPLIT_LINES]

CREATE_BED_ANNOTATION
    -cbahv|--create_bed_annotation_h_vmem        Mapping memory [$CREATE_BED_ANNOTATION_MEM]
    -cbahr|--create_bed_annotation_h_rt          Mapping time [$CREATE_BED_ANNOTATION_TIME]

BED_ANNOTATION
    -bahv|--bad_annotation_h_vmem                Mapping memory [$BED_ANNOTATION_MEM]
    -bahr|--bad_annotation_h_rt                  Mapping time [$BED_ANNOTATION_TIME]
    -baf|--bed_annotation_files	                 Path to the directory with the feature bed files [$BED_ANNOTATION_FILES]
    -bas|--bed_annotation_script	               Path to get_closest_feature.py script [$BED_ANNOTATION_SCRIPT]

BED_ANNOTATION MERGE
    -bamhv|--bed_annotation_merge_h_vmem         Mapping memory [$BED_ANNOTATION_MERGE_MEM]
    -bamhr|--bed_annotation_merge_h_rt           Mapping time [$BED_ANNOTATION_MERGE_TIME]

RANDOM_FOREST
    -rfhv|--rf_h_vmem                            Mapping memory [$RF_MEM]
    -rfhr|--rf_h_rt                              Mapping time [$RF_TIME]
    -rffts|--rf_ft_script                        Path to create_features_table.pl script [$RF_CREATE_FEATURE_TABLE_SCRIPT]
    -rfs|--rf_script                             Path to run_randomForest.R script [$RF_SCRIPT]
    -rfps|--rf_p_script                          Path to add_predict_annotation.py script [$RF_ADD_PREDICT_SCRIPT]

DB FILTER
    -dbhv|--db_h_vmem                            Mapping memory [$DB_MEM]
    -dbhr|--db_h_rt                              Mapping time [$DB_TIME]
    -dbf|--db_flank                              Database filter flank [$DB_FLANK]

DB MERGE
    -dbmhv|--db_merge_h_vmem                     Mapping memory [$DB_MERGE_MEM]
    -dbmhr|--db_merge_h_rt                       Mapping time [$DB_MERGE_TIME]

SHARC_FILTER
    -sfhv|--sharc_filter_h_vmem                  Mapping memory [$SHARC_FILTER_MEM]
    -sfhr|--sharc_filter_h_rt                    Mapping time [$SHARC_FILTER_TIME]
    -sfq|--sharc_filter_query                    SHARC Filter query [$SHARC_FILTER_QUERY]

VCF_TO_FASTA
    -v2fhv|--vcf_fasta_h_vmem                    Mapping memory [$VCF_FASTA_MEM]
    -v2fhr|--vcf_fasta_h_rt                      Mapping time [$VCF_FASTA_TIME]
    -v2fo|--vcf_fasta_offset                     VCF to FASTA offset [$VCF_FASTA_OFFSET]
    -v2ff|--vcf_fasta_flank                      VCF to FASTA flank [$VCF_FASTA_FLANK]
    -v2fm|--vcf_fasta_mask                       VCF tot FASTA mask [$VCF_FASTA_MASK]
    -v2fs|--vcf_fasta_script                     Path to vcf_to_fasta.py [$VCF_FASTA_SCRIPT]

PRIMER DESIGN
    -pdhv|--primer_design_h_vmem                 Mapping memory [$PRIMER_DESIGN_MEM]
    -pdhr|--primer_design_h_rt                   Mapping time [$PRIMER_DESIGN_TIME]
    -pdd|--primer_design_dir                     Path to primer3 directory [$PRIMER_DESIGN_DIR]
    -pdb|--primer_design_bindir                  Path to primer3 bin dir [$PRIMER_DESIGN_BINDIR]
    -pdpt|--primer_design_pcr_type               PCR type [$PRIMER_DESIGN_PCR_TYPE]
    -pdtp|--primer_design_tilling_params         Tilling params [$PRIMER_DESIGN_TILLING_PARAMS]
    -pdp|--primer_design_psr                     PSR [$PRIMER_DESIGN_PSR]
    -pgdp|--primer_design_guix_profile           Path to guix profile [$PRIMER_DESIGN_GUIX_PROFILE]
    -pdpc|--primer_design_primer3_core           Path to primer3_core [$PRIMER_DESIGN_PRIMER3_CORE]
    -pdm|--primer_design_mispriming              Path to mispriming [$PRIMER_DESIGN_MISPRIMING]

VCF PRIMER FILTER
    -vpfhv|--vcf_primer_filter_h_vmem            Mapping memory [$VCF_PRIMER_FILTER_MEM]
    -vpfhr|--vcf_primer_filter_h_rt              Mapping time [$VCF_PRIMER_FILTER_TIME]
    -vpfs|--vcf_primer_filter_script             Path to vcf_primer_filter.py [$VCF_PRIMER_FILTER_SCRIPT]


"
exit
}

POSITIONAL=()

# GENERAL DEFAULTS
SHARCDIR='/hpc/cog_bioinf/kloosterman/common_scripts/sharc/'
VENV=$SHARCDIR/venv/bin/activate
STEPSDIR=$SHARCDIR/steps
SCRIPTSDIR=$SHARCDIR/scripts
FILESDIR=$SHARCDIR/files
OUTPUTDIR='./'
SAMBAMBA='/hpc/local/CentOS7/cog_bioinf/sambamba_v0.6.5/sambamba'

# MAPPING DEFAULTS
MAPPING_THREADS=1
MAPPING_MEM=20G
MAPPING_TIME=1:0:0
MAPPING_REF='/hpc/cog_bioinf/GENOMES/Homo_sapiens.GRCh37.GATK.illumina/Homo_sapiens.GRCh37.GATK.illumina.fasta'
MAPPING_MINIMAP2='/hpc/cog_bioinf/kloosterman/tools/minimap2_v2.12/minimap2'
MAPPING_MINIMAP2_SETTINGS='-a --MD'
#MAPPING_MINIMAP2_SETTINGS='-a --MD --no-long-join -r50'
MAPPING_SAMBAMBA=$SAMBAMBA

# MAPPING MERGE DEFAULTS
MAPPING_MERGE_THREADS=8
MAPPING_MERGE_MEM=10G
MAPPING_MERGE_TIME=1:0:0
MAPPING_MERGE_SAMBAMBA=$SAMBAMBA

# SV DEFAULTS
SV_THREADS=8
SV_MEM=20G
SV_TIME=1:0:0
SV_CONFIG=$FILESDIR/config_NanoSV_SHARC.ini
SV_SAMBAMBA=$SAMBAMBA

# VCF_FILTER DEFAULTS
VCF_FILTER_MEM=2G
VCF_FILTER_TIME=0:5:0
VCF_FILTER_QUERY='$7 == "PASS" && $1 !~ /[XYMT]/ && $5 !~ /[XYMT]/ && $5 != "<INS>"'

# VCF_SPLIT DEFAULTS
VCF_SPLIT_MEM=2G
VCF_SPLIT_TIME=0:5:0
VCF_SPLIT_LINES=100

# CREATE_BED_ANNOTATION DEFAULTS
CREATE_BED_ANNOTATION_MEM=2G
CREATE_BED_ANNOTATION_TIME=0:5:0

# BED_ANNOTATION DEFAULTS
BED_ANNOTATION_MEM=10G
BED_ANNOTATION_TIME=0:10:0
BED_ANNOTATION_FILES=$FILESDIR
BED_ANNOTATION_SCRIPT=$SCRIPTSDIR/get_closest_feature.py

# BED_ANNOTATION_MERGE DEFAULTS
BED_ANNOTATION_MERGE_MEM=2G
BED_ANNOTATION_MERGE_TIME=0:5:0

# RANDOM_FOREST DEFAULTS
RF_MEM=2G
RF_TIME=0:5:0
RF_CREATE_FEATURE_TABLE_SCRIPT=$SCRIPTSDIR/create_features_table.pl
RF_SCRIPT=$SCRIPTSDIR/run_randomForest.R
RF_ADD_PREDICT_SCRIPT=$SCRIPTSDIR/add_predict_annotation.py

# DB DEFAULTS
DB_MEM=2G
DB_TIME=0:5:0
DB_TYPES=("REFDB" "SHARCDB")
DB_FLANK=100

# DB_MERGE
DB_MERGE_MEM=2G
DB_MERGE_TIME=0:5:0

# SHARC FILTER DEFAULTS
SHARC_FILTER_MEM=2G
SHARC_FILTER_TIME=0:5:0
SHARC_FILTER_QUERY='grep "PREDICT_LABEL=1" | grep -v "SHARCDBFILTER" | grep -v "REFDBFILTER"'

# VCF_FASTA_DEFAULTS
VCF_FASTA_MEM=2G
VCF_FASTA_TIME=0:5:0
VCF_FASTA_FLANK=200
VCF_FASTA_OFFSET=0
VCF_FASTA_MARK=false
VCF_FASTA_SCRIPT=$SCRIPTSDIR/vcf_to_fasta.py

# PRIMER_DESIGN_DEFAULTS
PRIMER_DESIGN_MEM=2G
PRIMER_DESIGN_TIME=0:5:0
PRIMER_DESIGN_DIR='/hpc/cog_bioinf/kloosterman/tools/primer3/'
PRIMER_DESIGN_BINDIR=$PRIMER_DESIGN_DIR/primers
PRIMER_DESIGN_PCR_TYPE='single'
PRIMER_DESIGN_TILLING_PARAMS=''
#PRIMER_DESIGN_PSR='30-230'
PRIMER_DESIGN_PSR='60-100'
PRIMER_DESIGN_GUIX_PROFILE=$PRIMER_DESIGN_DIR/emboss/.guix-profile
PRIMER_DESIGN_PRIMER3_CORE=$PRIMER_DESIGN_DIR/primer3/src/primer3_core
PRIMER_DESIGN_MISPRIMING=$PRIMER_DESIGN_DIR/repbase/current/empty.ref

# VCF PRIMER FILTER DEFAULTS
VCF_PRIMER_FILTER_MEM=2G
VCF_PRIMER_FILTER_TIME=0:5:0
VCF_PRIMER_FILTER_SCRIPT=$SCRIPTSDIR/vcf_primer_filter.py

while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
# REQUIRED OPTIONS
    -f|--fastqdir)
    FASTQDIR="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--mail)
    MAIL="$2"
    shift # past argument
    shift # past value
    ;;
    -mc|--meancov)
    MEANCOV="$2"
    shift # past argument
    shift # past value
    ;;
# GENERAL OPTIONS
    -h|--help)
    usage
    shift # past argument
    ;;
    -sd|--sharc_dir)
    SHARCDIR="$2"
    shift # past argument
    shift # past value
    ;;
    -v|--venv)
    VENV="$2"
    shift # past argument
    shift # past value
    ;;
    -o|--outputdir)
    OUTPUTDIR="$2"
    shift # past argument
    shift # past value
    ;;
# MAPPING OPTIONS
    -mt|--mapping_threads)
    MAPPING_THREADS="$2"
    shift # past argument
    shift # past value
    ;;
    -mhv|--mapping_h_vmem)
    MAPPING_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -mhr|--mapping_h_rt)
    MAPPING_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -mr|--mapping_ref)
    MAPPING_REF="$2"
    shift # past argument
    shift # past value
    ;;
    -mm|--minimap2)
    MAPPING_MINIMAP2="$2"
    shift # past argument
    shift # past value
    ;;
    -ms|--mapping_sambamba)
    MAPPING_SAMBAMBA="$2"
    shift # past argument
    shift # past value
    ;;
    -mms|--minimap2_settings)
    MAPPING_MINIMAP2_SETTINGS="$2"
    shift # past argument
    shift # past value
    ;;
# MAPPING MERGE OPTIONS
    -mmt|--mapping_merge_threads)
    MAPPING_MERGE_THREADS="$2"
    shift # past argument
    shift # past value
    ;;
    -mmhv|--mapping_merge_h_vmem)
    MAPPING_MERGE_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -mmhr|--mapping_merge_h_rt)
    MAPPING_MERGE_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -mms|--mapping_merge_sambamba)
    MAPPING_MERGE_SAMBAMBA="$2"
    shift # past argument
    shift # past value
    ;;
# SV_CALLING OPTIONS
    -svt|--sv_threads)
    SV_THREADS="$2"
    shift # past argument
    shift # past value
    ;;
    -svhv|--sv_h_vmem)
    SV_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -svhr|--sv_h_rt)
    SV_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -svc|--sv_config)
    SV_CONFIG="$2"
    shift # past argument
    shift # past value
    ;;
    -svs|--sv_sambamba)
    SV_SAMBAMBA="$2"
    shift # past argument
    shift # past value
    ;;
# VCF_FILTER OPTIONS
    -vfhv|--vcf_filter_h_vmem)
    VCF_FILTER_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -vfhr|--vcf_filter_h_rt)
    VCF_FILTER_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -vfq|--vcf_filter_query)
    VCF_FILTER_QUERY="$2"
    shift # past argument
    shift # past value
    ;;
# VCF_SPLIT OPTIONS
    -vshv|--vcf_split_h_vmem)
    VCF_SPLIT_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -vshr|--vcf_split_h_rt)
    VCF_SPLIT_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -vsl|--vcf_split_lines)
    VCF_SPLIT_LINES="$2"
    shift # past argument
    shift # past value
    ;;
# CREATE_BED_ANNOTATION OPTIONS
    -cbahv|--create_bed_annotation_h_vmem)
    CREATE_BED_ANNOTATION_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -cbahr|--create_bed_annotation_h_rt)
    CREATE_BED_ANNOTATION_TIME="$2"
    shift # past argument
    shift # past value
    ;;
# BED_ANNOTATION OPTIONS
    -bahv|--bed_annotation_h_vmem)
    BED_ANNOTATION_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -bahr|--bed_annotation_h_rt)
    BED_ANNOTATION_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -baf|--bed_annotation_files)
    BED_ANNOTATION_FILES="$2"
    shift # past argument
    shift # past value
    ;;
    -bas|--bed_annotation_script)
    BED_ANNOTATION_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
# BED_ANNOTATION_MERGE OPTIONS
    -bamhv|--bed_annotation_merge_h_vmem)
    BED_ANNOTATION_MERGE_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -bamhr|--bed_annotation_merge_h_rt)
    BED_ANNOTATION_MERGE_TIME="$2"
    shift # past argument
    shift # past value
    ;;
# RANDOM_FOREST OPTIONS
    -rfhv|--rf_h_vmem)
    RF_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -rfhr|--rf_h_rt)
    RF_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -rffts|--rf_ft_script)
    RF_CREATE_FEATURE_TABLE_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
    -rfs|--rf_script)
    RF_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
    -rfps|--rf_p_script)
    RF_ADD_PREDICT_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
# DB OPTIONS
    -dbhv|--db_h_vmem)
    DB_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -dbhr|--db_h_rt)
    DB_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -dbf|--db_flank)
    DB_FLANK="$2"
    shift # past argument
    shift # past value
    ;;
# DB_MERGE OPTIONS
    -dbmhv|--db_merge_h_vmem)
    DB_MERGE_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -dbmhr|--db_merge_h_rt)
    DB_MERGE_TIME="$2"
    shift # past argument
    shift # past value
    ;;
# SHARC_FILTER OPTIONS
    -sfhv|--sharc_filter_h_vmem)
    SHARC_FILTER_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -sfhr|--sharc_filter_h_rt)
    SHARC_FILTER_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -sfq|--sharc_filter_query)
    SHARC_FILTER_QUERY="$2"
    shift # past argument
    shift # past value
    ;;
# VCF_FASTA OPTIONS
    -v2fhv|--vcf_fasta_h_vmem)
    VCF_FASTA_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -v2fhr|--vcf_fasta_h_rt)
    VCF_FASTA_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -v2fo|--vcf_fasta_offset)
    VCF_FASTA_OFFSET="$2"
    shift # past argument
    shift # past value
    ;;
    -v2ff|--vcf_fasta_flank)
    VCF_FASTA_FLANK="$2"
    shift # past argument
    shift # past value
    ;;
    -v2fm|--vcf_fasta_mask)
    VCF_FASTA_MASK=true
    shift # past argument
    ;;
    -v2fs|--vcf_fasta_script)
    VCF_FASTA_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
# PRIMER_DESIGN OPTIONS
    -pdhv|--primer_design_h_vmem)
    PRIMER_DESIGN_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -pdhr|--primer_design_h_rt)
    PRIMER_DESIGN_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -pdd|--primer_design_dir)
    PRIMER_DESIGN_DIR="$2"
    shift # past argument
    shift # past value
    ;;
    -pdb|--primer_design_bindir)
    PRIMER_DESIGN_BINDIR="$2"
    shift # past argument
    shift # past value
    ;;
    -pdpt|--primer_design_pcr_type)
    PRIMER_DESIGN_PCR_TYPE="$2"
    shift # past argument
    shift # past value
    ;;
    -pdtp|--primer_design_tilling_params)
    PRIMER_DESIGN_TILLING_PARAMS="$2"
    shift # past argument
    shift # past value
    ;;
    -pdp|--primer_design_psr)
    PRIMER_DESIGN_PSR="$2"
    shift # past argument
    shift # past value
    ;;
    -pdgp|--primer_design_guix_profile)
    PRIMER_DESIGN_GUIX_PROFILE="$2"
    shift # past argument
    shift # past value
    ;;
    -pdpc|--primer_design_primer3_core)
    PRIMER_DESIGN_PRIMER3_CORE="$2"
    shift # past argument
    shift # past value
    ;;
    -pdm|--primer_design_mispriming)
    PRIMER_DESIGN_MISPRIMING="$2"
    shift # past argument
    shift # past value
    ;;
# VCF PRIMER FILTER OPTIONS
    -vpfhv|--vcf_primer_filter_h_vmem)
    VCF_PRIMER_FILTER_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -vpfhr|--vcf_primer_filter_h_rt)
    VCF_PRIMER_FILTER_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -vpfs|--vcf_primer_filter_script)
    VCF_PRIMER_FILTER_SCRIPT="$2"
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
if [ -z $FASTQDIR ]; then
  echo "Missing -f|--fastq parameter"
  usage
elif [ -z $MAIL ]; then
  echo "Missing -m|--mail parameter"
  usage
elif [ -z $MEANCOV ]; then
  echo "Missing -mc|--meancov parameter"
  usage
fi

FASTQDIR=$(readlink -f $FASTQDIR)
if [ ! -d $FASTQDIR ]; then
  echo "Fastq directory \"$FASTQDIR\" does not exists."
  exit
fi

if [ -z "$(ls -l $FASTQDIR/*.fastq 2>/dev/null)" ]; then
  echo "No fastq files found in fastq directory \"$FASTQDIR\"."
  exit
fi

prepare() {
OUTPUTDIR=$(readlink -f $OUTPUTDIR)
JOBDIR=$OUTPUTDIR/jobs
LOGDIR=$OUTPUTDIR/logs

OUTNAME=$(basename $OUTPUTDIR)
RAND=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 5)
NUMBER_OF_FASTQ_FILES=$(ls -l $FASTQDIR/*.fastq | wc -l)

MAPPING_DIR=$OUTPUTDIR/mapping/minimap2
MAPPING_TMP_DIR=$MAPPING_DIR/tmp
MAPPING_JOBNAME=$OUTNAME'_MAPPING_'$RAND
MAPPING_SH=$JOBDIR/$MAPPING_JOBNAME.sh
MAPPING_ERR="$LOGDIR/${MAPPING_JOBNAME}_\$TASK_ID.err"
MAPPING_LOG="$LOGDIR/${MAPPING_JOBNAME}_\$TASK_ID.log"

MAPPING_MERGE_JOBNAME=$OUTNAME'_MAPPINGMERGE_'$RAND
MAPPING_MERGE_SH=$JOBDIR/$MAPPING_MERGE_JOBNAME.sh
MAPPING_MERGE_ERR=$LOGDIR/$MAPPING_MERGE_JOBNAME.err
MAPPING_MERGE_LOG=$LOGDIR/$MAPPING_MERGE_JOBNAME.log
MAPPING_MERGE_OUT=$MAPPING_DIR/$OUTNAME.sorted.bam

SV_DIR=$OUTPUTDIR/sv/nanosv
SV_TMP_DIR=$SV_DIR/tmp
SV_JOBNAME=$OUTNAME'_SV_'$RAND
SV_SH=$JOBDIR/$SV_JOBNAME
SV_ERR=$LOGDIR/$SV_JOBNAME.err
SV_LOG=$LOGDIR/$SV_JOBNAME.log
SV_OUT=$SV_DIR/$OUTNAME.nanosv.vcf

VCF_FILTER_JOBNAME=$OUTNAME'_VCFFILTER_'$RAND
VCF_FILTER_SH=$JOBDIR/$VCF_FILTER_JOBNAME.sh
VCF_FILTER_ERR=$LOGDIR/$VCF_FILTER_JOBNAME.err
VCF_FILTER_LOG=$LOGDIR/$VCF_FILTER_JOBNAME.log
VCF_FILTER_OUT=$SV_TMP_DIR/$(basename ${SV_OUT/.vcf/.filter.vcf})

VCF_SPLIT_OUTDIR=$SV_TMP_DIR/split
VCF_SPLIT_JOBNAME=$OUTNAME'_VCFSPLIT_'$RAND
VCF_SPLIT_SH=$JOBDIR/$VCF_SPLIT_JOBNAME.sh
VCF_SPLIT_ERR=$LOGDIR/$VCF_SPLIT_JOBNAME.err
VCF_SPLIT_LOG=$LOGDIR/$VCF_SPLIT_JOBNAME.log
VCF_SPLIT_OUT=$SV_TMP_DIR/$(basename ${VCF_FILTER_OUT/.vcf/.split.vcf})

CREATE_BED_ANNOTATION_JOBNAME=$OUTNAME'_CREATEBEDANNOTATION_'$RAND
CREATE_BED_ANNOTATION_SH=$JOBDIR/$CREATE_BED_ANNOTATION_JOBNAME.sh
CREATE_BED_ANNOTATION_ERR=$LOGDIR/$CREATE_BED_ANNOTATION_JOBNAME.err
CREATE_BED_ANNOTATION_LOG=$LOGDIR/$CREATE_BED_ANNOTATION_JOBNAME.log

BED_ANNOTATION_JOBNAMES=$CREATE_BED_ANNOTATION_JOBNAME

BED_ANNOTATION_MERGE_JOBNAME=$OUTNAME'_BEDANNOTATIONMERGE_'$RAND
BED_ANNOTATION_MERGE_SH=$JOBDIR/$BED_ANNOTATION_MERGE_JOBNAME.sh
BED_ANNOTATION_MERGE_ERR=$LOGDIR/$BED_ANNOTATION_MERGE_JOBNAME.err
BED_ANNOTATION_MERGE_LOG=$LOGDIR/$BED_ANNOTATION_MERGE_JOBNAME.log
BED_ANNOTATION_MERGE_OUT=$SV_TMP_DIR/$(basename ${VCF_FILTER_OUT/.vcf/.annotation.vcf})

RF_OUTDIR=$SV_TMP_DIR/rf
RF_JOBNAME=$OUTNAME'_RF_'$RAND
RF_SH=$JOBDIR/$RF_JOBNAME.sh
RF_ERR=$LOGDIR/$RF_JOBNAME.err
RF_LOG=$LOGDIR/$RF_JOBNAME.log
RF_OUT=$SV_TMP_DIR/$(basename ${BED_ANNOTATION_MERGE_OUT/.vcf/.predict.vcf})

DB_OUTDIR=$SV_TMP_DIR/db
DB_JOBNAMES=''

DB_MERGE_JOBNAME=$OUTNAME'_DBMERGE_'$RAND
DB_MERGE_SH=$JOBDIR/$DB_MERGE_JOBNAME.sh
DB_MERGE_ERR=$LOGDIR/$DB_MERGE_JOBNAME.err
DB_MERGE_LOG=$LOGDIR/$DB_MERGE_JOBNAME.log
DB_MERGE_OUT=$SV_TMP_DIR/$(basename ${RF_OUT/.vcf/.dbfilter.vcf})

SHARC_FILTER_JOBNAME=$OUTNAME'_SHARCFILTER_'$RAND
SHARC_FILTER_SH=$JOBDIR/$SHARC_FILTER_JOBNAME.sh
SHARC_FILTER_ERR=$LOGDIR/$SHARC_FILTER_JOBNAME.err
SHARC_FILTER_LOG=$LOGDIR/$SHARC_FILTER_JOBNAME.log
SHARC_FILTER_OUT=$SV_DIR/$(basename ${SV_OUT/.vcf/.SHARC.vcf})

VCF_FASTA_OUTDIR=$OUTPUTDIR/primers
VCF_FASTA_JOBNAME=$OUTNAME'_VCFFASTA_'$RAND
VCF_FASTA_SH=$JOBDIR/$VCF_FASTA_JOBNAME.sh
VCF_FASTA_ERR=$LOGDIR/$VCF_FASTA_JOBNAME.err
VCF_FASTA_LOG=$LOGDIR/$VCF_FASTA_JOBNAME.log
VCF_FASTA_OUT=$VCF_FASTA_OUTDIR/$(basename ${SHARC_FILTER_OUT/.vcf/.fasta})

PRIMER_DESIGN_OUTDIR=$OUTPUTDIR/primers
PRIMER_DESIGN_TMP_DIR=$PRIMER_DESIGN_OUTDIR/tmp
PRIMER_DESIGN_JOBNAME=$OUTNAME'_PRIMERDESIGN_'$RAND
PRIMER_DESIGN_SH=$JOBDIR/$PRIMER_DESIGN_JOBNAME.sh
PRIMER_DESIGN_ERR=$LOGDIR/$PRIMER_DESIGN_JOBNAME.err
PRIMER_DESIGN_LOG=$LOGDIR/$PRIMER_DESIGN_JOBNAME.log
PRIMER_DESIGN_OUT=$PRIMER_DESIGN_OUTDIR/$(basename ${VCF_FASTA_OUT/.fasta/.primers})

VCF_PRIMER_FILTER_OUTDIR=$SV_DIR
VCF_PRIMER_FILTER_JOBNAME=$OUTNAME'_VCFPRIMERFILTER_'$RAND
VCF_PRIMER_FILTER_SH=$JOBDIR/$VCF_PRIMER_FILTER_JOBNAME.sh
VCF_PRIMER_FILTER_ERR=$LOGDIR/$VCF_PRIMER_FILTER_JOBNAME.err
VCF_PRIMER_FILTER_LOG=$LOGDIR/$VCF_PRIMER_FILTER_JOBNAME.log
VCF_PRIMER_FILTER_OUT=$VCF_PRIMER_FILTER_OUTDIR/$(basename ${SHARC_FILTER_OUT/.vcf/.primers.vcf})

mkdir -p $OUTPUTDIR
if [ ! -d $OUTPUTDIR ]; then
    exit
fi
mkdir -p $MAPPING_DIR
if [ ! -d $MAPPING_DIR ]; then
    exit
fi
mkdir -p $MAPPING_TMP_DIR
if [ ! -d $MAPPING_TMP_DIR ]; then
    exit
fi
mkdir -p $LOGDIR
if [ ! -d $LOGDIR ]; then
    exit
fi
mkdir -p $JOBDIR
if [ ! -d $JOBDIR ]; then
    exit
fi
mkdir -p $SV_DIR
if [ ! -d $SV_DIR ]; then
    exit
fi
mkdir -p $SV_TMP_DIR
if [ ! -d $SV_TMP_DIR ]; then
    exit
fi
mkdir -p $VCF_SPLIT_OUTDIR
if [ ! -d $VCF_SPLIT_OUTDIR ]; then
    exit
fi
mkdir -p $RF_OUTDIR
if [ ! -d $RF_OUTDIR ]; then
    exit
fi
mkdir -p $DB_OUTDIR
if [ ! -d $DB_OUTDIR ]; then
    exit
fi
mkdir -p $PRIMER_DESIGN_TMP_DIR
if [ ! -d $PRIMER_DESIGN_TMP_DIR ]; then
    exit
fi
cd $OUTPUTDIR
}

mapping() {
cat << EOF > $MAPPING_SH
#!/bin/bash

#$ -N $MAPPING_JOBNAME
#$ -cwd
#$ -t 1-$NUMBER_OF_FASTQ_FILES:1
#$ -pe threaded $MAPPING_THREADS
#$ -l h_vmem=$MAPPING_MEM
#$ -l h_rt=$MAPPING_TIME
#$ -e $MAPPING_ERR
#$ -o $MAPPING_LOG
#$ -m ea
#$ -M $MAIL

ID=\$((\$SGE_TASK_ID-1))

echo \`date\`: Running on \`uname -n\`

if [ -e $FASTQDIR/fastq_\$ID.fastq ]; then
    if [ ! -e $MAPPING_TMP_DIR/\$ID.sorted.bam.done ]; then
	bash $STEPSDIR/minimap2.sh \\
	-f $FASTQDIR/fastq_\$ID.fastq \\
	-t $MAPPING_THREADS \\
	-m $MAPPING_MINIMAP2 \\
	-r $MAPPING_REF \\
  -p $MAPPING_MINIMAP2_SETTINGS \\
	-s $MAPPING_SAMBAMBA \\
	-o $MAPPING_TMP_DIR/\$ID.sorted.bam
    else
	echo $MAPPING_TMP_DIR/\$ID.sorted.bam already exists
    fi
else
    echo $FASTQDIR/fastq_\$ID.fastq does not exists
fi

echo \`date\`: Done
EOF
qsub $MAPPING_SH
}

mapping_merge() {
cat << EOF > $MAPPING_MERGE_SH
#!/bin/bash

#$ -N $MAPPING_MERGE_JOBNAME
#$ -cwd
#$ -pe threaded $MAPPING_MERGE_THREADS
#$ -l h_vmem=$MAPPING_MERGE_MEM
#$ -l h_rt=$MAPPING_MERGE_TIME
#$ -e $MAPPING_MERGE_ERR
#$ -o $MAPPING_MERGE_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $MAPPING_JOBNAME ]; then
cat << EOF >> $MAPPING_MERGE_SH
#$ -hold_jid $MAPPING_JOBNAME
EOF
fi

cat << EOF >> $MAPPING_MERGE_SH
echo \`date\`: Running on \`uname -n\`

NUMBER_OF_DONE_FILES=\$(ls -l $MAPPING_TMP_DIR/*.done | wc -l)

if [ ! -e $MAPPING_MERGE_OUT.done ]; then
    if [ \$NUMBER_OF_DONE_FILES -eq $NUMBER_OF_FASTQ_FILES ]; then
	     $MAPPING_SAMBAMBA merge -t $MAPPING_THREADS $MAPPING_MERGE_OUT $MAPPING_TMP_DIR/*.sorted.bam
    else
	     echo "Not enough done files found"
       exit
    fi
    NUMBER_OF_READS_IN_BAMS=\$(for BAM in $MAPPING_TMP_DIR/*.bam; do $MAPPING_SAMBAMBA view \$BAM | cut -f 1 | sort | uniq | wc -l; done | awk '{ SUM += \$1} END { print SUM }')
    NUMBER_OF_READS_IN_MERGED_BAM=\$($MAPPING_SAMBAMBA view $MAPPING_MERGE_OUT | cut -f 1 | sort | uniq | wc -l)
    if [ "\$NUMBER_OF_READS_IN_BAMS" == "\$NUMBER_OF_READS_IN_MERGED_BAM" ]; then
	     touch $MAPPING_MERGE_OUT.done
    fi
fi

echo \`date\`: Done
EOF
qsub $MAPPING_MERGE_SH
}

sv() {
cat << EOF > $SV_SH
#!/bin/bash

#$ -N $SV_JOBNAME
#$ -cwd
#$ -pe threaded $SV_THREADS
#$ -l h_vmem=$SV_MEM
#$ -l h_rt=$SV_TIME
#$ -e $SV_ERR
#$ -o $SV_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $MAPPING_MERGE_JOBNAME ]; then
cat << EOF >> $SV_SH
#$ -hold_jid $MAPPING_MERGE_JOBNAME
EOF
fi

cat << EOF >> $SV_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $MAPPING_MERGE_OUT.done ]; then
    bash $STEPSDIR/nanosv.sh -b $MAPPING_MERGE_OUT -t $SV_THREADS -s $SV_SAMBAMBA -v $VENV -c $SV_CONFIG -o $SV_OUT
    touch $SV_OUT.done
fi

echo \`date\`: Done
EOF
qsub $SV_SH
}

vcf_filter() {
cat << EOF > $VCF_FILTER_SH
#!/bin/bash

#$ -N $VCF_FILTER_JOBNAME
#$ -cwd
#$ -l h_vmem=$VCF_FILTER_MEM
#$ -l h_rt=$VCF_FILTER_TIME
#$ -e $VCF_FILTER_ERR
#$ -o $VCF_FILTER_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $SV_JOBNAME ]; then
cat << EOF >> $VCF_FILTER_SH
#$ -hold_jid $SV_JOBNAME
EOF
fi

cat << EOF >> $VCF_FILTER_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $SV_OUT.done ]; then
    bash $STEPSDIR/vcf_filter.sh -v $SV_OUT -f '$VCF_FILTER_QUERY' -o $VCF_FILTER_OUT
    touch $VCF_FILTER_OUT.done
fi

echo \`date\`: Done
EOF
qsub $VCF_FILTER_SH
}

vcf_split() {
cat << EOF > $VCF_SPLIT_SH
#!/bin/bash

#$ -N $VCF_SPLIT_JOBNAME
#$ -cwd
#$ -l h_vmem=$VCF_SPLIT_MEM
#$ -l h_rt=$VCF_SPLIT_TIME
#$ -e $VCF_SPLIT_ERR
#$ -o $VCF_SPLIT_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $VCF_FILTER_JOBNAME ]; then
cat << EOF >> $VCF_SPLIT_SH
#$ -hold_jid $VCF_FILTER_JOBNAME
EOF
fi

cat << EOF >> $VCF_SPLIT_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $VCF_FILTER_OUT.done ]; then
    bash $STEPSDIR/vcf_split.sh -v $VCF_FILTER_OUT -l $VCF_SPLIT_LINES -o $VCF_SPLIT_OUTDIR
    NUMBER_OF_LINES_VCF_1=\$(wc -l $VCF_FILTER_OUT | grep -oP "(\d+)")
    NUMBER_OF_LINES_VCF_2=\$(cat $VCF_SPLIT_OUTDIR/*.vcf | wc -l | grep -oP "(\d+)")

    if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_VCF_2" ]; then
        touch $VCF_SPLIT_OUT.done
    fi
fi

echo \`date\`: Done
EOF
qsub $VCF_SPLIT_SH
}

create_bed_annotation_jobs() {
for BED in $BED_ANNOTATION_FILES/*.bed; do
    BEDNAME=($(basename $BED | tr '.' ' '))
    BEDNAME=${BEDNAME[0]}
    BED_ANNOTATION_JOBNAME=$OUTNAME'_'$BEDNAME'_'$RAND
    BED_ANNOTATION_JOBNAMES=$BED_ANNOTATION_JOBNAMES','$BED_ANNOTATION_JOBNAME
done

cat << EOF > $CREATE_BED_ANNOTATION_SH
#!/bin/bash

#$ -N $CREATE_BED_ANNOTATION_JOBNAME
#$ -cwd
#$ -l h_vmem=$CREATE_BED_ANNOTATION_MEM
#$ -l h_rt=$CREATE_BED_ANNOTATION_TIME
#$ -e $CREATE_BED_ANNOTATION_ERR
#$ -o $CREATE_BED_ANNOTATION_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $VCF_SPLIT_JOBNAME ]; then
cat << EOF >> $CREATE_BED_ANNOTATION_SH
#$ -hold_jid $VCF_SPLIT_JOBNAME
EOF
fi

cat << EOF >> $CREATE_BED_ANNOTATION_SH

echo \`date\`: Running on \`uname -n\`

bash $STEPSDIR/create_bed_annotation_jobs.sh -j $BED_ANNOTATION_JOBNAMES -f $BED_ANNOTATION_FILES -v $VCF_SPLIT_OUTDIR -o $OUTPUTDIR -s $STEPSDIR -b $BED_ANNOTATION_SCRIPT -m $MAIL -i $BED_ANNOTATION_MERGE_JOBNAME -vm $BED_ANNOTATION_MEM -rt $BED_ANNOTATION_TIME

echo \`date\`: Done
EOF
qsub $CREATE_BED_ANNOTATION_SH
}

annotation_merge() {
PASTE_CMD="paste <(paste <(grep -v \"^#\" $VCF_FILTER_OUT | sort -k3n | cut -f -8)"
for BED in $BED_ANNOTATION_FILES/*; do
    BEDNAME=($(basename $BED | tr '.' ' '))
    BEDNAME=${BEDNAME[0]}
    PASTE_CMD=$PASTE_CMD" <(cat $VCF_SPLIT_OUTDIR/*.$BEDNAME.vcf | grep -v \"^#\" | sort -k3n | cut -f 8 | rev | cut -f 1 -d ';' | rev)"
done
PASTE_CMD=$PASTE_CMD" -d ';') <(grep -v \"^#\" $VCF_FILTER_OUT | sort -k3n | cut -f 9-) >> $BED_ANNOTATION_MERGE_OUT"

cat << EOF > $BED_ANNOTATION_MERGE_SH
#!/bin/bash

#$ -N $BED_ANNOTATION_MERGE_JOBNAME
#$ -cwd
#$ -l h_vmem=$BED_ANNOTATION_MERGE_MEM
#$ -l h_rt=$BED_ANNOTATION_MERGE_TIME
#$ -e $BED_ANNOTATION_MERGE_ERR
#$ -o $BED_ANNOTATION_MERGE_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $BED_ANNOTATION_JOBNAMES ]; then
cat << EOF >> $BED_ANNOTATION_MERGE_SH
#$ -hold_jid $BED_ANNOTATION_JOBNAMES
EOF
fi

cat << EOF >> $BED_ANNOTATION_MERGE_SH
echo \`date\`: Running on \`uname -n\`

NUMBER_OF_SPLIT_FILES=\$(ls -l $VCF_SPLIT_OUTDIR/*.*.vcf | wc -l)
NUMBER_OF_DONE_FILES=\$(ls -l $VCF_SPLIT_OUTDIR/*.done | wc -l)
if [ "\$NUMBER_OF_SPLIT_FILES" == "\$NUMBER_OF_DONE_FILES" ]; then
    grep "^#" $VCF_FILTER_OUT > $BED_ANNOTATION_MERGE_OUT
    $PASTE_CMD
fi

NUMBER_OF_LINES_VCF_1=\$(wc -l $VCF_FILTER_OUT | grep -oP "(\d+)")
NUMBER_OF_LINES_VCF_2=\$(wc -l $BED_ANNOTATION_MERGE_OUT | grep -oP "(\d+)")

if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_VCF_2" ]; then
    touch $BED_ANNOTATION_MERGE_OUT.done
fi

echo \`date\`: Done
EOF
qsub $BED_ANNOTATION_MERGE_SH
}

random_forest() {
cat << EOF > $RF_SH
#!/bin/bash

#$ -N $RF_JOBNAME
#$ -cwd
#$ -l h_vmem=$RF_MEM
#$ -l h_rt=$RF_TIME
#$ -e $RF_ERR
#$ -o $RF_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $BED_ANNOTATION_MERGE_JOBNAME ]; then
cat << EOF >> $RF_SH
#$ -hold_jid $BED_ANNOTATION_MERGE_JOBNAME
EOF
fi

cat << EOF >> $RF_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $BED_ANNOTATION_MERGE_OUT.done ]; then
    bash $STEPSDIR/randomForest.sh -v $BED_ANNOTATION_MERGE_OUT -m $MEANCOV -o $RF_OUT -d $RF_OUTDIR -ft $RF_CREATE_FEATURE_TABLE_SCRIPT -rf $RF_SCRIPT -ap $RF_ADD_PREDICT_SCRIPT

    NUMBER_OF_LINES_VCF_1=\$(grep -v "^#" $BED_ANNOTATION_MERGE_OUT | wc -l | grep -oP "(\d+)")
    NUMBER_OF_LINES_VCF_2=\$(grep -v "^#" $RF_OUT | wc -l | grep -oP "(\d+)")

    if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_VCF_2" ]; then
        touch $RF_OUT.done
    fi
fi

echo \`date\`: Done
EOF
qsub $RF_SH
}

db_filter() {
for DB in ${DB_TYPES[@]|}; do
  DB_JOBNAME=$OUTNAME'_'$DB'_'$RAND
  DB_SH=$JOBDIR/$DB_JOBNAME.sh
  DB_ERR=$LOGDIR/$DB_JOBNAME.err
  DB_LOG=$LOGDIR/$DB_JOBNAME.log
  DB_OUT=$DB_OUTDIR/$DB.vcf
  DB_JOBNAMES=$DB_JOBNAMES','$DB_JOBNAME
  DB_NAME=${DB}FILTER
  DB_SCRIPT='/hpc/cog_bioinf/kloosterman/users/mroosmalen/vcf-explorer/vcf-explorer/vcfexplorer.py'
  if [ $DB == 'SHARCDB' ]; then
    DB_SCRIPT='/hpc/cog_bioinf/kloosterman/users/mroosmalen/vcf-explorer/sharc_database/vcfexplorer.py'
  fi

cat << EOF > $DB_SH
#!/bin/bash

#$ -N $DB_JOBNAME
#$ -cwd
#$ -l h_vmem=$DB_MEM
#$ -l h_rt=$DB_TIME
#$ -e $DB_ERR
#$ -o $DB_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $RF_JOBNAME ]; then
cat << EOF >> $DB_SH
#$ -hold_jid $RF_JOBNAME
EOF
fi

cat << EOF >> $DB_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $RF_OUT.done ]; then
    bash $STEPSDIR/database_filter.sh -v $RF_OUT -o $DB_OUT -e $VENV -f $DB_FLANK -n $DB_NAME -db $DB_SCRIPT

    sed -i s/DB_Count/${DB}_Count/g $DB_OUT
    sed -i s/DB_Frequency/${DB}_Frequency/g $DB_OUT
fi

echo \`date\`: Done
EOF
qsub $DB_SH
done
}

db_merge() {
PASTE_CMD="paste <(grep -v \"^#\" $RF_OUT | sort -k3n | cut -f -6) <(paste <(grep -v \"^#\" $RF_OUT | sort -k3n | cut -f 7 | sed s/PASS//)"
for DB in ${DB_TYPES[@]}; do
    PASTE_CMD=$PASTE_CMD" <(grep -v \"^#\" $DB_OUTDIR/$DB.vcf | sort -k3n | cut -f 7 | sed s/PASS//)"
done
PASTE_CMD=$PASTE_CMD" -d ';' | sed s/^\;\;$/PASS/ /dev/stdin | sed  s/^\;*// /dev/stdin | sed s/\;*$// /dev/stdin)"
PASTE_CMD=$PASTE_CMD" <(paste <(grep -v \"^#\" $RF_OUT | sort -k3n | cut -f 8)"

for DB in ${DB_TYPES[@]}; do
  PASTE_CMD=$PASTE_CMD" <(grep -v \"^#\" $DB_OUTDIR/$DB.vcf | sort -k3n | cut -f 8 | grep -oP \"${DB}_Count=(\d+);${DB}_Frequency=(.+?);\" | sed s/\;$//)"
done
PASTE_CMD=$PASTE_CMD" -d ';' )"
PASTE_CMD=$PASTE_CMD" <(grep -v \"^#\" $RF_OUT | sort -k3n | cut -f 9-) "

cat << EOF > $DB_MERGE_SH
#!/bin/bash

#$ -N $DB_MERGE_JOBNAME
#$ -cwd
#$ -l h_vmem=$DB_MERGE_MEM
#$ -l h_rt=$DB_MERGE_TIME
#$ -e $DB_MERGE_ERR
#$ -o $DB_MERGE_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $DB_JOBNAMES ]; then
cat << EOF >> $DB_MERGE_SH
#$ -hold_jid $DB_JOBNAMES
EOF
fi

cat << EOF >> $DB_MERGE_SH
echo \`date\`: Running on \`uname -n\`

grep "^#" $RF_OUT > $DB_MERGE_OUT
$PASTE_CMD >> $DB_MERGE_OUT

if [ -e $RF_OUT.done ]; then
  NUMBER_OF_LINES_VCF_1=\$(grep -v "^#" $RF_OUT | wc -l | grep -oP "(\d+)")
  NUMBER_OF_LINES_VCF_2=\$(grep -v "^#" $DB_MERGE_OUT | wc -l | grep -oP "(\d+)")

  if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_VCF_2" ]; then
      touch $DB_MERGE_OUT.done
  fi
fi

echo \`date\`: Done
EOF
qsub $DB_MERGE_SH
}

sharc_filter() {
cat << EOF > $SHARC_FILTER_SH
#!/bin/bash

#$ -N $SHARC_FILTER_JOBNAME
#$ -cwd
#$ -l h_vmem=$SHARC_FILTER_MEM
#$ -l h_rt=$SHARC_FILTER_TIME
#$ -e $SHARC_FILTER_ERR
#$ -o $SHARC_FILTER_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $DB_MERGE_JOBNAME ]; then
cat << EOF >> $SHARC_FILTER_SH
#$ -hold_jid $DB_MERGE_JOBNAME
EOF
fi

cat << EOF >> $SHARC_FILTER_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $DB_MERGE_OUT.done ]; then
    bash $STEPSDIR/sharc_filter.sh -v $DB_MERGE_OUT -f '$SHARC_FILTER_QUERY' -o $SHARC_FILTER_OUT
    touch $SHARC_FILTER_OUT.done
fi

echo \`date\`: Done
EOF
qsub $SHARC_FILTER_SH
}

vcf_fasta() {
cat << EOF > $VCF_FASTA_SH
#!/bin/bash

#$ -N $VCF_FASTA_JOBNAME
#$ -cwd
#$ -l h_vmem=$VCF_FASTA_MEM
#$ -l h_rt=$VCF_FASTA_TIME
#$ -e $VCF_FASTA_ERR
#$ -o $VCF_FASTA_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $SHARC_FILTER_JOBNAME ]; then
cat << EOF >> $VCF_FASTA_SH
#$ -hold_jid $SHARC_FILTER_JOBNAME
EOF
fi

cat << EOF >> $VCF_FASTA_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $SHARC_FILTER_OUT.done ]; then
EOF
if [ $VCF_FASTA_MARK = true ]; then
cat << EOF >> $VCF_FASTA_SH
    bash $STEPSDIR/vcf_fasta.sh -v $SHARC_FILTER_OUT -vff $VCF_FASTA_FLANK -vfo $VCF_FASTA_OFFSET -vfs $VCF_FASTA_SCRIPT -vfm -o $VCF_FASTA_OUT
EOF
else
cat << EOF >> $VCF_FASTA_SH
    bash $STEPSDIR/vcf_fasta.sh -v $SHARC_FILTER_OUT -vff $VCF_FASTA_FLANK -vfo $VCF_FASTA_OFFSET -vfs $VCF_FASTA_SCRIPT -o $VCF_FASTA_OUT
EOF
fi
cat << EOF >> $VCF_FASTA_SH

  touch $VCF_FASTA_OUT.done
fi

echo \`date\`: Done
EOF
qsub $VCF_FASTA_SH
}

primer_design() {
cat << EOF > $PRIMER_DESIGN_SH
#!/bin/bash

#$ -N $PRIMER_DESIGN_JOBNAME
#$ -cwd
#$ -l h_vmem=$PRIMER_DESIGN_MEM
#$ -l h_rt=$PRIMER_DESIGN_TIME
#$ -e $PRIMER_DESIGN_ERR
#$ -o $PRIMER_DESIGN_ERR
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $VCF_FASTA_JOBNAME ]; then
cat << EOF >> $PRIMER_DESIGN_SH
#$ -hold_jid $VCF_FASTA_JOBNAME
EOF
fi

cat << EOF >> $PRIMER_DESIGN_SH
echo \`date\`: Running on \`uname -n\`

cd $PRIMER_DESIGN_TMP_DIR

if [ -e $VCF_FASTA_OUT.done ]; then
EOF
if [ -z $PRIMER_DESIGN_TILLING_PARAMS ]; then
cat << EOF >> $PRIMER_DESIGN_SH
    bash $STEPSDIR/primer_design.sh -f $VCF_FASTA_OUT -pdb $PRIMER_DESIGN_BINDIR -pdpt $PRIMER_DESIGN_PCR_TYPE -pdp $PRIMER_DESIGN_PSR -pdgp $PRIMER_DESIGN_GUIX_PROFILE -pdpc $PRIMER_DESIGN_PRIMER3_CORE -pdm $PRIMER_DESIGN_MISPRIMING
EOF
else
cat << EOF >> $PRIMER_DESIGN_SH
    bash $STEPSDIR/primer_design.sh -f $VCF_FASTA_OUT -pdb $PRIMER_DESIGN_BINDIR -pdpt $PRIMER_DESIGN_PCR_TYPE -pdtp $PRIMER_DESIGN_TILLING_PARAMS -pdp $PRIMER_DESIGN_PSR -pdgp $PRIMER_DESIGN_GUIX_PROFILE -pdpc $PRIMER_DESIGN_PRIMER3_CORE -pdm $PRIMER_DESIGN_MISPRIMING
EOF
fi
cat << EOF >> $PRIMER_DESIGN_SH

  touch $PRIMER_DESIGN_OUT.done
  grep -v "FAILED" $PRIMER_DESIGN_TMP_DIR/primers.txt > $PRIMER_DESIGN_OUT
fi

cd $OUTPUTDIR

echo \`date\`: Done
EOF
qsub $PRIMER_DESIGN_SH
}

vcf_primer_filter() {
cat << EOF > $VCF_PRIMER_FILTER_SH
#!/bin/bash

#$ -N $VCF_PRIMER_FILTER_JOBNAME
#$ -cwd
#$ -l h_vmem=$VCF_PRIMER_FILTER_MEM
#$ -l h_rt=$VCF_PRIMER_FILTER_TIME
#$ -e $VCF_PRIMER_FILTER_ERR
#$ -o $VCF_PRIMER_FILTER_LOG
#$ -m ea
#$ -M $MAIL
EOF

if [ ! -z $PRIMER_DESIGN_JOBNAME ]; then
cat << EOF >> $VCF_PRIMER_FILTER_SH
#$ -hold_jid $PRIMER_DESIGN_JOBNAME
EOF
fi

cat << EOF >> $VCF_PRIMER_FILTER_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $PRIMER_DESIGN_OUT.done ]; then
    bash $STEPSDIR/vcf_primer_filter.sh -v $SHARC_FILTER_OUT -p $PRIMER_DESIGN_OUT -o $VCF_PRIMER_FILTER_OUT -s $VCF_PRIMER_FILTER_SCRIPT
    touch $VCF_PRIMER_FILTER.done
fi

echo \`date\`: Done
EOF
qsub $VCF_PRIMER_FILTER_SH
}

prepare
if [ ! -e $MAPPING_MERGE_OUT.done ]; then
    mapping
    mapping_merge
fi
if [ ! -e $SV_OUT.done ]; then
    sv
fi
if [ ! -e $VCF_FILTER_OUT.done ]; then
  vcf_filter
fi
if [ ! -e $BED_ANNOTATION_MERGE_OUT.done ]; then
  vcf_split
  create_bed_annotation_jobs
  annotation_merge
fi
if [ ! -e $RF_OUT.done ]; then
  random_forest
fi
if [ ! -e $DB_MERGE_OUT.done ]; then
  db_filter
  db_merge
fi
if [ ! -e $SHARC_FILTER_OUT.done ]; then
  sharc_filter
fi
if [ ! -e $VCF_FASTA_OUT.done ]; then
  vcf_fasta
fi
if [ ! -e $PRIMER_DESIGN_OUT.done ]; then
  primer_design
fi
if [ ! -e $VCF_PRIMER_FILTER_OUT.done ]; then
  vcf_primer_filter
fi
