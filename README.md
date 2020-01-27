# SHARC

## Intro 
SHARC is a pipeline for somatic SV calling and filtering from tumor-only Nanopore sequencing data. It performs mapping, SV calling, SV filtering, random forest classification, blacklist filtering and SV prioritization, followed by automated primer design for PCR amplicons of 80-120 bp that are useful to track cancer ctDNA molecules in liquid biopsies. 
We are currently busy refurbishing to make the pipeline fully accesible. For now, it would only work in SGE-HPC systems.

## INSTALL
```
git clone git@github.com:UMCUGenetics/SHARC.git sharc
cd sharc
virtualenv venv -p python3
. venv/bin/activate
pip install -r requirements.txt
```
## How to run
```
bash sharc.sh -f </path/to/fastqdir> -m <email> -o </path/to/outputdir>
```
