#!/usr/bin/python

import requests
import json
import vcf as pyvcf
import sys
import argparse
import difflib

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description='Put here a description.')

#REQUIRED ARGUMENTS
parser.add_argument('vcf', help='VCF file')
parser.add_argument('-c', '--cancertype', type=str, help='Primary site of cancer', required=True)
parser.add_argument('-o', '--output', type=str, help='VCF output file', required=True)
parser.add_argument('-f', '--flank', type=int, help='Number of basepairs that are taken around a breakpoint', required=True)
parser.add_argument('-a', '--attributes_output', type=str, help='Output for feature table', required=True)
parser.add_argument('-id', '--icgc_database_directory', type=str, help='Directory containing ICGC files for genes in cancer types', required=True)

#OPTIONAL ARGUMENTS
parser.add_argument('-cb', '--cosmic_breakpoints', type=str, help='COSMIC .csv containing known breakpoints for a specific cancer type')
parser.add_argument('-s', '--support', type=float, help='Minimal percentage of cancer patients supporting the mutated gene (default=average occurence)')

args = parser.parse_args()

#############################################   Convert different vcf sv notations to bracket notations N[Chr:pos[   #############################################
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


#############################################   Filter out regions around breakpoints from given vcf file   #############################################
def regions_from_vcf(INPUT_VCF, REGION_FLANK=0):
    with open(INPUT_VCF, "r") as vcf:
        VCF_READER=pyvcf.Reader(vcf)

        SV_DATA={}

        for record in VCF_READER:
            BEGIN_CHROM = str(record.CHROM)
            BEGIN_POS = record.POS
            ID=str(record.ID)
            SV_DATA[ID]={"REGION":[]}

            if "INS" in str(record.ALT[0]):
                REGION_START=BEGIN_POS-REGION_FLANK
                REGION_END=BEGIN_POS+1+REGION_FLANK
                SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START, "End":REGION_END})

            else:
                if not isinstance(record.ALT[0], pyvcf.model._Breakend):
                    record = alt_convert(record)

                END_CHROM = record.ALT[0].chr
                END_POS = record.ALT[0].pos

                if END_CHROM != BEGIN_CHROM:
                    if record.ALT[0].orientation and record.ALT[0].remoteOrientation:
                        REGION_START_1 = BEGIN_POS-1-REGION_FLANK
                        REGION_END_1 = BEGIN_POS+REGION_FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START_1, "End":REGION_END_1})
                        REGION_START_2 = END_POS-1-REGION_FLANK
                        REGION_END_2 = END_POS+REGION_FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":END_CHROM, "Start":REGION_START_2, "End":REGION_END_2})
                        continue
                    elif not record.ALT[0].orientation and record.ALT[0].remoteOrientation:
                        REGION_START_1 = BEGIN_POS-REGION_FLANK
                        REGION_END_1 = BEGIN_POS+1+REGION_FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START_1, "End":REGION_END_1})
                        REGION_START_2 = END_POS-1-REGION_FLANK
                        REGION_END_2 = END_POS+REGION_FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":END_CHROM, "Start":REGION_START_2, "End":REGION_END_2})
                        continue
                    elif record.ALT[0].orientation and not record.ALT[0].remoteOrientation:
                        REGION_START_1 = BEGIN_POS-1-REGION_FLANK
                        REGION_END_1 = BEGIN_POS+REGION_FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START_1, "End":REGION_END_1})
                        REGION_START_2 = END_POS-REGION_FLANK
                        REGION_END_2 = END_POS+1+REGION_FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":END_CHROM, "Start":REGION_START_2, "End":REGION_END_2})
                        continue
                    elif not record.ALT[0].orientation and not record.ALT[0].remoteOrientation:
                        REGION_START_1 = BEGIN_POS-REGION_FLANK
                        REGION_END_1 = BEGIN_POS+1+REGION_FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START_1, "End":REGION_END_1})
                        REGION_START_2 = END_POS-REGION_FLANK
                        REGION_END_2 = END_POS+1+REGION_FLANK
                        SV_DATA[ID]["REGION"].append({"Chrom":END_CHROM, "Start":REGION_START_2, "End":REGION_END_2})
                        continue
                else:
                    REGION_START = BEGIN_POS-REGION_FLANK
                    REGION_END = END_POS+REGION_FLANK
                    SV_DATA[ID]["REGION"].append({"Chrom":BEGIN_CHROM, "Start":REGION_START, "End":REGION_END})
        return (SV_DATA)

#############################################   Overlap all regions from vcf with ENSEMBL genes   #############################################
def overlap_ENSEMBL(REGIONS):
    SERVER="https://GRCh37.rest.ensembl.org/overlap/region/"
    SPECIES="human"
    HEADERS={"Content-Type" : "application/json"}
    BREAKPOINT_FEATURES={}
    for ID in REGIONS:
        REGIONS[ID]["GENES"]=[]
        BREAKPOINT_FEATURES[int(ID)]={}
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
                            sys.exit("Error while requesting from ENSEMBL database after "+str(TRY)+" tries")
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
                                sys.exit("Error while requesting from ENSEMBL database after "+str(TRY)+" tries")
                            TRY +=1

                    if isinstance(data, list):
                        REGIONS[ID]["GENES"]=REGIONS[ID]["GENES"]+[gene["id"] for gene in data]
                    else:
                        print ("Error:", data["error"])
                        REGIONS[ID]["GENES"]=[]
                        break
                    TEMP_SV_START=TEMP_SV_END
        BREAKPOINT_FEATURES[int(ID)]["ENSEMBL_OVERLAP"]=len(REGIONS[ID]["GENES"])
    return (REGIONS, BREAKPOINT_FEATURES)

#############################################   Load or create a list of genes with occurrence and cancer census from ICGC   #############################################

def create_ICGC_gene_list(CANCER_TYPE, DATABASE_OUTPUT_DIR):

############################ Check all possible primary sites and convert given cancer type to the most likely primary site name in ICGC
    SERVER_PRIMARY_SITES="https://dcc.icgc.org/api/v1/projects"

    PARAMS_PRIMARY_SITES = {
        "field": "primarySite",
        "format": "JSON",
        "size": "1000"
        }

    TRY=1
    while TRY <= 10:
        try:
            request_primary_sites=requests.get(SERVER_PRIMARY_SITES, params=PARAMS_PRIMARY_SITES)
            response_primary_sites=request_primary_sites.text
            response_primary_sites=json.loads(response_primary_sites)
            hits_primary_sites=response_primary_sites["hits"]
            break
        except:
            if TRY==4:
                sys.exit("Error while requesting from ICGC database after "+str(TRY)+" tries")
            TRY +=1

    PRIMARY_SITES=[]
    for hit in hits_primary_sites:
        if hit["primarySite"] not in PRIMARY_SITES:
            PRIMARY_SITES.append(hit["primarySite"])

    print ("Possible primary sites:", str(", ".join(PRIMARY_SITES)))

    CANCER_TYPE=difflib.get_close_matches(CANCER_TYPE, PRIMARY_SITES, n=1, cutoff=0)[0]
    CANCER_TYPE_FILENAME="_".join(difflib.get_close_matches(CANCER_TYPE, PRIMARY_SITES, n=1, cutoff=0)[0].split(" "))

    print("Given cancer type ("+ str(CANCERTYPE)+") most resembles \""+CANCER_TYPE+ "\"")

############################ Check if file already exists
    DATABASE=str(DATABASE_OUTPUT_DIR)+"/ICGC_"+str(CANCER_TYPE_FILENAME)+".txt"
    try:
        with open(DATABASE, "r") as ICGC_GENES:
            print ("CNVs have already been selected from database")
            print ("Loading CNVs...")
            DATABASE_GENES={}
            for line in ICGC_GENES:
                if not line.startswith("#"):
                    line=line.strip()
                    columns=line.split("\t")
                    ensembl_id=columns[0]
                    symbol=columns[1]
                    occurrence=float(columns[2])
                    cancer_census=columns[3]
                    if cancer_census=="True":
                        cancer_census=True
                    else:
                        cancer_census=False
                    high_impact_mutation=columns[4]
                    if high_impact_mutation=="True":
                        high_impact_mutation=True
                    else:
                        high_impact_mutation=False
                    score=int(columns[5])
                    DATABASE_GENES[ensembl_id]={"symbol":symbol,"occurrence":occurrence,"cancer_census":cancer_census, "high_impact_mutation":high_impact_mutation, "score": score}
            return (DATABASE_GENES)
    except:
        pass
############################ Select all genes from ICGC in specific cancer type
    print("Selecting all ICGC genes in "+CANCER_TYPE.lower()+" cancer")
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
        print(str(SLICE))
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
                    sys.exit("Error while requesting from ICGC database after "+str(TRY)+" tries")
                TRY +=1

        for HIT in hits_genes:
            OCCURRENCE=float(float(HIT["affectedDonorCountFiltered"])/float(CASE_NUMBER))
            SIGNIFICANT_GENES[HIT["id"]]={}
            SIGNIFICANT_GENES[HIT["id"]]["score"]=0
            SIGNIFICANT_GENES[HIT["id"]]["symbol"]=HIT["symbol"]
            SIGNIFICANT_GENES[HIT["id"]]["cancer_census"]=False
            SIGNIFICANT_GENES[HIT["id"]]["high_impact_mutation"]=False
            SIGNIFICANT_GENES[HIT["id"]]["occurrence"]=OCCURRENCE

        SLICE+=100
    print("Done")

##################################### Selecting all cancer genes from ICGC
    print("Selecting all ICGC cancer genes in "+CANCER_TYPE.lower()+" cancer")

    SERVER_GENES="https://dcc.icgc.org/api/v1/genes"
    FILTERS_GENES={
                    "donor":{"primarySite":{"is":[CANCER_TYPE]}
                    ,"availableDataTypes":{"is":["ssm"]}}
                    ,"gene":{"curatedSetId":{"is":["GS1"]}}
                    }
    FILTERS_GENES=json.dumps(FILTERS_GENES)

    MAX_GENES=int(requests.get("https://dcc.icgc.org/api/v1/genes/count?filters="+FILTERS_GENES).text)
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
                    sys.exit("Error while requesting from ICGC database after " +TRY+ "tries")
                TRY +=1


        for HIT in hits_genes:
            OCCURRENCE=float(float(HIT["affectedDonorCountFiltered"])/float(CASE_NUMBER))
            if HIT["id"] in SIGNIFICANT_GENES:
                SIGNIFICANT_GENES[HIT["id"]]["cancer_census"]=True
            else:
                SIGNIFICANT_GENES[HIT["id"]]={}
                SIGNIFICANT_GENES[HIT["id"]]["cancer_census"]=True
                SIGNIFICANT_GENES[HIT["id"]]["symbol"]=HIT["symbol"]
                SIGNIFICANT_GENES[HIT["id"]]["occurrence"]=OCCURRENCE

        SLICE+=100
    print("Done")

##################################### Select genes that have known high impact mutations
    print("Selecting all genes that have known high impact mutation in "+CANCER_TYPE.lower()+" cancer")
    SERVER_GENES="https://dcc.icgc.org/api/v1/genes"
    FILTERS_GENES={
                    "donor":{"primarySite":{"is":[CANCER_TYPE]}
                    ,"availableDataTypes":{"is":["ssm"]}}
                    ,"mutation":{"functionalImpact":{"is":["High"]}}
                    }
    FILTERS_GENES=json.dumps(FILTERS_GENES)
    MAX_GENES=int(requests.get("https://dcc.icgc.org/api/v1/genes/count?filters="+FILTERS_GENES).text)

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
                    sys.exit("Error while requesting from ICGC database after "+str(TRY)+" tries")
                TRY +=1

        for HIT in hits_genes:
            if HIT["id"] in SIGNIFICANT_GENES:
                SIGNIFICANT_GENES[HIT["id"]]["high_impact_mutation"]=True
        SLICE+=100
    print("Done")

##################################### Output the table with all genes selected
    OUTPUT=str(DATABASE_OUTPUT_DIR)+"/ICGC_"+str(CANCER_TYPE_FILENAME)+".txt"
    print("Writing ICGC information to "+OUTPUT)
    with open(OUTPUT, "w") as output:
        output.write("#ENSEMBL_ID"+ "\t" + "SYMBOL" + "\t" + "OCCURRENCE" + "\t" + "Cancer_gene" + "\t" + "high_impact_mutation" + "\t" + "score" + "\n")
        for gene in sorted(SIGNIFICANT_GENES.items(),key=lambda x: x[1]['occurrence'],reverse=True):
            gene=gene[0]
            output.write(str(gene) + "\t" + str(SIGNIFICANT_GENES[gene]["symbol"]) + "\t" + str(SIGNIFICANT_GENES[gene]["occurrence"]) + "\t" + str(SIGNIFICANT_GENES[gene]["cancer_census"])
            + "\t" + str(SIGNIFICANT_GENES[gene]["high_impact_mutation"]) + "\t" + str(SIGNIFICANT_GENES[gene]["score"]) + "\n")
    print("Done")
    return SIGNIFICANT_GENES


#############################################   OVERLAP GENES THAT OVERLAP WITH GIVEN SV VCF AND TCGA CANCER GENES   #############################################
def vcf_annotate_ICGC_genes_overlap(INPUT_VCF, OUTPUT_VCF, ICGC_GENES, REGIONS, BREAKPOINT_FEATURES, MINIMAL_SUPPORT):
    with open(INPUT_VCF, "r") as INPUT, open (OUTPUT_VCF, "w") as OUTPUT:

        VCF_READER=pyvcf.Reader(INPUT)
        VCF_READER.infos['ICGC_OVERLAP']=pyvcf.parser._Info('ICGC_OVERLAP', ".", "String", "ICGC cancer gene ordered from high occurrence to low occurrence overlapping with the SV region (+"+str(FLANK)+"bp flanking region)", "NanoSV", "X")
        VCF_WRITER=pyvcf.Writer(OUTPUT, VCF_READER, lineterminator='\n')

        occurrences=[]
        for gene in ICGC_GENES:
            occurrences.append(float(ICGC_GENES[gene]['occurrence']))
        total_genes=int(requests.get("https://dcc.icgc.org/api/v1/genes/count").text)
        occurrences=occurrences+[0]*(total_genes-len(occurrences))
        average_occurrence=float(sum(occurrences)/len(occurrences))
        print ("Average occurrence: "+str(average_occurrence))

        if MINIMAL_SUPPORT is None:
            MINIMAL_SUPPORT=average_occurrence

        print("Selecting only ICGC overlapping genes with a minimal occurrence of "+str(MINIMAL_SUPPORT*100)+"%")

        for record in VCF_READER:
            ID=int(record.ID)
            ENSEMBL_OVERLAP=REGIONS[record.ID]["GENES"]
            OVERLAP=set(ENSEMBL_OVERLAP).intersection(ICGC_GENES)
            if "SVLEN" in record.INFO:
                BREAKPOINT_FEATURES[ID]["SV_LENGTH"]=record.INFO["SVLEN"][0]
            else:
                BREAKPOINT_FEATURES[ID]["SV_LENGTH"]=0
            BREAKPOINT_FEATURES[ID]["ICGC_OVERLAP"]=0
            BREAKPOINT_FEATURES[ID]["ICGC_CANCER_GENE_OVERLAP"]=0
            BREAKPOINT_FEATURES[ID]["HIGHEST_OCCURRING_GENE"]=0
            BREAKPOINT_FEATURES[ID]["HIGHEST_OCCURRING_CANCER_GENE"]=0

            SCORE=0
            CANCER_GENES=[]
            for gene in OVERLAP:
                occurrence=ICGC_GENES[gene]["occurrence"]
                gene_score=ICGC_GENES[gene]["score"]
                cancer_census=ICGC_GENES[gene]["cancer_census"]
                high_impact=ICGC_GENES[gene]["high_impact_mutation"]

                if occurrence>=MINIMAL_SUPPORT:
                    BREAKPOINT_FEATURES[ID]["ICGC_OVERLAP"]+=1
                    if occurrence>BREAKPOINT_FEATURES[ID]["HIGHEST_OCCURRING_GENE"]:
                        BREAKPOINT_FEATURES[ID]["HIGHEST_OCCURRING_GENE"]=occurrence
                if cancer_census is True:
                    BREAKPOINT_FEATURES[ID]["ICGC_CANCER_GENE_OVERLAP"]+=1
                    if occurrence>BREAKPOINT_FEATURES[ID]["HIGHEST_OCCURRING_GENE"]:
                        BREAKPOINT_FEATURES[ID]["HIGHEST_OCCURRING_GENE"]=occurrence
                    if occurrence>BREAKPOINT_FEATURES[ID]["HIGHEST_OCCURRING_CANCER_GENE"]:
                        CANCER_GENES.insert(0, ICGC_GENES[gene]["symbol"])
                        BREAKPOINT_FEATURES[ID]["HIGHEST_OCCURRING_CANCER_GENE"]=occurrence
                    elif occurrence>MINIMAL_SUPPORT:
                        CANCER_GENES.append(ICGC_GENES[gene]["symbol"])
            if len(CANCER_GENES) > 0:
                record.INFO["ICGC_OVERLAP"]=",".join(CANCER_GENES)
            VCF_WRITER.write_record(record)
    return BREAKPOINT_FEATURES

def overlap_COSMIC(VCF, COSMIC_BREAKPOINT_CSV, BREAKPOINT_FEATURES):

    REGIONS=regions_from_vcf(VCF)

    with open(COSMIC_BREAKPOINT_CSV, "r") as file:
        SV=[]
        TRA=[]
        for line in file:
            if not line.startswith("SAMPLE"):
                line=line.strip()
                columns=line.split(",")
                begin_chrom=columns[15]
                end_chrom=columns[19]
                begin_pos=columns[16]
                end_pos=columns[21]

                if begin_chrom==end_chrom:
                    if end_pos < begin_pos:
                        end_pos=columns[16]
                        begin_pos=columns[21]
                    SV.append({"Chrom":str(begin_chrom), "Start":str(begin_pos), "End":str(end_pos)})
                else:
                    TRA.append({"Begin_chrom":str(begin_chrom), "Start":str(begin_pos), "End_chrom":str(end_chrom), "End":str(end_pos)})

    for ID in REGIONS:
        regions=REGIONS[ID]["REGION"]
        BREAKPOINT_FEATURES[int(ID)]["COSMIC_BREAKPOINT_OVERLAP"]=0
        if len(regions)==1: #and REGIONS[ID]["LENGTH"] > 200:
            for sv in SV:
                COSMIC_BREAKPOINT_OVERLAP=0

                COSMIC_LENGTH=abs(int(sv["End"])-int(sv["Start"]))

                DIS=float((int(regions[0]["End"])-int(regions[0]["Start"]))/4)
                if DIS>1000:
                    DIS=1000

                if (regions[0]["Chrom"]== sv["Chrom"] and
                abs(int(regions[0]["Start"])-int(sv["Start"]))<DIS and
                int(regions[0]["Start"])<int(sv["End"]) and
                int(regions[0]["End"])>int(sv["Start"]): #and
                #int(regions[0]["End"])-int(sv["Start"])>COSMIC_LENGTH*0.5):
                    #print (int(regions[0]["End"]), int(sv["Start"]))
                    print(ID)
                    print(sv)
                    COSMIC_BREAKPOINT_OVERLAP+=1
                if (regions[0]["Chrom"]== sv["Chrom"] and
                abs(int(regions[0]["End"])-int(sv["End"]))<DIS and
                int(regions[0]["End"])>int(sv["Start"]) and
                int(regions[0]["Start"])<int(sv["End"]): #and
                #int(regions[0]["Start"])-int(sv["End"])>COSMIC_LENGTH*0.5):
                    COSMIC_BREAKPOINT_OVERLAP+=1
                    #print (int(regions[0]["Start"]), int(sv["End"]))
                    print(ID)
                    print(sv)

                if COSMIC_BREAKPOINT_OVERLAP > BREAKPOINT_FEATURES[int(ID)]["COSMIC_BREAKPOINT_OVERLAP"]:
                    BREAKPOINT_FEATURES[int(ID)]["COSMIC_BREAKPOINT_OVERLAP"]=COSMIC_BREAKPOINT_OVERLAP
        elif len(regions)==2:
            for tra in TRA:
                COSMIC_BREAKPOINT_OVERLAP=0
                if ((regions[0]["Chrom"]== tra["Begin_chrom"] and abs(int(tra["Start"]) - int(regions[0]["Start"])) < 1000) or
                (regions[0]["Chrom"]== tra["End_chrom"] and abs(int(tra["End"]) - int(regions[0]["Start"])) < 1000) or
                (regions[1]["Chrom"]== tra["Begin_chrom"] and abs(int(tra["Start"]) - int(regions[1]["Start"])) < 1000) or
                (regions[1]["Chrom"]== tra["End_chrom"] and abs(int(tra["End"]) - int(regions[1]["Start"])) < 1000)):
                    print(ID)
                    print(tra)
                    COSMIC_BREAKPOINT_OVERLAP=1

                    if (((regions[0]["Chrom"]== tra["Begin_chrom"] and abs(int(tra["Start"]) - int(regions[0]["Start"])) < 1000) and
                    (regions[1]["Chrom"]== tra["End_chrom"] and abs(int(tra["End"]) - int(regions[1]["Start"])) < 1000)) or
                    ((regions[1]["Chrom"]== tra["Begin_chrom"] and abs(int(tra["Start"]) - int(regions[1]["Start"])) < 1000) and
                    (regions[0]["Chrom"]== tra["End_chrom"] and abs(int(tra["End"]) - int(regions[0]["Start"])) < 1000))):
                        COSMIC_BREAKPOINT_OVERLAP=2
                if COSMIC_BREAKPOINT_OVERLAP > BREAKPOINT_FEATURES[int(ID)]["COSMIC_BREAKPOINT_OVERLAP"]:
                    BREAKPOINT_FEATURES[int(ID)]["COSMIC_BREAKPOINT_OVERLAP"]=COSMIC_BREAKPOINT_OVERLAP
    return (BREAKPOINT_FEATURES)

#############################################   RUNNING CODE   #############################################
VCF_IN=args.vcf
VCF_GENE_SELECTED=args.output
FLANK=args.flank
MIN_SUPPORT=args.support
CANCERTYPE=args.cancertype
BREAKPOINT_FEATURES_OUTPUT=args.attributes_output
DATABASE_DIR=args.icgc_database_directory
COSMIC_SV=args.cosmic_breakpoints
if COSMIC_SV is None:
    print("################## NO COSMIC BREAKPOINT FILE GIVEN ")
    print("################## Skipping COSMIC database overlap ")
    print("################## To add specificity, download CosmicBreakpointsExport.tsv.gz for "+str(CANCERTYPE.lower())+" cancer from https://cancer.sanger.ac.uk/cosmic/download\n")

print("1) Selecting regions from VCF")
REGIONS=regions_from_vcf(VCF_IN, FLANK)
print("1) Done")

print("2) Overlapping regions with known ENSEMBL GENES")
OVERLAP, FEATURES=overlap_ENSEMBL(REGIONS)
print("2) Done")

print("3) Creating a list of ICGC genes with their respective score for "+CANCERTYPE)
KNOWN_GENES=create_ICGC_gene_list(CANCERTYPE, DATABASE_DIR)
print("3) Done")

print("4) Overlapping genes per SV with ICGC genes")
FEATURES=vcf_annotate_ICGC_genes_overlap(VCF_IN, VCF_GENE_SELECTED, KNOWN_GENES, OVERLAP, FEATURES, MIN_SUPPORT)
print("4) Done")


if COSMIC_SV is not None:
    print("5) Overlapping regions with known COSMIC breakpoints")
    FEATURES=overlap_COSMIC(VCF_IN, COSMIC_SV, FEATURES)
    print("5) Done")
else:
    print("5) No COSMIC file; Skipping COSMIC database overlap")

# print("6) Producing output")
# with open(BREAKPOINT_FEATURES_OUTPUT, "w") as output:
#     FIRST=True
#     for ID in sorted(list(FEATURES)):
#         if FIRST:
#             attributes=[]
#             for attribute, value in FEATURES[ID].items():
#                 attributes.append(str(attribute))
#             attributes=sorted(attributes)
#             output.write("ID"+"\t"+"\t".join(attributes) + "\n")
#             FIRST=False
#         values=[]
#         for attribute in attributes:
#             values.append(str(FEATURES[ID][attribute]))
#         output.write(str(ID)+"\t"+"\t".join(values) + "\n")
# print("6) Done")
