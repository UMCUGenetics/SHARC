#!/usr/bin/python

import sys
import vcf as pyvcf

bed_features = dict()

bed_file = sys.argv[1]
feature = bed_file.split("/")[-1].split(".")[0]
feature_label = feature.upper()+'_DISTANCE'
vcf_file = sys.argv[2]

with( open( bed_file, 'r' ) ) as bed:
	for line in bed:
		line = line.rstrip()
		chr, start, end = line.split("\t")
		chr = chr.replace('chr','')
		start, end = int(start), int(end)
		if not chr in bed_features:
			bed_features[chr] = dict()
		if not start in bed_features[chr]:
			bed_features[chr][start] = dict()
		bed_features[chr][start][end] = 1

vcf_reader = pyvcf.Reader(open(vcf_file,'r'))
vcf_reader.infos[feature_label]=pyvcf.parser._Info(feature_label, 2, "Integer", "Distance to the closest "+feature, False, False)
vcf_writer = pyvcf.Writer(open('/dev/stdout','w'),vcf_reader)

for record in vcf_reader:
	chrom = record.CHROM.replace('chr','')
	pos1 = record.POS
	if isinstance(record.ALT[0], pyvcf.model._Breakend):
		chrom2 = record.ALT[0].chr
		pos2 = record.ALT[0].pos
	elif 'CHR2' in record.INFO:
		chrom2 = record.INFO['CHR2']
	else:
		chrom2 = chrom
	if 'END' in record.INFO:
		pos2 = record.INFO['END']

	distance1 = 9999999999999
	b = False
	if chrom in bed_features:
		for s in sorted( bed_features[chrom].keys() ):
			for e in sorted( bed_features[chrom][s].keys() ):
				if e <= pos1:
					d1 = abs(pos1-e)
				else:
					if s <= pos1:
						d1 = 0
					else:
						d1 = abs(pos1-s)
				if d1 < distance1:
					distance1 = d1
				else:
					b = True
					break
			if s > pos1 and b:
				break

	distance2 = 9999999999999
	b = False

	if chrom2 in bed_features:
		for s in sorted( bed_features[chrom2].keys() ):
			for e in sorted( bed_features[chrom2][s].keys() ):
				if e <= pos2:
					d2 = abs(pos2-e)
				else:
					if s <= pos2:
						d2 = 0
					else:
						d2 = abs(pos2-s)
				if d2 < distance2:
					distance2 = d2
				else:
					b = True
					break
			if s > pos2 and b:
				break

	record.INFO[feature_label] = [distance1, distance2]
	vcf_writer.write_record(record)
