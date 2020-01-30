#!/bin/bash

usage() {
echo "
Required parameters:
    -f|--fastqdir                                        Path to fastq directory
    -m|--mail                                            Email adress

Optional parameters:

GENERAL
    -h|--help                                            Shows help
    -sd|--sharc_dir                                      Path to sharc directory [$SHARCDIR]
    -v|--venv                                            Path to virtual env [$VENV]
    -o|--outputdir                                       Path to output directory [$OUTPUTDIR]
    -sm|--sample_name                                    Name of the sample [From FASTQ or OUTPUTDIR ]
    -dc|--dont_clean                                     Don't clean up the mapping tmp dir []

MAPPING
    -mt|--mapping_threads                                Number of threads [$MAPPING_THREADS]
    -mhr|--mapping_h_rt                                  Mapping time [$MAPPING_TIME]
    -mhv|--mapping_h_vmem                                Mapping memory [$MAPPING_MEM]
    -mr|--mapping_ref                                    Mapping reference [$MAPPING_REF]
    -mm|--minimap2                                       Path to minimap2 [$MAPPING_MINIMAP2]
    -mms|--minimap2_settings                             Minimap2 settings [$MAPPING_MINIMAP2_SETTINGS]
    -msb|--mapping_sambamba                              Path to sambamba [$MAPPING_SAMBAMBA]

MAPPING MERGE
    -mmt|--mapping_merge_threads                         Number of threads [$MAPPING_MERGE_THREADS]
    -mmhv|--mapping_merge_h_vmem                         Mapping merge memory [$MAPPING_MERGE_MEM]
    -mmhr|--mapping_merge_h_rt                           Mapping merge time [$MAPPING_MERGE_TIME]
    -mmsb|--mapping_merge_sambamba                       Path to sambamba [$MAPPING_MERGE_SAMBAMBA]

COVERAGE CALCULATION
    -cct|--coverage_calculation_threads                  Number of threads [$COVERAGE_CALCULATION_THREADS]
    -cchv|--coverage_calculation_h_vmem                  Coverage calculation memory [$COVERAGE_CALCULATION_MEM]
    -cchr|--coverage_calculation_h_rt                    Coverage calculation time [$COVERAGE_CALCULATION_TIME]
    -ccs|--coverage_calculation_sambamba                 Path to sambamba [$COVERAGE_CALCULATION_SAMBAMBA]
    -ccb|--coverage_calculation_bed                      Path to bed file [$COVERAGE_CALCULATION_BED]
    -ccss|--coverage_calculation_sambamba_settings       Sambamba settings [$COVERAGE_CALCULATION_SAMBAMBA_SETTINGS]

SV_CALLING
    -svt|--sv_threads                                    Number of threads [$SV_THREADS]
    -svhv|--sv_h_vmem                                    SV calling memory [$SV_MEM]
    -svhr|--sv_h_rt                                      SV calling time [$SV_TIME]
    -svc|--sv_config                                     Path to config file [$SV_CONFIG]
    -svs|--sv_sambamba                                   Path to sambamba [$SV_SAMBAMBA]

VCF_FILTER
    -vfhv|--vcf_filter_h_vmem                            VCF filter memory [$VCF_FILTER_MEM]
    -vfhr|--vcf_filter_h_rt                              VCF filter time [$VCF_FILTER_TIME]
    -vfq|--vcf_filter_query                              VCF Filter query [$VCF_FILTER_QUERY]

VCF_SPLIT
    -vshv|--vcf_split_h_vmem                             VCF split memory [$VCF_SPLIT_MEM]
    -vshr|--vcf_split_h_rt                               VCF split time [$VCF_SPLIT_TIME]
    -vsl|--vcf_split_lines                               Number of lines per split [$VCF_SPLIT_LINES]

CREATE_BED_ANNOTATION
    -cbahv|--create_bed_annotation_h_vmem                Create BED memory [$CREATE_BED_ANNOTATION_MEM]
    -cbahr|--create_bed_annotation_h_rt                  Create BED time [$CREATE_BED_ANNOTATION_TIME]

BED_ANNOTATION
    -bahv|--bed_annotation_h_vmem                        BED annotation memory [$BED_ANNOTATION_MEM]
    -bahr|--bed_annotation_h_rt                          BED annotation time [$BED_ANNOTATION_TIME]
    -baf|--bed_annotation_files                          Path to the directory with the feature bed files [$BED_ANNOTATION_FILES]
    -bas|--bed_annotation_script                         Path to get_closest_feature.py script [$BED_ANNOTATION_SCRIPT]

BED_ANNOTATION MERGE
    -bamhv|--bed_annotation_merge_h_vmem                 Merge annotation memory [$BED_ANNOTATION_MERGE_MEM]
    -bamhr|--bed_annotation_merge_h_rt                   Merge annotation time [$BED_ANNOTATION_MERGE_TIME]

RANDOM_FOREST
    -rfhv|--rf_h_vmem                                    Random forest memory [$RF_MEM]
    -rfhr|--rf_h_rt                                      Random forest time [$RF_TIME]
    -rffts|--rf_ft_script                                Path to create_features_table.pl script [$RF_CREATE_FEATURE_TABLE_SCRIPT]
    -rfs|--rf_script                                     Path to run_randomForest.R script [$RF_SCRIPT]
    -rfps|--rf_p_script                                  Path to add_predict_annotation.py script [$RF_ADD_PREDICT_SCRIPT]

DB FILTER
    -dbhv|--db_h_vmem                                    DB filter memory [$DB_MEM]
    -dbhr|--db_h_rt                                      DB filter time [$DB_TIME]
    -dbf|--db_flank                                      Database filter flank [$DB_FLANK]
    -dbse|--db_sample_exclusion                          List of samples to exclude from the SHARC database (e.g '[Sample1,Sample2]') [$DB_EXCLUSION]

DB MERGE
    -dbmhv|--db_merge_h_vmem                             Merge DB annotation memory [$DB_MERGE_MEM]
    -dbmhr|--db_merge_h_rt                               Merge DB annotation time [$DB_MERGE_TIME]

SHARC_FILTER
    -sfhv|--sharc_filter_h_vmem                          SHARC Filter memory [$SHARC_FILTER_MEM]
    -sfhr|--sharc_filter_h_rt                            SHARC Filter time [$SHARC_FILTER_TIME]
    -sfq|--sharc_filter_query                            SHARC Filter query [$SHARC_FILTER_QUERY]

SOMATIC FEATURE SELECTION
    -sfshv|--somatic_feature_selection_h_vmem                   Somatic feature selection memory [$SOMATIC_FEATURE_SELECTION_MEM]
    -sfshr|--somatic_feature_selection_h_rt                     Somatic feature selection time [$SOMATIC_FEATURE_SELECTION_TIME]
    -sfsf|--somatic_feature_selection_flank                     Somatic feature selection flank [$SOMATIC_FEATURE_SELECTION_FLANK]
    -sfsp|--somatic_feature_selection_support                   Somatic feature selection support [$SOMATIC_FEATURE_SELECTION_SUPPORT]
    -sfss|--somatic_feature_selection_script                    Path to somatic_feature_selection.py [$SOMATIC_FEATURE_SELECTION_SCRIPT]
    -sfsid|--somatic_feature_selection_icgc_directory           Path to ICGC database directory [$SOMATIC_FEATURE_SELECTION_ICGC_DIRECTORY]
    -sfscb|--somatic_feature_selection_cosmic_breakpoints       Path to COSMIC database .csv file [$SOMATIC_FEATURE_SELECTION_COSMIC_BREAKPOINTS]

SOMATIC_RANKING
    -srhv|--somatic_ranking_h_vmem                       Somatic ranking memory [$SOMATIC_RANKING_MEM]
    -srhr|--somatic_ranking_h_rt                         Somatic ranking time [$SOMATIC_RANKING_TIME]
    -srs|--somatic_ranking_script                        Path to somatic_ranking.py [$SOMATIC_RANKING_SCRIPT]

VCF_TO_FASTA
    -v2fhv|--vcf_fasta_h_vmem                            VCF to FASTA memory [$VCF_FASTA_MEM]
    -v2fhr|--vcf_fasta_h_rt                              VCF to FASTA time [$VCF_FASTA_TIME]
    -v2fo|--vcf_fasta_offset                             VCF to FASTA offset [$VCF_FASTA_OFFSET]
    -v2ff|--vcf_fasta_flank                              VCF to FASTA flank [$VCF_FASTA_FLANK]
    -v2fm|--vcf_fasta_mask                               VCF to FASTA mask [$VCF_FASTA_MASK]
    -v2fs|--vcf_fasta_script                             Path to vcf_to_fasta.py [$VCF_FASTA_SCRIPT]

PRIMER DESIGN
    -pdhv|--primer_design_h_vmem                         Primer design memory [$PRIMER_DESIGN_MEM]
    -pdhr|--primer_design_h_rt                           Primer design time [$PRIMER_DESIGN_TIME]
    -pdd|--primer_design_dir                             Path to primer3 directory [$PRIMER_DESIGN_DIR]
    -pdb|--primer_design_bindir                          Path to primer3 bin dir [$PRIMER_DESIGN_BINDIR]
    -pdpt|--primer_design_pcr_type                       PCR type [$PRIMER_DESIGN_PCR_TYPE]
    -pdtp|--primer_design_tilling_params                 Tilling params [$PRIMER_DESIGN_TILLING_PARAMS]
    -pdp|--primer_design_psr                             PSR [$PRIMER_DESIGN_PSR]
    -pdgp|--primer_design_guix_profile                   Path to guix profile [$PRIMER_DESIGN_GUIX_PROFILE]
    -pdpc|--primer_design_primer3_core                   Path to primer3_core [$PRIMER_DESIGN_PRIMER3_CORE]
    -pdm|--primer_design_mispriming                      Path to mispriming [$PRIMER_DESIGN_MISPRIMING]

VCF PRIMER FILTER
    -vpfhv|--vcf_primer_filter_h_vmem                    VCF Primer Filter memory [$VCF_PRIMER_FILTER_MEM]
    -vpfhr|--vcf_primer_filter_h_rt                      VCF Primer Filter time [$VCF_PRIMER_FILTER_TIME]
    -vpfs|--vcf_primer_filter_script                     Path to vcf_primer_filter.py [$VCF_PRIMER_FILTER_SCRIPT]

PRIMER_RANKING
    -prhv|--primer_ranking_h_vmem                        Primer ranking memory [$PRIMER_RANKING_MEM]
    -prhr|--primer_ranking_h_rt                          Primer ranking time [$PRIMER_RANKING_TIME]
    -prs|--primer_ranking_script                         Path to primer ranking.py [$PRIMER_RANKING_SCRIPT]

"
exit
}

POSITIONAL=()

# GENERAL DEFAULTS
SHARCDIR=$(dirname ${BASH_SOURCE[0]})
#SHARCDIR='/hpc/cog_bioinf/kloosterman/common_scripts/sharc/'
VENV=$SHARCDIR/venv/bin/activate
STEPSDIR=$SHARCDIR/steps
SCRIPTSDIR=$SHARCDIR/scripts
FILESDIR=$SHARCDIR/files
OUTPUTDIR='./'
SAMBAMBA='/hpc/local/CentOS7/cog_bioinf/sambamba_v0.6.5/sambamba'
DONT_CLEAN=false

# MAPPING DEFAULTS
MAPPING_THREADS=1
MAPPING_MEM=20G
MAPPING_TIME=2:0:0
MAPPING_REF='/hpc/cog_bioinf/GENOMES/Homo_sapiens.GRCh37.GATK.illumina/Homo_sapiens.GRCh37.GATK.illumina.fasta'
MAPPING_MINIMAP2='/hpc/cog_bioinf/cuppen/personal_data/jvalleinclan/tools_kloosterman/minimap2_v2.12/minimap2'
MAPPING_MINIMAP2_SETTINGS='-x map-ont -a --MD'
#MAPPING_MINIMAP2_SETTINGS='-a --MD --no-long-join -r50'
MAPPING_SAMBAMBA=$SAMBAMBA

# MAPPING MERGE DEFAULTS
MAPPING_MERGE_THREADS=8
MAPPING_MERGE_MEM=20G
MAPPING_MERGE_TIME=3:0:0
MAPPING_MERGE_SAMBAMBA=$SAMBAMBA

# COVERAGE CALCULATION DEFAULTS
COVERAGE_CALCULATION_THREADS=8
COVERAGE_CALCULATION_MEM=20G
COVERAGE_CALCULATION_TIME=4:0:0
COVERAGE_CALCULATION_SAMBAMBA=$SAMBAMBA
COVERAGE_CALCULATION_BED=$FILESDIR/human_hg19.bed
COVERAGE_CALCULATION_SAMBAMBA_SETTINGS='base --min-coverage=0'

# SV DEFAULTS
SV_THREADS=8
SV_MEM=30G
SV_TIME=4:0:0
SV_CONFIG=$FILESDIR/config_NanoSV_SHARC.ini
SV_SAMBAMBA=$SAMBAMBA

# VCF_FILTER DEFAULTS
VCF_FILTER_MEM=2G
VCF_FILTER_TIME=0:30:0
VCF_FILTER_QUERY='$7 == "PASS" && $1 !~ /(Y|MT)/ && $5 !~ /(Y|MT):/ && $5 != "<INS>"'

# VCF_SPLIT DEFAULTS
VCF_SPLIT_MEM=2G
VCF_SPLIT_TIME=0:30:0
VCF_SPLIT_LINES=100

# CREATE_BED_ANNOTATION DEFAULTS
CREATE_BED_ANNOTATION_MEM=2G
CREATE_BED_ANNOTATION_TIME=0:30:0

# BED_ANNOTATION DEFAULTS
BED_ANNOTATION_MEM=10G
BED_ANNOTATION_TIME=1:0:0
BED_ANNOTATION_FILES=$FILESDIR
BED_ANNOTATION_SCRIPT=$SCRIPTSDIR/get_closest_feature.py

# BED_ANNOTATION_MERGE DEFAULTS
BED_ANNOTATION_MERGE_MEM=2G
BED_ANNOTATION_MERGE_TIME=0:30:0

# RANDOM_FOREST DEFAULTS
RF_MEM=2G
RF_TIME=0:30:0
RF_CREATE_FEATURE_TABLE_SCRIPT=$SCRIPTSDIR/create_features_table.py
RF_SCRIPT=$SCRIPTSDIR/run_randomForest.R
RF_ADD_PREDICT_SCRIPT=$SCRIPTSDIR/add_predict_annotation.py

# DB DEFAULTS
DB_MEM=2G
DB_TIME=0:30:0
DB_TYPES=("REFDB" "SHARCDB")
DB_FLANK=100
DB_EXCLUSION=None

# DB_MERGE
DB_MERGE_MEM=2G
DB_MERGE_TIME=0:30:0

# SHARC FILTER DEFAULTS
SHARC_FILTER_MEM=2G
SHARC_FILTER_TIME=0:30:0
SHARC_FILTER_QUERY='grep "PREDICT_LABEL=1" | grep -v "SHARCDBFILTER" | grep -v "REFDBFILTER"'

#ICGC FILTER DEFAULTS
SOMATIC_FEATURE_SELECTION_MEM=10G
SOMATIC_FEATURE_SELECTION_TIME=0:10:0
SOMATIC_FEATURE_SELECTION_FLANK=200
SOMATIC_FEATURE_SELECTION_SCRIPT=$SCRIPTSDIR/somatic_feature_selection.py
SOMATIC_FEATURE_SELECTION_ICGC_DIRECTORY=$FILESDIR
SOMATIC_FEATURE_SELECTION_COSMIC_BREAKPOINTS=$FILESDIR
SOMATIC_FEATURE_SELECTION_SUPPORT=None

#SOMATIC_RANKING VCF_FASTA_DEFAULTS
SOMATIC_RANKING_MEM=2G
SOMATIC_RANKING_TIME=0:5:0
SOMATIC_RANKING_SCRIPT=$SCRIPTSDIR/somatic_ranking.py

# VCF_FASTA_DEFAULTS
VCF_FASTA_MEM=2G
VCF_FASTA_TIME=2:0:0
VCF_FASTA_FLANK=200
VCF_FASTA_OFFSET=0
VCF_FASTA_MARK=false
VCF_FASTA_SCRIPT=$SCRIPTSDIR/vcf_to_fasta.py

# PRIMER_DESIGN_DEFAULTS
PRIMER_DESIGN_MEM=2G
PRIMER_DESIGN_TIME=1:0:0
PRIMER_DESIGN_DIR='/hpc/cog_bioinf/cuppen/personal_data/jvalleinclan/tools_kloosterman/primer3/'
PRIMER_DESIGN_BINDIR=$PRIMER_DESIGN_DIR/primers
PRIMER_DESIGN_PCR_TYPE='single'
PRIMER_DESIGN_TILLING_PARAMS=''
PRIMER_DESIGN_PSR='60-100'
PRIMER_DESIGN_GUIX_PROFILE=$PRIMER_DESIGN_DIR/emboss/.guix-profile
PRIMER_DESIGN_PRIMER3_CORE=$PRIMER_DESIGN_DIR/primer3/src/primer3_core
PRIMER_DESIGN_MISPRIMING=$PRIMER_DESIGN_DIR/repbase/current/empty.ref

# VCF PRIMER FILTER DEFAULTS
VCF_PRIMER_FILTER_MEM=2G
VCF_PRIMER_FILTER_TIME=0:30:0
VCF_PRIMER_FILTER_SCRIPT=$SCRIPTSDIR/vcf_primer_filter.py

# PRIMER_RANKING DEFAULTS
PRIMER_RANKING_MEM=1G
PRIMER_RANKING_TIME=0:30:0
PRIMER_RANKING_SCRIPT=$SCRIPTSDIR/primer_ranking.py


# PRIMER_RANKING DEFAULTS
TOP20_REPORT_MEM=1G
TOP20_REPORT_TIME=0:45:0
TOP20_REPORT_SCRIPT=$SCRIPTSDIR/top20_report.py

# CHECK_SHARC FILTER DEFAULTS
CHECK_SHARC_MEM=1G
CHECK_SHARC_TIME=0:5:0

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
    -sm|--sample_name)
    OUTNAME="$2"
    shift # past argument
    shift # past value
    ;;
    -dc|--dont_clean)
    DONT_CLEAN=true
    shift # past argument
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
    -msb|--mapping_sambamba)
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
    -mmsb|--mapping_merge_sambamba)
    MAPPING_MERGE_SAMBAMBA="$2"
    shift # past argument
    shift # past value
    ;;
# COVERAGE CALCULATION OPTIONS
    -cct|--coverage_calculation_threads)
    COVERAGE_CALCULATION_THREADS="$2"
    shift # past argument
    shift # past value
    ;;
    -cchv|--coverage_calculation_h_vmem)
    COVERAGE_CALCULATION_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -cchr|--coverage_calculation_h_rt)
    COVERAGE_CALCULATION_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -ccs|--coverage_calculation_sambamba)
    COVERAGE_CALCULATION_SAMBAMBA="$2"
    shift # past argument
    shift # past value
    ;;
    -ccb|--coverage_calculation_bed)
    COVERAGE_CALCULATION_BED="$2"
    shift # past argument
    shift # past value
    ;;
    -ccss|--coverage_calculation_sambamba_settings)
    COVERAGE_CALCULATION_SAMBAMBA_SETTINGS="$2"
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
    -dbse|--db_sample_exclusion)
    DB_EXCLUSION="$2"
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
# SOMATIC_FEATURE_SELECTION OPTIONS
    -sfshv|--somatic_feature_selection_h_vmem)
    SOMATIC_FEATURE_SELECTION_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -sfshr|--somatic_feature_selection_h_rt)
    SOMATIC_FEATURE_SELECTION_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -sfsf|--somatic_feature_selection_flank)
    SOMATIC_FEATURE_SELECTION_FLANK="$2"
    shift # past argument
    shift # past value
    ;;
    -sfsp|--somatic_feature_selection_support)
    SOMATIC_FEATURE_SELECTION_SUPPORT="$2"
    shift # past argument
    shift # past value
    ;;
    -sfss|--somatic_feature_selection_script)
    SOMATIC_FEATURE_SELECTION_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
    -sfsid|--somatic_feature_selection_icgc_directory)
    SOMATIC_FEATURE_SELECTION_ICGC_DIRECTORY="$2"
    shift # past argument
    shift # past value
    ;;
    -sfscb|--somatic_feature_selection_cosmic_breakpoints)
    SOMATIC_FEATURE_SELECTION_COSMIC_BREAKPOINTS="$2"
    shift # past argument
    shift # past value
    ;;
# SOMATIC_RANKING OPTIONS
    -srhv|--somatic_ranking_h_vmem)
    SOMATIC_RANKING_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -srhr|--somatic_ranking_h_rt)
    SOMATIC_RANKING_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -srs|--somatic_ranking_script)
    SOMATIC_RANKING_SCRIPT="$2"
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
# PRIMER_RANKING OPTIONS
    -prhv|--primer_ranking_h_vmem)
    PRIMER_RANKING_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -prhr|--primer_ranking_h_rt)
    PRIMER_RANKING_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -prs|--primer_ranking_script)
    PRIMER_RANKING_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
    
# TOP 20 REPORT OPTIONS
    -tophv|--top_report_h_vmem)
    TOP20_REPORT_MEM="$2"
    shift # past argument
    shift # past value
    ;;
    -tophr|--top_report_h_rt)
    TOP20_REPORT_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -tops|--top_report_script)
    TOP20_REPORT_SCRIPT="$2"
    shift # past argument
    shift # past value
    ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
if [ -z $FASTQDIR ]; then
  echo "Missing -f|--fastqdir parameter"
  usage
elif [ -z $MAIL ]; then
  echo "Missing -m|--mail parameter"
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

if [ ! $OUTNAME ]; then
  if [ "$(head -n 1 $FASTQDIR/fastq_0.fastq | cut -d " " -f 3 | cut -d "=" -f 1)" == "sampleid" ]; then
    OUTNAME="$(head -n 1 $FASTQDIR/fastq_0.fastq | cut -d " " -f 3 | cut -d "=" -f 2)"
  else
    OUTNAME=$(basename $OUTPUTDIR)
  fi
fi

RAND=$(cat /dev/urandom | tr -cd 'a-zA-Z0-9' | head -c 5)
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

COVERAGE_CALCULATION_JOBNAME=$OUTNAME'_COVERAGECALCULATION_'$RAND
COVERAGE_CALCULATION_SH=$JOBDIR/$COVERAGE_CALCULATION_JOBNAME.sh
COVERAGE_CALCULATION_ERR=$LOGDIR/$COVERAGE_CALCULATION_JOBNAME.err
COVERAGE_CALCULATION_LOG=$LOGDIR/$COVERAGE_CALCULATION_JOBNAME.log
COVERAGE_CALCULATION_OUT=${MAPPING_MERGE_OUT/.sorted.bam/.depth}

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
SHARC_FILTER_OUT=$SV_TMP_DIR/$(basename ${SV_OUT/.vcf/.SHARC.vcf})


SOMATIC_FEATURE_SELECTION_COSMIC_BREAKPOINTS=$SOMATIC_FEATURE_SELECTION_COSMIC_BREAKPOINTS/${SOMATIC_FEATURE_SELECTION_CANCER_TYPE}_COSMIC_SVs.csv
SOMATIC_FEATURE_SELECTION_JOBNAME=$OUTNAME'_SOMATIC_FEATURE_SELECTION_'$RAND
SOMATIC_FEATURE_SELECTION_SH=$JOBDIR/$SOMATIC_FEATURE_SELECTION_JOBNAME.sh
SOMATIC_FEATURE_SELECTION_ERR=$LOGDIR/$SOMATIC_FEATURE_SELECTION_JOBNAME.err
SOMATIC_FEATURE_SELECTION_LOG=$LOGDIR/$SOMATIC_FEATURE_SELECTION_JOBNAME.log
SOMATIC_FEATURE_SELECTION_ATTRIBUTES_OUT=$RF_OUTDIR/'somatic_features_table.txt'
SOMATIC_FEATURE_SELECTION_OUT=$SV_TMP_DIR/$(basename ${SHARC_FILTER_OUT/.vcf/.ICGC.vcf})

SOMATIC_RANKING_JOBNAME=$OUTNAME'_SOMATICRANKING_'$RAND
SOMATIC_RANKING_SH=$JOBDIR/$SOMATIC_RANKING_JOBNAME.sh
SOMATIC_RANKING_ERR=$LOGDIR/$SOMATIC_RANKING_JOBNAME.err
SOMATIC_RANKING_LOG=$LOGDIR/$SOMATIC_RANKING_JOBNAME.log
SOMATIC_RANKING_OUT=$SV_DIR/$(basename ${SOMATIC_FEATURE_SELECTION_OUT/.vcf/.SHARC_RANK.vcf})

VCF_FASTA_OUTDIR=$OUTPUTDIR/primers
VCF_FASTA_JOBNAME=$OUTNAME'_VCFFASTA_'$RAND
VCF_FASTA_SH=$JOBDIR/$VCF_FASTA_JOBNAME.sh
VCF_FASTA_ERR=$LOGDIR/$VCF_FASTA_JOBNAME.err
VCF_FASTA_LOG=$LOGDIR/$VCF_FASTA_JOBNAME.log
VCF_FASTA_OUT=$VCF_FASTA_OUTDIR/$(basename ${SOMATIC_RANKING_OUT/.vcf/.fasta})

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
VCF_PRIMER_FILTER_OUT=$VCF_PRIMER_FILTER_OUTDIR/$(basename ${SOMATIC_RANKING_OUT/.vcf/.primers.vcf})

PRIMER_RANKING_JOBNAME=$OUTNAME'_PRIMERRANKING_'$RAND
PRIMER_RANKING_SH=$JOBDIR/$PRIMER_RANKING_JOBNAME.sh
PRIMER_RANKING_ERR=$LOGDIR/$PRIMER_RANKING_JOBNAME.err
PRIMER_RANKING_LOG=$LOGDIR/$PRIMER_RANKING_JOBNAME.log
PRIMER_RANKING_OUT=$PRIMER_DESIGN_OUTDIR/$(basename ${PRIMER_DESIGN_OUT/.primers/.ranked.primers})

TOP20_REPORT_JOBNAME=$OUTNAME'_TOP20_'$RAND
TOP20_REPORT_SH=$JOBDIR/$TOP20_REPORT_JOBNAME.sh
TOP20_REPORT_ERR=$LOGDIR/$TOP20_REPORT_JOBNAME.err
TOP20_REPORT_LOG=$LOGDIR/$TOP20_REPORT_JOBNAME.log
TOP20_REPORT_OUT_TABLE=$OUTPUTDIR/$OUTNAME.sharc.top20.tsv
TOP20_REPORT_OUT_VCF=$OUTPUTDIR/$OUTNAME.sharc.top20.vcf




CHECK_SHARC_OUTDIR=$OUTPUTDIR
CHECK_SHARC_JOBNAME=$OUTNAME'_CHECKSHARC_'$RAND
CHECK_SHARC_SH=$JOBDIR/$CHECK_SHARC_JOBNAME.sh
CHECK_SHARC_ERR=$LOGDIR/$CHECK_SHARC_JOBNAME.err
CHECK_SHARC_LOG=$LOGDIR/$CHECK_SHARC_JOBNAME.log
CHECK_SHARC_OUT=$CHECK_SHARC_OUTDIR/$OUTNAME'.check'

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
if [ -d $PRIMER_DESIGN_TMP_DIR ];then
  rm -r $PRIMER_DESIGN_TMP_DIR
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


ID=\$((\$SGE_TASK_ID-1))

echo \`date\`: Running on \`uname -n\`

if [ -e $FASTQDIR/fastq_\$ID.fastq ]; then
    if [ ! -e $MAPPING_TMP_DIR/\$ID.sorted.bam.done ]; then
	bash $STEPSDIR/minimap2.sh \\
	-f $FASTQDIR/fastq_\$ID.fastq \\
	-t $MAPPING_THREADS \\
	-m $MAPPING_MINIMAP2 \\
	-r $MAPPING_REF \\
  -p "$MAPPING_MINIMAP2_SETTINGS" \\
	-s $MAPPING_SAMBAMBA \\
  -n $OUTNAME \\
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
        if [ \$NUMBER_OF_DONE_FILES -eq 1 ]; then
            cp $MAPPING_TMP_DIR/*.sorted.bam $MAPPING_MERGE_OUT
            cp $MAPPING_TMP_DIR/*.sorted.bam.bai $MAPPING_MERGE_OUT.bai
        else
            $MAPPING_SAMBAMBA merge -t $MAPPING_THREADS $MAPPING_MERGE_OUT $MAPPING_TMP_DIR/*.sorted.bam
        fi
    else
	     echo "Not enough done files found"
       exit
    fi
    NUMBER_OF_READS_IN_BAMS=\$(for BAM in $MAPPING_TMP_DIR/*.bam; do $MAPPING_SAMBAMBA view \$BAM | cut -f 1 | sort | uniq | wc -l; done | awk '{ SUM += \$1} END { print SUM }')
    NUMBER_OF_READS_IN_MERGED_BAM=\$($MAPPING_SAMBAMBA view $MAPPING_MERGE_OUT | cut -f 1 | sort | uniq | wc -l)
    if [ "\$NUMBER_OF_READS_IN_BAMS" == "\$NUMBER_OF_READS_IN_MERGED_BAM" ]; then
	     touch $MAPPING_MERGE_OUT.done
    else
      echo "The number of reads in the tmp bam files (\$NUMBER_OF_READS_IN_BAMS) is different than the number of reads in the merged bam file (\$NUMBER_OF_READS_IN_MERGED_BAM)" >&2
    fi

fi

echo \`date\`: Done
EOF
qsub $MAPPING_MERGE_SH
}

coverage_calculation() {
cat << EOF > $COVERAGE_CALCULATION_SH
#!/bin/bash

#$ -N $COVERAGE_CALCULATION_JOBNAME
#$ -cwd
#$ -pe threaded $COVERAGE_CALCULATION_THREADS
#$ -l h_vmem=$COVERAGE_CALCULATION_MEM
#$ -l h_rt=$COVERAGE_CALCULATION_TIME
#$ -e $COVERAGE_CALCULATION_ERR
#$ -o $COVERAGE_CALCULATION_LOG
EOF

if [ ! -z $MAPPING_MERGE_JOBNAME ]; then
cat << EOF >> $COVERAGE_CALCULATION_SH
#$ -hold_jid $MAPPING_MERGE_JOBNAME
EOF
fi

cat << EOF >> $COVERAGE_CALCULATION_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $MAPPING_MERGE_OUT.done ]; then
    bash $STEPSDIR/calculate_coverage.sh -b $MAPPING_MERGE_OUT -t $COVERAGE_CALCULATION_THREADS -s $COVERAGE_CALCULATION_SAMBAMBA -bed $COVERAGE_CALCULATION_BED -p "$COVERAGE_CALCULATION_SAMBAMBA_SETTINGS" -o $COVERAGE_CALCULATION_OUT
    NUMBER_OF_LINES_FILE_1=\$(wc -l $COVERAGE_CALCULATION_BED | grep -oP "(^\d+)")
    NUMBER_OF_LINES_FILE_2=\$(wc -l $COVERAGE_CALCULATION_OUT | grep -oP "(^\d+)")
    NUMBER_OF_LINES_FILE_2=\$((NUMBER_OF_LINES_FILE_2-2))

    if [ "\$NUMBER_OF_LINES_FILE_1" == "\$NUMBER_OF_LINES_FILE_2" ]; then
        touch $COVERAGE_CALCULATION_OUT.done
    else
      echo "The number of lines in the bed file (\$NUMBER_OF_LINES_FILE_1) is different than the number of lines in the coverage file (\$NUMBER_OF_LINES_FILE_2)" >&2
    fi
fi

echo \`date\`: Done
EOF
qsub $COVERAGE_CALCULATION_SH
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
    NUMBER_OF_LINES_VCF=\$(grep -v "^#" $SV_OUT | wc -l | grep -oP "(^\d+)")
    if [ \$NUMBER_OF_LINES_VCF != 0 ]; then
      touch $SV_OUT.done
    fi
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
    NUMBER_OF_LINES_VCF_1=\$(grep -v "^#" $VCF_FILTER_OUT | wc -l | grep -oP "(^\d+)")
    NUMBER_OF_LINES_VCF_2=\$(cat $VCF_SPLIT_OUTDIR/*.vcf | grep -v "^#" | wc -l | grep -oP "(^\d+)")

    if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_VCF_2" ]; then
        touch $VCF_SPLIT_OUT.done
    else
        echo "The number of lines in the original vcf file (\$NUMBER_OF_LINES_VCF_1) is different than the number of lines in the splitted vcf files (\$NUMBER_OF_LINES_VCF_2)" >&2
    fi
fi

echo \`date\`: Done
EOF
qsub $VCF_SPLIT_SH
}

create_bed_annotation_jobs() {
for BED in $BED_ANNOTATION_FILES/*.feature.bed; do
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
EOF

if [ ! -z $VCF_SPLIT_JOBNAME ]; then
cat << EOF >> $CREATE_BED_ANNOTATION_SH
#$ -hold_jid $VCF_SPLIT_JOBNAME
EOF
fi

cat << EOF >> $CREATE_BED_ANNOTATION_SH

echo \`date\`: Running on \`uname -n\`
if [ -e $VCF_SPLIT_OUT.done ]; then
  bash $STEPSDIR/create_bed_annotation_jobs.sh -j $BED_ANNOTATION_JOBNAMES -f $BED_ANNOTATION_FILES -v $VCF_SPLIT_OUTDIR -o $OUTPUTDIR -s $STEPSDIR -b $BED_ANNOTATION_SCRIPT -m $MAIL -i $BED_ANNOTATION_MERGE_JOBNAME -vm $BED_ANNOTATION_MEM -rt $BED_ANNOTATION_TIME -e $VENV
fi
echo \`date\`: Done
EOF
qsub $CREATE_BED_ANNOTATION_SH
}

annotation_merge() {
PASTE_CMD="paste <(paste <(grep -v \"^#\" $VCF_FILTER_OUT | sort -k3n | cut -f -8)"
for BED in $BED_ANNOTATION_FILES/*.feature.bed; do
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
EOF

if [ ! -z $BED_ANNOTATION_JOBNAMES ]; then
cat << EOF >> $BED_ANNOTATION_MERGE_SH
#$ -hold_jid $BED_ANNOTATION_JOBNAMES
EOF
fi

cat << EOF >> $BED_ANNOTATION_MERGE_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $VCF_SPLIT_OUT.done ]; then
  NUMBER_OF_SPLIT_FILES=\$(ls -l $VCF_SPLIT_OUTDIR/*.*.vcf | wc -l)
  NUMBER_OF_DONE_FILES=\$(ls -l $VCF_SPLIT_OUTDIR/*.done | wc -l)
  if [ "\$NUMBER_OF_SPLIT_FILES" == "\$NUMBER_OF_DONE_FILES" ]; then
      HEADERS=\$(cat $VCF_SPLIT_OUTDIR/1.*.vcf | grep "^#" | grep "_DISTANCE")
      grep "^#" $VCF_FILTER_OUT | awk -v headers="\$HEADERS" '/^##FORMAT/ && !modif { print headers; modif=1 } {print}' > $BED_ANNOTATION_MERGE_OUT
      $PASTE_CMD
  fi

  NUMBER_OF_LINES_VCF_1=\$(grep -v "^#" $VCF_FILTER_OUT | wc -l | grep -oP "(^\d+)")
  NUMBER_OF_LINES_VCF_2=\$(grep -v "^#" $BED_ANNOTATION_MERGE_OUT | wc -l | grep -oP "(^\d+)")

  if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_VCF_2" ]; then
      touch $BED_ANNOTATION_MERGE_OUT.done
  else
      echo "The number of lines in the original vcf file (\$NUMBER_OF_LINES_VCF_1) is different than the number of lines in the annotated vcf file (\$NUMBER_OF_LINES_VCF_2)" >&2
  fi
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
EOF

if [ ! -z $BED_ANNOTATION_MERGE_JOBNAME ] && [ ! -z $COVERAGE_CALCULATION_JOBNAME ]; then
cat << EOF >> $RF_SH
#$ -hold_jid $BED_ANNOTATION_MERGE_JOBNAME,$COVERAGE_CALCULATION_JOBNAME
EOF
fi

cat << EOF >> $RF_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $BED_ANNOTATION_MERGE_OUT.done ] && [ -e $COVERAGE_CALCULATION_OUT.done ]; then
    MEANCOV=\$(head -n 1 $COVERAGE_CALCULATION_OUT | cut -f 2 -d'=' | grep -oP "(^\d+)")
    if [ \$MEANCOV -eq 0 ]; then
      MEANCOV=1
    fi
    bash $STEPSDIR/randomForest.sh -v $BED_ANNOTATION_MERGE_OUT -m \$MEANCOV -o $RF_OUT -d $RF_OUTDIR -ft $RF_CREATE_FEATURE_TABLE_SCRIPT -rf $RF_SCRIPT -ap $RF_ADD_PREDICT_SCRIPT -e $VENV

    NUMBER_OF_LINES_VCF_1=\$(grep -v "^#" $BED_ANNOTATION_MERGE_OUT | wc -l | grep -oP "(^\d+)")
    NUMBER_OF_LINES_VCF_2=\$(grep -v "^#" $RF_OUT | wc -l | grep -oP "(^\d+)")

    if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_VCF_2" ]; then
        touch $RF_OUT.done
    else
        echo "The number of lines in the annotated vcf file (\$NUMBER_OF_LINES_VCF_1) is different than the number of lines in the random forest vcf file (\$NUMBER_OF_LINES_VCF_2)" >&2
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
  DB_SCRIPT=$SHARCDIR/vcf-explorer/vcf-explorer_refdb/vcfexplorer.py
  if [ $DB == 'SHARCDB' ]; then
    DB_SCRIPT=$SHARCDIR/vcf-explorer/vcf-explorer_sharcdb/vcfexplorer.py
  fi
  if [ -e $DB_OUT.done ]; then
    continue
  fi

cat << EOF > $DB_SH
#!/bin/bash

#$ -N $DB_JOBNAME
#$ -cwd
#$ -l h_vmem=$DB_MEM
#$ -l h_rt=$DB_TIME
#$ -e $DB_ERR
#$ -o $DB_LOG
EOF

if [ ! -z $RF_JOBNAME ]; then
cat << EOF >> $DB_SH
#$ -hold_jid $RF_JOBNAME
EOF
fi

cat << EOF >> $DB_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $RF_OUT.done ]; then
    bash $STEPSDIR/database_filter.sh -v $RF_OUT -o $DB_OUT -e $VENV -f $DB_FLANK -n $DB_NAME -db $DB_SCRIPT -se $DB_EXCLUSION

    sed -i s/DB_Count/${DB}_Count/g $DB_OUT
    sed -i s/DB_Frequency/${DB}_Frequency/g $DB_OUT

    NUMBER_OF_LINES_VCF_1=\$(grep -v "^#" $RF_OUT | wc -l | grep -oP "(^\d+)")
    NUMBER_OF_LINES_VCF_2=\$(grep -v "^#" $DB_OUT | wc -l | grep -oP "(^\d+)")

    if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_VCF_2" ]; then
        touch $DB_OUT.done
    else
        echo "The number of lines in the random forest vcf file (\$NUMBER_OF_LINES_VCF_1) is different than the number of lines in the db vcf file (\$NUMBER_OF_LINES_VCF_2)" >&2
    fi
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
EOF

if [ ! -z $DB_JOBNAMES ]; then
cat << EOF >> $DB_MERGE_SH
#$ -hold_jid $DB_JOBNAMES
EOF
fi

cat << EOF >> $DB_MERGE_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $RF_OUT.done ]; then
  HEADERS=\$(cat $DB_OUTDIR/*.vcf | grep "^##INFO" | grep "DB_")
  grep "^#" $RF_OUT | awk -v headers="\$HEADERS" '/^##FORMAT/ && !modif { print headers; modif=1 } {print}' > $DB_MERGE_OUT

  $PASTE_CMD >> $DB_MERGE_OUT

  NUMBER_OF_LINES_VCF_1=\$(grep -v "^#" $RF_OUT | wc -l | grep -oP "(^\d+)")
  NUMBER_OF_LINES_VCF_2=\$(grep -v "^#" $DB_MERGE_OUT | wc -l | grep -oP "(^\d+)")

  if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_VCF_2" ]; then
      touch $DB_MERGE_OUT.done
  else
      echo "The number of lines in the random forest vcf file (\$NUMBER_OF_LINES_VCF_1) is different than the number of lines in the db merged vcf file (\$NUMBER_OF_LINES_VCF_2)" >&2
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

# somatic_feature_selection() {
# cat << EOF > $SOMATIC_FEATURE_SELECTION_SH
# #!/bin/bash
# 
# #$ -N $SOMATIC_FEATURE_SELECTION_JOBNAME
# #$ -cwd
# #$ -l h_vmem=$SOMATIC_FEATURE_SELECTION_MEM
# #$ -l h_rt=$SOMATIC_FEATURE_SELECTION_TIME
# #$ -e $SOMATIC_FEATURE_SELECTION_ERR
# #$ -o $SOMATIC_FEATURE_SELECTION_LOG
# EOF
# 
# if [ ! -z $SHARC_FILTER_JOBNAME ]; then
# cat << EOF >> $SOMATIC_FEATURE_SELECTION_SH
# #$ -hold_jid $SHARC_FILTER_JOBNAME
# EOF
# fi
# 
# cat << EOF >> $SOMATIC_FEATURE_SELECTION_SH
# echo \`date\`: Running on \`uname -n\`
# 
# if [ -e $SHARC_FILTER_OUT.done ]; then
#     bash $STEPSDIR/somatic_feature_selection.sh -v $SHARC_FILTER_OUT -s $SOMATIC_FEATURE_SELECTION_SCRIPT -c $SOMATIC_FEATURE_SELECTION_CANCER_TYPE -f $SOMATIC_FEATURE_SELECTION_FLANK -p $SOMATIC_FEATURE_SELECTION_SUPPORT -id $SOMATIC_FEATURE_SELECTION_ICGC_DIRECTORY -cb $SOMATIC_FEATURE_SELECTION_COSMIC_BREAKPOINTS -o $SOMATIC_FEATURE_SELECTION_OUT -a $SOMATIC_FEATURE_SELECTION_ATTRIBUTES_OUT
#     NUMBER_OF_LINES_VCF_1=\$(grep -v "^#" $SHARC_FILTER_OUT | wc -l | grep -oP "(^\d+)")
#     NUMBER_OF_LINES_VCF_2=\$(grep -v "^#" $SOMATIC_FEATURE_SELECTION_OUT | wc -l | grep -oP "(^\d+)")
# 
#     if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_VCF_2" ]; then
#         touch $SOMATIC_FEATURE_SELECTION_OUT.done
#     else
#         echo "The number of lines in the SHARC vcf file (\$NUMBER_OF_LINES_VCF_1) is different than the number of lines in the ICGC file (\$NUMBER_OF_LINES_VCF_2)" >&2
#     fi
# fi
# 
# echo \`date\`: Done
# EOF
# qsub $SOMATIC_FEATURE_SELECTION_SH
# }

somatic_ranking() {
cat << EOF > $SOMATIC_RANKING_SH
#!/bin/bash
#$ -N $SOMATIC_RANKING_JOBNAME
#$ -cwd
#$ -l h_vmem=$SOMATIC_RANKING_MEM
#$ -l h_rt=$SOMATIC_RANKING_TIME
#$ -e $SOMATIC_RANKING_ERR
#$ -o $SOMATIC_RANKING_LOG
EOF
if [ ! -z $SHARC_FILTER_JOBNAME ]; then
cat << EOF >> $SOMATIC_RANKING_SH
#$ -hold_jid $SHARC_FILTER_JOBNAME
EOF
fi
cat << EOF >> $SOMATIC_RANKING_SH
echo \`date\`: Running on \`uname -n\`
if [ -e $SHARC_FILTER_OUT.done ]; then
    bash $STEPSDIR/somatic_ranking.sh -v $SHARC_FILTER_OUT -s $SOMATIC_RANKING_SCRIPT -o $SOMATIC_RANKING_OUT -e $VENV
    NUMBER_OF_LINES_VCF_1=\$(grep -v "^#" $SHARC_FILTER_OUT | wc -l | grep -oP "(^\d+)")
    NUMBER_OF_LINES_VCF_2=\$(grep -v "^#" $SOMATIC_RANKING_OUT | wc -l | grep -oP "(^\d+)")
    if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_VCF_2" ]; then
        touch $SOMATIC_RANKING_OUT.done
    else
        echo "The number of lines in the SHARC vcf file (\$NUMBER_OF_LINES_VCF_1) is different than the number of lines in the Ranking file (\$NUMBER_OF_LINES_VCF_2)" >&2
    fi
fi
echo \`date\`: Done
EOF
qsub $SOMATIC_RANKING_SH
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
EOF

if [ ! -z $SOMATIC_RANKING_JOBNAME ]; then
cat << EOF >> $VCF_FASTA_SH
#$ -hold_jid $SOMATIC_RANKING_JOBNAME
EOF
fi

cat << EOF >> $VCF_FASTA_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $SOMATIC_RANKING_OUT.done ]; then
EOF
if [ "$VCF_FASTA_MASK" = true ]; then
cat << EOF >> $VCF_FASTA_SH
    bash $STEPSDIR/vcf_fasta.sh -v $SOMATIC_RANKING_OUT -vff $VCF_FASTA_FLANK -vfo $VCF_FASTA_OFFSET -vfs $VCF_FASTA_SCRIPT -vfm -o $VCF_FASTA_OUT -e $VENV
EOF
else
cat << EOF >> $VCF_FASTA_SH
    bash $STEPSDIR/vcf_fasta.sh -v $SOMATIC_RANKING_OUT -vff $VCF_FASTA_FLANK -vfo $VCF_FASTA_OFFSET -vfs $VCF_FASTA_SCRIPT -o $VCF_FASTA_OUT -e $VENV
EOF
fi
cat << EOF >> $VCF_FASTA_SH
  NUMBER_OF_LINES_VCF_1=\$(grep -v "^#" $SOMATIC_RANKING_OUT | wc -l | grep -oP "(^\d+)")
  NUMBER_OF_LINES_FILE_2=\$(grep "^Record" $VCF_FASTA_ERR | wc -l | grep -oP "(^\d+)")
  if [ "\$NUMBER_OF_LINES_VCF_1" == "\$NUMBER_OF_LINES_FILE_2" ]; then
      touch $VCF_FASTA_OUT.done
  else
      echo "The number of lines in the Somatic ranking vcf file (\$NUMBER_OF_LINES_VCF_1) is different than the number of lines in the vcf fasta err file (\$NUMBER_OF_LINES_FILE_2)" >&2
  fi
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
#$ -o $PRIMER_DESIGN_LOG
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
  grep -v "FAILED" $PRIMER_DESIGN_TMP_DIR/primers.txt > $PRIMER_DESIGN_OUT
  paste <(cat $PRIMER_DESIGN_OUT) <(grep "PRODUCT SIZE" $PRIMER_DESIGN_ERR | grep -oP "\d+$") > $PRIMER_DESIGN_OUT.tmp && mv $PRIMER_DESIGN_OUT.tmp $PRIMER_DESIGN_OUT
  touch $PRIMER_DESIGN_OUT.done

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
EOF

if [ ! -z $PRIMER_DESIGN_JOBNAME ]; then
cat << EOF >> $VCF_PRIMER_FILTER_SH
#$ -hold_jid $PRIMER_DESIGN_JOBNAME
EOF
fi

cat << EOF >> $VCF_PRIMER_FILTER_SH
echo \`date\`: Running on \`uname -n\`

if [ -e $PRIMER_DESIGN_OUT.done ]; then
    bash $STEPSDIR/vcf_primer_filter.sh -v $SOMATIC_RANKING_OUT -p $PRIMER_DESIGN_OUT -o $VCF_PRIMER_FILTER_OUT -s $VCF_PRIMER_FILTER_SCRIPT
    NUMBER_OF_LINES_PRIMER=\$(cat $PRIMER_DESIGN_OUT | wc -l | grep -oP "(^\d+)")
    NUMBER_OF_LINES_VCF=\$(grep -v "^#" $VCF_PRIMER_FILTER_OUT | wc -l | grep -oP "(^\d+)")
    if [ "\$NUMBER_OF_LINES_PRIMER" == "\$NUMBER_OF_LINES_VCF" ]; then
        touch $VCF_PRIMER_FILTER_OUT.done
    else
        echo "The number of lines in the primer file (\$NUMBER_OF_LINES_PRIMER) is different than the number of lines in the SHARC.primer.vcf file (\$NUMBER_OF_LINES_VCF)" >&2
    fi
fi

echo \`date\`: Done
EOF
qsub $VCF_PRIMER_FILTER_SH
}

primer_ranking() {
cat << EOF > $PRIMER_RANKING_SH
#!/bin/bash
#$ -N $PRIMER_RANKING_JOBNAME
#$ -cwd
#$ -l h_vmem=$PRIMER_RANKING_MEM
#$ -l h_rt=$PRIMER_RANKING_TIME
#$ -e $PRIMER_RANKING_ERR
#$ -o $PRIMER_RANKING_LOG
EOF
if [ ! -z $PRIMER_DESIGN_JOBNAME ]  && [ ! -z $SOMATIC_RANKING_JOBNAME ]; then
cat << EOF >> $PRIMER_RANKING_SH
#$ -hold_jid $PRIMER_DESIGN_JOBNAME,$SOMATIC_RANKING_JOBNAME
EOF
fi
cat << EOF >> $PRIMER_RANKING_SH
echo \`date\`: Running on \`uname -n\`
if [ -e $PRIMER_DESIGN_OUT.done ]; then
    bash $STEPSDIR/primer_ranking.sh -v $SOMATIC_RANKING_OUT -p $PRIMER_DESIGN_OUT -o $PRIMER_RANKING_OUT -e $VENV
    NUMBER_OF_PRIMERS_1=\$(wc -l $PRIMER_DESIGN_OUT | grep -oP "(^\d+)")
    NUMBER_OF_PRIMERS_2=\$(wc -l $PRIMER_RANKING_OUT | grep -oP "(^\d+)")
    if [ "\$NUMBER_OF_PRIMERS_1" == "\$NUMBER_OF_PRIMERS_2" ]; then
        touch $PRIMER_RANKING_OUT.done
    else
        echo "The number of lines in the unranked primers file (\$NUMBER_OF_PRIMERS_1) is different than the number of lines in the ranked primers file (\$NUMBER_OF_PRIMERS_2)" >&2
    fi
fi
echo \`date\`: Done
EOF
qsub $PRIMER_RANKING_SH
}

top20_report() {
cat << EOF > $TOP20_REPORT_SH
#!/bin/bash
#$ -N $TOP20_REPORT_JOBNAME
#$ -cwd
#$ -l h_vmem=$TOP20_REPORT_MEM
#$ -l h_rt=$TOP20_REPORT_TIME
#$ -e $TOP20_REPORT_ERR
#$ -o $TOP20_REPORT_LOG
EOF
if [ ! -z $PRIMER_RANKING_JOBNAME ]  && [ ! -z $SOMATIC_RANKING_JOBNAME ]; then
cat << EOF >> $TOP20_REPORT_SH
#$ -hold_jid $PRIMER_RANKING_JOBNAME,$SOMATIC_RANKING_JOBNAME
EOF
fi
cat << EOF >> $TOP20_REPORT_SH
echo \`date\`: Running on \`uname -n\`
if [ -e $PRIMER_RANKING_OUT.done ]; then
    bash $STEPSDIR/top20_report.sh -v $SOMATIC_RANKING_OUT -p $PRIMER_RANKING_OUT -ov $TOP20_REPORT_OUT_VCF -ot $TOP20_REPORT_OUT_TABLE
    LINES_VCF=\$(grep -v "^#" $TOP20_REPORT_OUT_VCF | wc -l)
    LINES_TSV=\$(tail -n +2 $TOP20_REPORT_OUT_TABLE | wc -l)
    if [ "\$LINES_VCF" == "\$LINES_TSV" ] && [ "\$LINES_VCF" -eq 20 ] ; then
        touch $TOP20_REPORT_OUT_VCF.done
    else
        echo "The number of lines in the TOP20 VCF (\$LINES_VCF) is different than the number of lines in the TOP20 table (\$LINES_TSV) or one is not 20" >&2
    fi
fi
echo \`date\`: Done
EOF
qsub $TOP20_REPORT_SH
}


check_SHARC() {
cat << EOF > $CHECK_SHARC_SH
#!/bin/bash

#$ -N $CHECK_SHARC_JOBNAME
#$ -cwd
#$ -l h_vmem=$CHECK_SHARC_MEM
#$ -l h_rt=$CHECK_SHARC_TIME
#$ -e $CHECK_SHARC_ERR
#$ -o $CHECK_SHARC_LOG

EOF

if [ ! -z $TOP20_REPORT_JOBNAME ]; then
cat << EOF >> $CHECK_SHARC_SH
#$ -hold_jid $TOP20_REPORT_JOBNAME
EOF
fi

cat << EOF >> $CHECK_SHARC_SH
echo \`date\`: Running on \`uname -n\`
CHECK_BOOL=true
echo "------------------------------------------------" >> $CHECK_SHARC_OUT
echo "\`date\`" >> $CHECK_SHARC_OUT
echo "Qsub ID: $RAND" >> $CHECK_SHARC_OUT
echo "Sample name: $OUTNAME" >> $CHECK_SHARC_OUT
if [ -e $MAPPING_MERGE_OUT.done ]; then
    echo "Mapping: Done" >> $CHECK_SHARC_OUT
else
    echo "Mapping: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi

if [ -e $COVERAGE_CALCULATION_OUT.done ]; then
    echo "Coverage calculation: Done" >> $CHECK_SHARC_OUT
else
  echo "Coverage calculation: Fail" >> $CHECK_SHARC_OUT
  CHECK_BOOL=false
fi

if [ -e $SV_OUT.done ]; then
    echo "SV calling: Done" >> $CHECK_SHARC_OUT
else
    echo "SV calling: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi

if [ -e $VCF_FILTER_OUT.done ]; then
    echo "VCF filter: Done" >> $CHECK_SHARC_OUT
else
    echo "VCF filter: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi

if [ -e $BED_ANNOTATION_MERGE_OUT.done ]; then
    echo "BED annotation: Done" >> $CHECK_SHARC_OUT
else
    echo "BED annotation: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi

if [ -e $RF_OUT.done ]; then
    echo "Random Forest: Done" >> $CHECK_SHARC_OUT
else
    echo "Random Forest: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi

if [ -e $DB_MERGE_OUT.done ]; then
    echo "DB filter: Done" >> $CHECK_SHARC_OUT
else
    echo "DB filter: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi

if [ -e $SHARC_FILTER_OUT.done ]; then
    echo "SHARC filter: Done" >> $CHECK_SHARC_OUT
else
    echo "SHARC filter: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi

# if [ -e $SOMATIC_FEATURE_SELECTION_OUT.done ]; then
#     echo "Somatic feature selection: Done" >> $CHECK_SHARC_OUT
# else
#     echo "Somatic feature selection: Fail" >> $CHECK_SHARC_OUT
#     CHECK_BOOL=false
# fi
if [ -e $SOMATIC_RANKING_OUT.done ]; then
    echo "Somatic ranking: Done" >> $CHECK_SHARC_OUT
else
    echo "Somatic ranking: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi
if [ -e $VCF_FASTA_OUT.done ]; then
    echo "VCF to FASTA: Done" >> $CHECK_SHARC_OUT
else
    echo "VCF to FASTA: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi

if [ -e $PRIMER_DESIGN_OUT.done ]; then
    echo "Primer design: Done" >> $CHECK_SHARC_OUT
else
    echo "Primer design: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi

if [ -e $VCF_PRIMER_FILTER_OUT.done ]; then
    echo "VCF primer filter: Done" >> $CHECK_SHARC_OUT
else
    echo "VCF primer filter: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi
if [ -e $PRIMER_RANKING_OUT.done ]; then
    echo "Primer ranking: Done" >> $CHECK_SHARC_OUT
else
    echo "Primer ranking: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi
if [ -e $TOP20_REPORT_OUT_VCF.done ]; then
    echo "Top20 report: Done" >> $CHECK_SHARC_OUT
else
    echo "Top20 report: Fail" >> $CHECK_SHARC_OUT
    CHECK_BOOL=false
fi
if [ \$CHECK_BOOL = true ]; then
    touch $CHECK_SHARC_OUT.done
    if [ $DONT_CLEAN = false ]; then
      rm -rf $MAPPING_TMP_DIR
    fi
fi
tac $CHECK_SHARC_OUT | sed '/^Qsub/q' | tac | mail -s 'SHARC_${OUTNAME}_${RAND}' $MAIL

echo \`date\`: Done

sleep 20
EOF
qsub $CHECK_SHARC_SH
}

prepare
if [ ! -e $MAPPING_MERGE_OUT.done ]; then
    mapping
    mapping_merge
fi
if [ ! -e $COVERAGE_CALCULATION_OUT.done ]; then
    coverage_calculation
fi
if [ ! -e $SV_OUT.done ]; then
    sv
fi
if [ ! -e $VCF_FILTER_OUT.done ]; then
  vcf_filter
fi
if [ ! -e $VCF_SPLIT_OUT.done ]; then
  vcf_split
fi
if [ ! -e $BED_ANNOTATION_MERGE_OUT.done ]; then
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
# if [ ! -e $SOMATIC_FEATURE_SELECTION_OUT.done ]; then
#   somatic_feature_selection
# fi
if [ ! -e $SOMATIC_RANKING_OUT.done ]; then
  somatic_ranking
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
if [ ! -e $PRIMER_RANKING_OUT.done ]; then
  primer_ranking
fi
if [ ! -e $TOP20_REPORT_OUT_VCF.done ]; then
  top20_report
fi
if [ ! -e $CHECK_SHARC_OUT.done ]; then
  check_SHARC
fi
