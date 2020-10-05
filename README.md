# SHARC

## Intro 
SHARC is a pipeline for somatic SV calling and filtering from tumor-only Nanopore sequencing data. It performs mapping, SV calling, SV filtering, random forest classification, blacklist filtering and SV prioritization, followed by automated primer design for PCR amplicons of 80-120 bp that are useful to track cancer ctDNA molecules in liquid biopsies. 
We provide packages to run on:

1. SLURM cluster
2. SGE
3. Locally

We also provide Docker and Singularity containers.

## Installation 
Depending on your version and distribution system, download your preferred package on [Zenodo](https://doi.org/10.5281/zenodo.4064767).
These packages were created using [GNU-Guix](https://guix.gnu.org/). Our other [GUIX packages](https://github.com/UMCUGenetics/guix-additions)

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

bin/sharc -f <FASTQ_DIR> -o <OUTPUT_DIR> -mr <PATH_TO_REF>
```
It will run in your local machine. 

### Singularity
```
singularity run --bind <PATH_TO_DATA>:<PATH_TO_DATA> sharc-singularity.squashfs -f <FASTQ_DIR> -o <OUTPUT_DIR> -mr <PATH_TO_REF>
```
You probably need to bind all the directories needed (FASTQ input, output, reference genome)
We tested using Singularity version 3.6

### Docker
The docker image can be ran automatically from [Docker hub](https://hub.docker.com/r/jaesvi/sharc).
```
###Run automatically from docker hub
docker run --mount type=bind,source=<PATH_TO_DATA>,destination=<PATH_TO_DATA> -it jaesvi/sharc -f <FASTQ_DIR> -o <OUTPUT_DIR>  -mr <PATH_TO_REF>

###Load the image manually
docker load < sharc-docker.tar.gz
docker run --mount type=bind,source=<PATH_TO_DATA>,destination=<PATH_TO_DATA> -it sharc -f <FASTQ_DIR> -o <OUTPUT_DIR>  -mr <PATH_TO_REF>
```

## Parameters
There are a lot of parameters to control the amount of memory, time and threads a specific job can take. You can view them all by running
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
