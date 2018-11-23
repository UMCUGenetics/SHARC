#!/usr/bin/python

import vcf as pyvcf
import argparse

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description='Put here a description.')
parser.add_argument('-v', '--vcf', type=str, help='VCF input file', required=True)
parser.add_argument('-o', '--output', type=str, help='VCF output file', required=True)
args = parser.parse_args()

VCF=args.vcf
RANKED_VCF=args.output

with open(VCF, "r") as input:
    VCF_READ=pyvcf.Reader(input)

    primers=[]
    for record in VCF_READ:
        record_info={}
        record_info["ID"]=record.ID
        if "SVLEN" in record.INFO:
            record_info["SVLEN"]=record.INFO["SVLEN"][0]
        else:
            record_info["SVLEN"]=0
        if isinstance(record.ALT[0], pyvcf.model._Breakend):
            if record.ALT[0].chr == record.CHROM:
                if record.ALT[0].orientation == False and record.ALT[0].remoteOrientation == True:
                    record_info["TYPE"]="DEL"
                elif record.ALT[0].orientation == True and record.ALT[0].remoteOrientation == False:
                    record_info["TYPE"]="DUP"
                else:
                    record_info["TYPE"]="INV"
            else:
                record_info["TYPE"]="TRA"
        else:
            record_info["TYPE"]=record.ALT[0]

        record_info["ICGC_SCORE"]=record.INFO['ICGC_SCORE']
        primers.append(record_info)

    score_6=[]
    score_5=[]
    score_4=[]
    score_3=[]
    score_2=[]
    score_1=[]
    score_0=[]

    primers=sorted(primers, key=lambda k: k['ICGC_SCORE'], reverse=True)

    for primer in primers:
        if int(primer["ICGC_SCORE"]) >= 5:
            if int(primer["SVLEN"]) >= 200000:
                score_6.append(primer)
            elif int(primer["SVLEN"]) >= 1000:
                score_5.append(primer)
            elif int(primer["SVLEN"]) == 0:
                score_5.append(primer)
            else:
                score_0.append(primer)

        elif int(primer["ICGC_SCORE"]) >= 3:
            if int(primer["SVLEN"]) >= 200000:
                score_5.append(primer)
            elif int(primer["SVLEN"]) >= 1000:
                score_4.append(primer)
            elif int(primer["SVLEN"]) == 0:
                score_3.append(primer)
            else:
                score_0.append(primer)

        elif int(primer["ICGC_SCORE"]) >= 1:
            if int(primer["SVLEN"]) >= 200000:
                score_4.append(primer)
            elif int(primer["SVLEN"]) >= 50000:
                score_3.append(primer)
            elif int(primer["SVLEN"]) >= 1000:
                score_2.append(primer)
            elif int(primer["SVLEN"]) == 0:
                score_1.append(primer)
            else:
                score_0.append(primer)

        elif int(primer["ICGC_SCORE"]) == 0:
            if int(primer["SVLEN"]) >= 200000:
                score_3.append(primer)
            elif int(primer["SVLEN"]) >= 50000:
                score_2.append(primer)
            elif int(primer["SVLEN"]) >= 1000:
                score_1.append(primer)
            elif int(primer["SVLEN"]) == 0:
                score_0.append(primer)
            else:
                score_0.append(primer)
        else:
            print ("ERROR: UNKNOWN SCORE")


    score_6=sorted(score_6, key=lambda k: k['SVLEN'], reverse=True)
    score_5=sorted(score_5, key=lambda k: k['SVLEN'], reverse=True)
    score_4=sorted(score_4, key=lambda k: k['SVLEN'], reverse=True)
    score_3=sorted(score_3, key=lambda k: k['SVLEN'], reverse=True)
    score_2=sorted(score_2, key=lambda k: k['SVLEN'], reverse=True)
    score_1=sorted(score_1, key=lambda k: k['SVLEN'], reverse=True)
    score_0=sorted(score_0, key=lambda k: k['SVLEN'], reverse=True)

    SCORE=score_6+score_5+score_4+score_3+score_2+score_1+score_0
    SVLEN_SCORE=sorted(primers, key=lambda k: k['SVLEN'], reverse=True)

    # for i in range(20):
    #     rank=SCORE[i]
    #     len=SVLEN_SCORE[i]
    #     print (str(rank["ID"]) + "\t" + str(len["ID"]))
    for primer in SCORE:
        print (str(primer["ID"]) + "\t" + str(primer["TYPE"]) + "\t" + str(primer["ICGC_SCORE"]) + "\t" + str(primer["SVLEN"]))
    for primer in SVLEN_SCORE:
        continue
        print (str(primer["ID"]) + "\t" + str(primer["TYPE"]) + "\t" + str(primer["ICGC_SCORE"]) + "\t" + str(primer["SVLEN"]))

with open(VCF, "r") as vcf_input, open(RANKED_VCF, "w") as vcf_output:
    VCF_READ2=pyvcf.Reader(vcf_input)
    VCF_READ2.infos['SHARC_RANK']=pyvcf.parser._Info('SHARC_RANK', 1, "Integer", "Ranking based on icgc database, SV length and read depth", "NanoSV", "X")
    VCF_WRITER=pyvcf.Writer(vcf_output, VCF_READ2, lineterminator='\n')
    for record in VCF_READ2:
        for rank, primer in enumerate(SCORE):
            RANK=rank+1
            if str(record.ID) == str(primer["ID"]):
                record.INFO["SHARC_RANK"]=RANK
        VCF_WRITER.write_record(record)
