library(randomForest)

load("/hpc/cog_bioinf/kloosterman/common_scripts/sharc/scripts/randomforest_vl_v3_3overlap_p96_r99.5_pc0.39.Rdata")

args <- commandArgs(trailingOnly = TRUE)

test_feature_table <- read.table(args[1],sep="\t",header=T)
test_mean_cov <- as.integer(args[2])

test_total_cov <- (test_feature_table$dr1+test_feature_table$dr2+test_feature_table$dv1+test_feature_table$dv2)
test_feature_table$total_cov_norm <- round(test_total_cov/test_mean_cov)
test_feature_table$vaf <- (test_feature_table$dv1+test_feature_table$dv2)/test_total_cov
test_feature_table <- test_feature_table[,-which(colnames(test_feature_table) %in% c("dr1","dr2","dv1","dv2"))]

test.forest <- predict(output.forest,newdata=test_feature_table)
test_feature_table$pred <- predict(output.forest,newdata=test_feature_table)
table(test.forest)

write.table(test_feature_table[,c("id","pred")],paste(dirname(args[1]),"/predict_labels.txt",sep=""),quote=F,sep="\t",row.names=F,col.names=F)
