#!/usr/bin/python

import vcf as pyvcf
import argparse

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description='Put here a description.')
parser.add_argument('-v', '--vcf', type=str, help='VCF input file', required=True)
parser.add_argument('-f', '--features', type=str, help='VCF input file', required=True)
parser.add_argument('-o', '--output', type=str, help='VCF output file', required=True)
args = parser.parse_args()

VCF=args.vcf
RANKED_VCF=args.output
DATABASE_FEATURES=args.features

RANKING={}
RANK=[]

BREAKPOINTS=[]
with open(DATABASE_FEATURES, "r") as input:
    for line in input:
        FEATURES={}
        if line.startswith("ID"):
            line=line.strip()
            columns=line.split("\t")
            ATTRIBUTES=columns
        else:
            columns=line.strip().split("\t")
            LINE_FEATURES=columns
            for index, attribute in enumerate(ATTRIBUTES):
                FEATURES[attribute]=float(LINE_FEATURES[index])
            BREAKPOINTS.append(FEATURES)

for SV in BREAKPOINTS:
    ENSEMBL_OVERLAP=int(SV["ENSEMBL_OVERLAP"])
    if ENSEMBL_OVERLAP not in RANKING:
        RANKING[ENSEMBL_OVERLAP]=[SV]
    else:
        RANKING[ENSEMBL_OVERLAP].append(SV)

primers=sorted(RANKING, key=lambda k: k, reverse=True)
FINAL_RANKING=[]
for x in primers:
    length_sorted=sorted(RANKING[x], key=lambda k: k["SV_LENGTH"], reverse=True)
    FINAL_RANKING=FINAL_RANKING+length_sorted

for idx, SV in enumerate(BREAKPOINTS):
    BREAKPOINTS[idx]["ID"]=int(BREAKPOINTS[idx]["ID"])
    ID=BREAKPOINTS[idx]["ID"]
    if int(SV["COSMIC_BREAKPOINT_OVERLAP"])==1 or (SV["SV_LENGTH"]==0 and SV["HIGHEST_OCCURRING_CANCER_GENE"]>=0.33):
        for primer in FINAL_RANKING:
            if primer["ID"]==ID:
                FINAL_RANKING.remove(primer)
                FINAL_RANKING.insert(0, primer)

with open(VCF, "r") as vcf_input, open(RANKED_VCF, "w") as vcf_output:
    VCF_READ=pyvcf.Reader(vcf_input)
    VCF_READ.infos['SHARC_RANK']=pyvcf.parser._Info('SHARC_RANK', 1, "Integer", "Ranking based on icgc database, SV length and read depth", "NanoSV", "X")
    VCF_WRITER=pyvcf.Writer(vcf_output, VCF_READ, lineterminator='\n')
    for record in VCF_READ:
        for rank, primer in enumerate(FINAL_RANKING):
            RANK=rank+1
            if str(record.ID) == str(primer["ID"]):
                record.INFO["SHARC_RANK"]=RANK
        VCF_WRITER.write_record(record)
