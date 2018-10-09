
import sys

ids = dict()

vcf_file = sys.argv[1]
predict = sys.argv[2]

with(open(predict,'r')) as p:
	for line in p:
		line = line.rstrip()
		id, label = line.split("\t")
		ids[id] = label

with(open(vcf_file,'r')) as vcf:
	for line in vcf:
		line = line.rstrip()
		columns = line.split("\t")
		if line.startswith("##"):
			print(line)
		elif line.startswith("#"):
			print("##INFO=<ID=PREDICT_LABEL,Number=1,Type=Integer,Description=\"Predict label of the random forest\">")
			print(line)
		else:			
			if columns[2] in ids:
				label = ids[columns[2]]
				columns[7] = "PREDICT_LABEL="+label+";"+columns[7]
			else:
				columns[7] = "PREDICT_LABEL="+"NA"+";"+columns[7]
		
			print("\t".join(columns))
			