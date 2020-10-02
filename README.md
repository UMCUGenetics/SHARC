# SHARC

## Intro 
SHARC is a pipeline for somatic SV calling and filtering from tumor-only Nanopore sequencing data. It performs mapping, SV calling, SV filtering, random forest classification, blacklist filtering and SV prioritization, followed by automated primer design for PCR amplicons of 80-120 bp that are useful to track cancer ctDNA molecules in liquid biopsies. 
We provide packages to run on:

1. SLURM cluster
2. SGE
3. Locally

We also provide Docker and Singularity containers.

## Installation 

Depending on your version and distribution system, download your package on:

### Slurm
```
tar axvf sharc-slurm.tar.gz
bin/sharc -f <FASTQ_DIR> -o <OUTPUT_DIR> -m <EMAIL> -mr <PATH_TO_REF>
```
This will submit jobs to your cluster. 

### SGE
```
tar axvf sharc-sge.tar.gz
bin/sharc -f <FASTQ_DIR> -o <OUTPUT_DIR> -m <EMAIL> -mr <PATH_TO_REF>
```
This will submit jobs to your cluster. 


### Local
```
tar axvf sharc-local.tar.gz

bin/sharc -f <FASTQ_DIR> -o <OUTPUT_DIR>
```
It will run in your local machine. 

### Singularity
```
singularity run --bind <PATH_TO_REF>:<PATH_TO_REF> sharc-singularity.squashfs -f <FASTQ_DIR> -o <OUTPUT_DIR> -mr <PATH_TO_REF>
```
We tested using Singularity version 3.6

### Docker
```
docker load < sharc-docker.tar.gz
docker run --mount type=bind,source=/home/roel,destination=/home/roel -it sharc -f <FASTQ_DIR> -o <OUTPUT_DIR>  -mr <PATH_TO_REF>
```

## Parameters
There are a lot of parameters to control the amount of memory and time a specific job can take. You can view them all by running
```
bin/sharc --help
```
The ones that are most likely to be useful are:
```
    -o|--outputdir                                       Path to output directory [./]
    -sm|--sample_name                                    Name of the sample [taken from FASTQ name or outputdir]
    -mr|--mapping_ref                                    Path to reference genome [/hpc/cog_bioinf/GENOMES/Homo_sapiens.GRCh37.GATK.illumina/Homo_sapiens.GRCh37.GATK.illumina.fasta]
    -ponfiles|--pon_files                                Path to VCF files to be used as PON (comma separated) [files/gnomad_v2.1_sv.sites.vcf]
    -mt|--mapping_threads                                Number of threads for mapping [$MAPPING_THREADS]
```
