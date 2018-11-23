#!/usr/bin/python

import requests
import json
import vcf as pyvcf
import sys
import argparse

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description='Put here a description.')
parser.add_argument('vcf', help='VCF file')
parser.add_argument('-c', '--cancertype', type=str, help='Primary site of cancer', required=True)
parser.add_argument('-o', '--output', type=str, help='VCF output file', required=True)
parser.add_argument('-f', '--flank', type=int, help='Flank', required=True)
parser.add_argument('-s', '--support', type=float, help='Minimal percentage of cancer patients supporting the mutated gene', required=True)
args = parser.parse_args()

#############################################   CONVERT DIFFERENT VCF SV NOTATIONS TO bracket notations N[Chr:pos[   #############################################
def alt_convert( record ):
    orientation = None
    remoteOrientation = None
    if record.INFO['SVTYPE'] == 'DEL':
        orientation = False
        remoteOrientation = True
    elif record.INFO['SVTYPE'] == 'DUP':
        orientation = True
        remoteOrientation = False
    elif record.INFO['SVTYPE'] == 'TRA':
        strands=record.INFO['STRANDS']
        if strands == "++":
            orientation = False
            remoteOrientation = False
        elif strands == "+-":
            orientation = False
            remoteOrientation = True
        elif strands == "-+":
            orientation = True
            remoteOrientation = False
        elif strands == "--":
            orientation = True
            remoteOrientation = True
    elif 'INV3' in record.INFO:
    	orientation = False
    	remoteOrientation = False
    elif 'INV5' in record.INFO:
        orientation = True
        remoteOrientation = True

    if 'CT' in record.INFO:
        if record.INFO['CT'] == '3to5':
            orientation = False
            remoteOrientation = True
        elif record.INFO['CT'] == '3to3':
            orientation = False
            remoteOrientation = False
        elif record.INFO['CT'] == '5to3':
            orientation = True
            remoteOrientation = False
        elif record.INFO['CT'] == '5to5':
            orientation = True
            remoteOrientation = True
    if orientation is None or remoteOrientation is None:
        sys.exit()
    record.ALT = [ pyvcf.model._Breakend( record.CHROM, record.INFO['END'], orientation, remoteOrientation, record.REF, True ) ]
    return( record )


#############################################   FILTER OUT REGIONS AROUND BREAKPOINTS FROM A VCF FILE   #############################################
def regions_from_vcf(INPUT_VCF):
    with open(INPUT_VCF, "r") as vcf:
        VCF_READER=pyvcf.Reader(vcf)

        SV_DATA={}

        for record in VCF_READER:
            BEGIN_CHROM = str(record.CHROM)
            BEGIN_POS = record.POS
            ID=str(record.ID)
            SV_DATA[ID]={"REGION":[]}

            if "INS" in str(record.ALT[0]):
                REGION_START=BEGIN_POS-FLANK
                REGION_END=BEGIN_POS+1+FLANK
                SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START, "End":REGION_END})

            else:
                if not isinstance(record.ALT[0], pyvcf.model._Breakend):
                    record = alt_convert(record)

                END_CHROM = record.ALT[0].chr
                END_POS = record.ALT[0].pos

                if END_CHROM != BEGIN_CHROM:
                    if record.ALT[0].orientation and record.ALT[0].remoteOrientation:
                        REGION_START_1 = BEGIN_POS-1-FLANK
                        REGION_END_1 = BEGIN_POS+FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START_1, "End":REGION_END_1})
                        REGION_START_2 = END_POS-1-FLANK
                        REGION_END_2 = END_POS+FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":END_CHROM, "Start":REGION_START_2, "End":REGION_END_2})
                        continue
                    elif not record.ALT[0].orientation and record.ALT[0].remoteOrientation:
                        REGION_START_1 = BEGIN_POS-FLANK
                        REGION_END_1 = BEGIN_POS+1+FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START_1, "End":REGION_END_1})
                        REGION_START_2 = END_POS-1-FLANK
                        REGION_END_2 = END_POS+FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":END_CHROM, "Start":REGION_START_2, "End":REGION_END_2})
                        continue
                    elif record.ALT[0].orientation and not record.ALT[0].remoteOrientation:
                        REGION_START_1 = BEGIN_POS-1-FLANK
                        REGION_END_1 = BEGIN_POS+FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START_1, "End":REGION_END_1})
                        REGION_START_2 = END_POS-FLANK
                        REGION_END_2 = END_POS+1+FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":END_CHROM, "Start":REGION_START_2, "End":REGION_END_2})
                        continue
                    elif not record.ALT[0].orientation and not record.ALT[0].remoteOrientation:
                        REGION_START_1 = BEGIN_POS-FLANK
                        REGION_END_1 = BEGIN_POS+1+FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START_1, "End":REGION_END_1})
                        REGION_START_2 = END_POS-FLANK
                        REGION_END_2 = END_POS+1+FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":END_CHROM, "Start":REGION_START_2, "End":REGION_END_2})
                        continue
                else:
                    REGION_START = BEGIN_POS-FLANK
                    REGION_END = END_POS+FLANK
                    SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START, "End":REGION_END})
        return (SV_DATA)

#############################################   OVERLAP SV WITH KNOWN ENSEMBLE GENES   #############################################
def overlap_ENSEMBLE(REGIONS):
    SERVER="https://GRCh37.rest.ensembl.org/overlap/region/"
    SPECIES="human"
    HEADERS={"Content-Type" : "application/json"}
    print("Ensembl overlap")
    for ID in REGIONS:
        REGIONS[ID]["GENES"]=[]

        for region in REGIONS[ID]["REGION"]:
            CHROM=region["Chrom"]
            SV_START=int(region["Start"])
            SV_END=int(region["End"])

            if SV_END-SV_START <= 5000000:

                TRY=1
                while TRY <= 10:
                    try:
                        request = requests.get(SERVER+SPECIES+"/"+CHROM+":"+str(SV_START)+"-"+str(SV_END)+"?feature=gene", headers=HEADERS)
                        response = request.text
                        data=json.loads(response)
                        break
                    except:
                        if TRY==10:
                            sys.exit("Error while requesting from ENSEMBL database after", TRY,  "tries")
                        TRY +=1

                if isinstance(data, list):
                    REGIONS[ID]["GENES"]=REGIONS[ID]["GENES"]+[gene["id"] for gene in data]

                else:
                    print ("Error:", data["error"])
                    REGIONS[ID]["GENES"]=[]
            else:
                TEMP_SV_START=SV_START
                TEMP_SV_END=TEMP_SV_START
                while TEMP_SV_END < SV_END:
                    TEMP_SV_END+=4999999
                    if TEMP_SV_END > SV_END:
                        TEMP_SV_END=SV_END

                    TRY=1
                    while TRY <= 10:
                        try:
                            request = requests.get(SERVER+SPECIES+"/"+CHROM+":"+str(TEMP_SV_START)+"-"+str(TEMP_SV_END)+"?feature=gene", headers=HEADERS)
                            response = request.text
                            data=json.loads(response)
                            break
                        except:
                            if TRY==10:
                                sys.exit("Error while requesting from ENSEMBL database after", TRY,  "tries")
                            TRY +=1

                    if isinstance(data, list):
                        REGIONS[ID]["GENES"]=REGIONS[ID]["GENES"]+[gene["id"] for gene in data]
                    else:
                        print ("Error:", data["error"])
                        REGIONS[ID]["GENES"]=[]
                        break
                    TEMP_SV_START=TEMP_SV_END
            print (ID, "\t", REGIONS[ID]["GENES"])
    return REGIONS

#############################################   CREATE A LIST OF CANCER GENES FROM THE ICGC DATABASE   #############################################

def create_ICGC_gene_list(CANCER_TYPE, MIN_SUPPORT):

##################################### Top genes with occurence > given occurence
    SIGNIFICANT_GENES={}

    SERVER_GENES="https://dcc.icgc.org/api/v1/genes"
    FILTERS_GENES={
                    "donor":{"primarySite":{"is":[CANCER_TYPE]}
                    ,"availableDataTypes":{"is":["ssm"]}}
                    }
    FILTERS_GENES=json.dumps(FILTERS_GENES)

    MAX_GENES=int(requests.get("https://dcc.icgc.org/api/v1/genes/count?filters="+FILTERS_GENES).text)
    CASE_NUMBER=int(requests.get("https://dcc.icgc.org/api/v1/donors/count?filters="+FILTERS_GENES).text)

    SLICE=1
    STOP=False

    while SLICE < MAX_GENES and STOP==False :
        PARAMS_GENES = {
            "filters": FILTERS_GENES,
            "format": "JSON",
            "size": "100",
            "from": str(SLICE)
            }

        TRY=1
        while TRY <= 10:
            try:
                request_genes=requests.get(SERVER_GENES, params=PARAMS_GENES)
                response_genes=request_genes.text
                response_genes=json.loads(response_genes)
                hits_genes=response_genes["hits"]
                break
            except:
                if TRY==10:
                    sys.exit("Error while requesting from ENSEMBL database after", TRY,  "tries")
                TRY +=1


        for HIT in hits_genes:
            OCCURRENCE=float(float(HIT["affectedDonorCountFiltered"])/float(CASE_NUMBER))
            if OCCURRENCE>=float(MIN_SUPPORT):
                SIGNIFICANT_GENES[HIT["id"]]={}
                SIGNIFICANT_GENES[HIT["id"]]["score"]=1
                SIGNIFICANT_GENES[HIT["id"]]["symbol"]=HIT["symbol"]
            else:
                STOP=True
                break

        SLICE+=100

##################################### Genes with occurence > given occurence and cancer_census is true
    SERVER_GENES="https://dcc.icgc.org/api/v1/genes"
    FILTERS_GENES={
                    "donor":{"primarySite":{"is":[CANCER_TYPE]}
                    ,"availableDataTypes":{"is":["ssm"]}}
                    ,"gene":{"curatedSetId":{"is":["GS1"]}}
                    }
    FILTERS_GENES=json.dumps(FILTERS_GENES)

    MAX_GENES=int(requests.get("https://dcc.icgc.org/api/v1/genes/count?filters="+FILTERS_GENES).text)
    CASE_NUMBER=int(requests.get("https://dcc.icgc.org/api/v1/donors/count?filters="+FILTERS_GENES).text)

    SLICE=1
    STOP=False
    while SLICE < MAX_GENES and STOP==False:
        PARAMS_GENES = {
            "filters": FILTERS_GENES,
            "format": "JSON",
            "size": "100",
            "from": str(SLICE)
            }

        TRY=1
        while TRY <= 10:
            try:
                request_genes=requests.get(SERVER_GENES, params=PARAMS_GENES)
                response_genes=request_genes.text
                response_genes=json.loads(response_genes)
                hits_genes=response_genes["hits"]
                break
            except:
                if TRY==10:
                    sys.exit("Error while requesting from ENSEMBL database after", TRY,  "tries")
                TRY +=1

        for HIT in hits_genes:
            OCCURRENCE=float(float(HIT["affectedDonorCountFiltered"])/float(CASE_NUMBER))
            if OCCURRENCE>=float(MIN_SUPPORT):
                if HIT["id"] not in SIGNIFICANT_GENES:
                    SIGNIFICANT_GENES[HIT["id"]]={}
                    SIGNIFICANT_GENES[HIT["id"]]["symbol"]=HIT["symbol"]
                SIGNIFICANT_GENES[HIT["id"]]["score"]=3
            else:
                STOP=True
                break
        SLICE+=100

##################################### Genes with occurence > 0.2 and cancer_census is true
    SERVER_GENES="https://dcc.icgc.org/api/v1/genes"
    FILTERS_GENES={
                    "donor":{"primarySite":{"is":[CANCER_TYPE]}
                    ,"availableDataTypes":{"is":["ssm"]}}
                    ,"gene":{"curatedSetId":{"is":["GS1"]}}
                    }
    FILTERS_GENES=json.dumps(FILTERS_GENES)

    MAX_GENES=int(requests.get("https://dcc.icgc.org/api/v1/genes/count?filters="+FILTERS_GENES).text)
    CASE_NUMBER=int(requests.get("https://dcc.icgc.org/api/v1/donors/count?filters="+FILTERS_GENES).text)

    SLICE=1
    STOP=False
    while SLICE < MAX_GENES and STOP==False:
        PARAMS_GENES = {
            "filters": FILTERS_GENES,
            "format": "JSON",
            "size": "100",
            "from": str(SLICE)
            }

        TRY=1
        while TRY <= 10:
            try:
                request_genes=requests.get(SERVER_GENES, params=PARAMS_GENES)
                response_genes=request_genes.text
                response_genes=json.loads(response_genes)
                hits_genes=response_genes["hits"]
                break
            except:
                if TRY==10:
                    sys.exit("Error while requesting from ENSEMBL database after", TRY,  "tries")
                TRY +=1

        for HIT in hits_genes:
            OCCURRENCE=float(float(HIT["affectedDonorCountFiltered"])/float(CASE_NUMBER))
            if OCCURRENCE>=0.2:
                SIGNIFICANT_GENES[HIT["id"]]["score"]=5
            else:
                STOP=True
                break
        SLICE+=100

##################################### Genes that have known high impact mutations
    SERVER_GENES="https://dcc.icgc.org/api/v1/genes"
    FILTERS_GENES={
                    "donor":{"primarySite":{"is":[CANCER_TYPE]}
                    ,"availableDataTypes":{"is":["ssm"]}}
                    ,"mutation":{"functionalImpact":{"is":["High"]}}
                    }
    FILTERS_GENES=json.dumps(FILTERS_GENES)

    MAX_GENES=int(requests.get("https://dcc.icgc.org/api/v1/genes/count?filters="+FILTERS_GENES).text)
    CASE_NUMBER=int(requests.get("https://dcc.icgc.org/api/v1/donors/count?filters="+FILTERS_GENES).text)

    SLICE=1
    while SLICE < MAX_GENES:
        PARAMS_GENES = {
            "filters": FILTERS_GENES,
            "format": "JSON",
            "size": "100",
            "from": str(SLICE)
            }

        TRY=1
        while TRY <= 10:
            try:
                request_genes=requests.get(SERVER_GENES, params=PARAMS_GENES)
                response_genes=request_genes.text
                response_genes=json.loads(response_genes)
                hits_genes=response_genes["hits"]
                break
            except:
                if TRY==10:
                    sys.exit("Error while requesting from ENSEMBL database after", TRY,  "tries")
                TRY +=1

        for HIT in hits_genes:
            #OCCURRENCE=float(float(HIT["affectedDonorCountFiltered"])/float(CASE_NUMBER))
            if HIT["id"] in SIGNIFICANT_GENES:
                SIGNIFICANT_GENES[HIT["id"]]["score"]+=1
        SLICE+=100

##################################### Return
    print ("Selecting genes with a minimal occurrence of "+str(MIN_SUPPORT)+"/"+str(CASE_NUMBER)+"="+str(float(MIN_SUPPORT)*CASE_NUMBER))
    print (len(SIGNIFICANT_GENES))
    return SIGNIFICANT_GENES


#############################################   OVERLAP GENES THAT OVERLAP WITH GIVEN SV VCF AND TCGA CANCER GENES   #############################################
def vcf_annotate_ICGC_genes_overlap(INPUT_VCF, OUTPUT_VCF, ICGC_GENES, REGIONS):
    with open(INPUT_VCF, "r") as INPUT, open (OUTPUT_VCF, "w") as OUTPUT:

        count_pros_overlap=0
        count_gene_no_overlap=0
        count_no_gene=0
        x=0
        VCF_READER=pyvcf.Reader(INPUT)
        VCF_READER.infos['ICGC_SCORE']=pyvcf.parser._Info('ICGC_SCORE', 1, "Integer", "Score of ICGC cancer genes (occurrence>"+str(MIN_SUPPORT)+") overlapping with the SV region (+"+str(FLANK)+"bp flanking region)", "NanoSV", "X")
        VCF_READER.infos['ICGC_OVERLAP']=pyvcf.parser._Info('ICGC_OVERLAP', ".", "String", "ICGC cancer gene (icgc_score>3) ordered from high ICGC_SCORE to low ICGC_SCORE overlapping with the SV region (+"+str(FLANK)+"bp flanking region)", "NanoSV", "X")
        # 0 = No overlap
        # 1 = Overlap ----> occurrene > MIN_SUPPORT
        # 2 = Overlap ----> occurrene > MIN_SUPPORT + impact==HIGH
        # 3 = Overlap ----> occurrene > MIN_SUPPORT + cancer gene
        # 4 = Overlap ----> occurrene > MIN_SUPPORT + impact==HIGH + cancer gene
        # 5 = Overlap ----> occurrene > 20% + cancer gene
        # 6 = Overlap ----> occurrene > 20% + cancer gene + impact==HIGH

        VCF_WRITER=pyvcf.Writer(OUTPUT, VCF_READER, lineterminator='\n')
        GO={}

        print ("ID" + "\t" + "TYPE" + "\t" + "LENGTH" + "\t" + "ICGC_OVERLAP_COUNT" + "\t" + "ICGC_SCORE" + "\t" + "ICGC_OVERLAP")
        for record in VCF_READER:
            x+=1
            overlap=0

            ENSEMBLE_OVERLAP=REGIONS[record.ID]["GENES"]
            OVERLAP=set(ENSEMBLE_OVERLAP).intersection(ICGC_GENES)

            SCORE=0
            GENE=[]
            for gene in OVERLAP:
                gene_score=ICGC_GENES[gene]["score"]

                if gene_score > SCORE:
                    SCORE=gene_score
                    if gene_score >= 3:
                        GENE.insert(0, ICGC_GENES[gene]["symbol"])
                elif gene_score >= 3:
                    GENE.append(ICGC_GENES[gene]["symbol"])
            record.INFO["ICGC_SCORE"]=SCORE

            if len(GENE) > 0:
                record.INFO["ICGC_OVERLAP"]=",".join(GENE)
            VCF_WRITER.write_record(record)


            if len(OVERLAP)>0:
                if "SVLEN" in record.INFO:
                    print (str(record.ID) + "\t" + str(record.ALT[0]) + "\t" + str(record.INFO["SVLEN"][0]) + "\t" + str(len(OVERLAP)) + "\t" + str(len(GENE)) + "\t" + str(SCORE) + "\t" + str(",".join(GENE)))
                else:
                    print (str(record.ID) + "\t" + "TRANS" + "\t" + "NA" + "\t" + str(len(GENE)) + "\t" + str(SCORE) + "\t" + str(",".join(GENE)))
                count_pros_overlap+=1
            elif len(REGIONS[record.ID]["GENES"])>0:
                count_gene_no_overlap+=1
            elif len(REGIONS[record.ID]["GENES"])==0:
                count_no_gene +=1

        print ("\n" +"Total nr of genes: "+ str(x))
        print ("ICGC overlap: ",count_pros_overlap)
        print ("Gene overlap but none are in ICGC database: ",count_gene_no_overlap)
        print ("No gene overlap: ", count_no_gene)


#############################################   RUNNING CODE   #############################################
VCF_IN=args.vcf
VCF_GENE_SELECTED=args.output
FLANK=args.flank
MIN_SUPPORT=args.support
CANCERTYPE=args.cancertype
CANCERTYPE=CANCERTYPE.capitalize()

print("Selecting regions from VCF")
REGIONS=regions_from_vcf(VCF_IN)
print("Done")
print("Overlapping regions with known ENSEMBL GENES")
OVERLAP=overlap_ENSEMBLE(REGIONS)
print("Done")
print("Creating a list of ICGC genes with their respective score for "+CANCERTYPE)
KNOWN_GENES=create_ICGC_gene_list(CANCERTYPE, MIN_SUPPORT)
print("Done")
print("Overlapping genes per SV with ICGC genes")
vcf_annotate_ICGC_genes_overlap(VCF_IN, VCF_GENE_SELECTED, KNOWN_GENES, OVERLAP)
print("Done")
