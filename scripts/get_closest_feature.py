#!/usr/bin/python

import sys
import re

bed_features = dict()

bed_file = sys.argv[1]
feature = bed_file.split("/")[-1].split(".")[0]
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

with( open( vcf_file, 'r' ) ) as vcf:
	for line in vcf:
		line = line.rstrip()
		if not line.startswith("#"):
			columns = line.split("\t")
			chrom, pos1, id, ref, alt, qual, filter, info = columns[:8]
			chrom = chrom.replace("chr","")
			pos1 = int(pos1)
			
			alt_match = re.search("^(\w*\]|\w*\[)(\w+):(\d+)(\]\w*|\[\w*)$", alt)
			chrom2_match = re.search("CHR2=(.+?)(;|$)", info)
			end_match = re.search("END=(\d+)(;|$)", info)
			
			chrom2 = chrom
			if chrom2_match:
				chrom2 = chrom2_match.group(1)
			elif alt_match:
				chrom2 = alt_match.group(2)
			chrom2 = chrom2.replace("chr","")
			
			pos2 = 0
			if end_match:
				pos2 = end_match.group(1)
			elif alt_match:
				pos2 = alt_match.group(3)
			pos2 = int(pos2)
			
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
			b= False
			
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
					
			columns[7] += ";"+feature+"_distance="+str(distance1)+","+str(distance2)
			print "\t".join(columns)
			
				