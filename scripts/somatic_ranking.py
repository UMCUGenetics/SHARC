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

SCORE={}
SCORES={"SVLEN_SCORE":0, "ENSEMBL_OVERLAP_SCORE":0, "COSMIC_BREAKPOINT_OVERLAP":0, "ICGC_OVERLAP_SCORE":0, "ICGC_OCCURRENCE_SCORE":0}

for SV in BREAKPOINTS:
    ID=int(SV["ID"])
    SVLEN=int(SV["SV_LENGTH"])
    ENSEMBL_OVERLAP=int(SV["ENSEMBL_OVERLAP"])
    ICGC_OVERLAP=int(SV["ICGC_OVERLAP"])
    ICGC_CANCER_GENE_OVERLAP=int(SV["ICGC_CANCER_GENE_OVERLAP"])
    COSMIC_BREAKPOINT_OVERLAP=int(SV["COSMIC_BREAKPOINT_OVERLAP"])
    HIGHEST_OCCURRING_CANCER_GENE=float(SV["HIGHEST_OCCURRING_CANCER_GENE"])
    HIGHEST_OCCURRING_GENE=float(SV["HIGHEST_OCCURRING_GENE"])

    #SCORE[ID]={"SVLEN_SCORE":0, "ENSEMBL_OVERLAP_SCORE":0, "ICGC_OVERLAP_SCORE":0, "ICGC_OCCURRENCE_SCORE":0, "COSMIC_BREAKPOINT_OVERLAP_SCORE":0}
    SCORE[ID]=SVLEN
    #Score based on SV length
    # SCORE[ID]["SVLEN_SCORE"]=float(SVLEN/250000000)
    #
    # #Score based on ENSEMBL overlap normalized to SV length
    # temp_length=SVLEN
    # if SVLEN<10000:
    #     temp_length=10000
    # SCORE[ID]["ENSEMBL_OVERLAP_SCORE"]=ENSEMBL_OVERLAP/temp_length
    #
    # if SCORE[ID]["ENSEMBL_OVERLAP_SCORE"]>0:
    #     SC=SCORE[ID]["SVLEN_SCORE"]+((SCORE[ID]["SVLEN_SCORE"]**2)/SCORE[ID]["ENSEMBL_OVERLAP_SCORE"])
    # else:
    #     SC=SCORE[ID]["SVLEN_SCORE"]+0

FINAL_RANKING=sorted(SCORE, key=lambda k: SCORE[k], reverse=True)


with open(VCF, "r") as vcf_input, open(RANKED_VCF, "w") as vcf_output:
    VCF_READ=pyvcf.Reader(vcf_input)
    VCF_READ.infos['SHARC_RANK']=pyvcf.parser._Info('SHARC_RANK', 1, "Integer", "Ranking based on icgc database, SV length and read depth", "NanoSV", "X")
    VCF_WRITER=pyvcf.Writer(vcf_output, VCF_READ, lineterminator='\n')
    for record in VCF_READ:
        for rank, primer in enumerate(FINAL_RANKING):
            RANK=rank+1
            if str(record.ID) == str(primer):
                record.INFO["SHARC_RANK"]=RANK
        VCF_WRITER.write_record(record)
