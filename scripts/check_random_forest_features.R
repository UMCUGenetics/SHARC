library(randomForest)


load("randomforest_v3_3overlap_p95_r98_pc0.38.Rdata")

test_feature_table <- read.table("/data/hpc/cog_bioinf/kloosterman/shared/SHARC/randomForest_finalcheck/Pros1/sharc/features_table.txt",sep="\t",header=T)
test_mean_cov <- 2

test_total_cov <- (test_feature_table$dr1+test_feature_table$dr2+test_feature_table$dv1+test_feature_table$dv2)
test_feature_table$total_cov_norm <- round(test_total_cov/test_mean_cov)
test_feature_table$vaf <- (test_feature_table$dv1+test_feature_table$dv2)/test_total_cov
test_feature_table <- test_feature_table[,-which(colnames(test_feature_table) %in% c("dr1","dr2","dv1","dv2"))]

id <- test_feature_table[test_feature_table$id == 1277,]

predictions <- c()

for (k in c(1:500)) {
  tree_table <- getTree(output.forest, k=k, labelVar = TRUE)

  rownr <- 1
  while(rownr <= nrow(tree_table)) {
    feature <- as.character(tree_table[rownr,]$`split var`)
    if (is.na(feature)) {
      #print(tree_table[rownr,])
      predictions <- append(predictions,tree_table[rownr,]$prediction)
      break
    }
    else {
      #print(tree_table[rownr,])
      feature_value <- id[,feature]
      if (feature_value <= tree_table[rownr,]$`split point`) {
        rownr <- tree_table[rownr,]$`left daughter`
      }
      else {
        rownr <- tree_table[rownr,]$`right daughter`
      }
    }
  }
}

table(predictions)




