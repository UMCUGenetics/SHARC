import vcf as pyvcf
import argparse

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description='Put here a description.')
parser.add_argument('vcf', help='VCF file')
parser.add_argument('primers', help='Primers file')
args = parser.parse_args()
vcf = args.vcf
primers_file = args.primers

primers = dict()

with(open(primers_file, 'r')) as p:
    for line in p:
        line = line.rstrip()
        columns = line.split("\t")
        primers[columns[0]] = 1

vcf_reader = pyvcf.Reader(open(vcf, 'r'))
vcf_writer = pyvcf.Writer(open('/dev/stdout', 'w'), vcf_reader)

for record in vcf_reader:
    if record.ID in primers:
        vcf_writer.write_record(record)
