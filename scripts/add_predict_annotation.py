#!/usr/bin/python

import sys
import vcf as pyvcf

ids = dict()

vcf_file = sys.argv[1]
predict = sys.argv[2]

with(open(predict,'r')) as p:
	for line in p:
		line = line.rstrip()
		id, label = line.split("\t")
		ids[id] = label

vcf_reader = pyvcf.Reader(open(vcf_file,'r'))
vcf_reader.infos['PREDICT_LABEL']=pyvcf.parser._Info('PREDICT_LABEL', 1, "Integer", "Predict label of the random forest", False, False)
vcf_writer = pyvcf.Writer(open('/dev/stdout','w'),vcf_reader)
for record in vcf_reader:
	if record.ID in ids:
		record.INFO['PREDICT_LABEL']=ids[record.ID]
	vcf_writer.write_record(record)
