#! /usr/bin/python

import sys
import vcf as pyvcf

features = "id sr_distance1 sr_distance2 gap_distance1 gap_distance2 sd_distance1 sd_distance2 svlength mapq1 mapq2 pid1 pid2 cipos1 cipos2 plength1 plength2 ciend1 ciend2 rlength gap dr1 dr2 dv1 dv2".split()
print( "\t".join(features) )

vcf_file = sys.argv[1]

vcf_reader = pyvcf.Reader(open(vcf_file,'r'))

for record in vcf_reader:
    feature_values = list()
    feature_values.append(record.ID)
    feature_values.extend(record.INFO['SIMPLEREPEATS_DISTANCE'])
    feature_values.extend(record.INFO['GAP_DISTANCE'])
    feature_values.extend(record.INFO['SEGDUP_DISTANCE'])
    if 'SVLEN' in record.INFO:
        feature_values.extend(record.INFO['SVLEN'])
    else:
        feature_values.append(1000000)
    feature_values.extend(record.INFO['MAPQ'])
    feature_values.extend(record.INFO['PID'])
    feature_values.extend(record.INFO['CIPOS'])
    feature_values.extend(record.INFO['PLENGTH'])
    feature_values.extend(record.INFO['CIEND'])
    feature_values.append(record.INFO['RLENGTH'])
    feature_values.append(record.INFO['GAP'])
    feature_values.extend(record.samples[0]['DR'])
    feature_values.extend(record.samples[0]['DV'])

    print( "\t".join(map(str, feature_values)) )
