#!/usr/bin/python

import vcf as pyvcf
import argparse

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description='Put here a description.')
parser.add_argument('-v', '--vcf', type=str, help='VCF input file', required=True)
parser.add_argument('-p', '--primers', type=str, help='Primer input file', required=True)
parser.add_argument('-o', '--output', type=str, help='Primer output file', required=True)
args = parser.parse_args()

VCF=args.vcf
PRIMERS=args.primers
OUTPUT=args.output

VCF_READER=pyvcf.Reader(open(VCF, "r"))

PRIMER_RANKING={}
for record in VCF_READER:
    PRIMER_RANKING[record.ID]=record.INFO["RANK"]

PRIMER_RANKING=sorted(PRIMER_RANKING, key=lambda k: PRIMER_RANKING[k])

with open(PRIMERS, "r") as input:
    lines=[]
    for line in input:
        columns=line.strip().split("\t")
        ID=columns[0]
        lines.append([line, ID])

with open(OUTPUT, "w") as output:
    for primer_id in PRIMER_RANKING:
        for primer in lines:
            if primer[1] == primer_id:
                output.write(primer[0])
