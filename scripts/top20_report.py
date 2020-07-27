import vcf as pyvcf
import argparse
import re

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description='Put here a description.')
parser.add_argument('vcf', help='VCF file')
parser.add_argument('primers', help='Ranked primers file')
parser.add_argument('outvcf', help='Output VCF file')
parser.add_argument('outtsv', help='Output TSV file')

args = parser.parse_args()
vcf = args.vcf
ranked_primers_file = args.primers
outvcf = args.outvcf
outtsv=args.outtsv

primers = dict()

with(open(ranked_primers_file, 'r')) as p:
    counter = 1
    for line in p:
        if counter <= 20:
            line = line.rstrip()
            columns = line.split("\t")
            primers[columns[0]] = {"fw_id":columns[1], "fw_seq":columns[2], "rv_id":columns[3], "rv_seq":columns[4]}
            counter += 1
        else: 
            break

vcf_reader = pyvcf.Reader(open(vcf, 'r'))
vcf_writer = pyvcf.Writer(open(outvcf, 'w'), vcf_reader)
tsv_writer = open(outtsv, 'w')
tsv_writer.write('\t'.join(["chr1", "pos1", "chr2", "pos2", "ori", "rank", "id", "primer_fw_id", "primer_fw_seq", "primer_rv_id", "primer_rv_seq"])+'\n')

for record in vcf_reader:
    if record.ID in primers:
        vcf_writer.write_record(record)
        chr1 = str(record.CHROM)
        pos1 = str(record.POS)
        alt = str(record.ALT[0])
        alt_match = re.search("^(\w*\]|\w*\[)(\w+):(\d+)(\]\w*|\[\w*)$", alt)
        chr2 = alt_match.group(2)
        pos2 = alt_match.group(3)
        ori = ""
        if alt_match.group(1) == "]" or alt_match.group(1) == "[":
            ori += "-"
        else:
            ori += "+"
        if "[" in alt_match.group(4):
            ori += "-"
        else:
            ori += "+"
        rank = str(record.INFO["SHARC_RANK"])
        fw_id = primers[record.ID]["fw_id"]
        fw_seq = primers[record.ID]["fw_seq"]
        rv_id = primers[record.ID]["rv_id"]
        rv_seq = primers[record.ID]["rv_seq"]
        tsv_writer.write('\t'.join([chr1, pos1, chr2, pos2, ori, rank, record.ID, fw_id, fw_seq, rv_id, rv_seq])+'\n')