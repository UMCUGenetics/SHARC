
library(randomForest)
library(ROCR)

raw_data <- read.table("../NA12878_features_table.txt",sep="\t",header=T)
meta <- read.table("../NA12878_train.txt",sep="\t",header=T)
mean_cov <- 30
p <- 10
random <- 100

data <- raw_data
total_cov <- (data$dr1+data$dr2+data$dv1+data$dv2)
data$total_cov_norm <- round(total_cov/mean_cov)
data$vaf <- (data$dv1+data$dv2)/total_cov
data <- merge(data, meta,by="id",all.x=T)
data <- data[,-which(colnames(data) %in% c("dr1","dr2","dv1","dv2"))]
data$val <- as.vector(data$val)

match_data <- data[which(data$val == 1),]
unmatch_data <- data[which(data$val == 0),]

n <- 400
match_data_train_rows <- sample(c(1:nrow(match_data)),n)
match_data_test_rows <- c(1:nrow(match_data))[-match_data_train_rows]
unmatch_data_train_rows <- sample(c(1:nrow(unmatch_data)),length(match_data_train_rows))
unmatch_data_test_rows <- sample(as.vector(c(1:nrow(unmatch_data))[-unmatch_data_train_rows]),length(match_data_test_rows))

train_data <- rbind(match_data[match_data_train_rows,],unmatch_data[unmatch_data_train_rows,])
train_data2 <- rbind(match_data[match_data_train_rows,],unmatch_data[unmatch_data_train_rows,])
train_data$val <- as.vector(train_data$val)
train_data <- train_data[,-1]

test_data <- rbind(match_data[match_data_test_rows,],unmatch_data[unmatch_data_test_rows,])

output.forest <- randomForest(as.factor(val) ~ ., data=train_data)
print(output.forest)
importance(output.forest,type=2)

val_1 <- floor(nrow(train_data[train_data$val == 1,])/p)
val_0 <- floor(nrow(train_data[train_data$val == 0,])/p)

folds <- list()
for ( x in c(1:random)) {
  print(paste("X=",x))
  rows <- c(sample(which(train_data$val == 1),val_1),sample(which(train_data$val == 0),val_0))
  subset.train <- train_data[-rows,]
  subset.test <- train_data[rows,]
  subset.forest <- randomForest(as.factor(val) ~ . , data=subset.train)
  subset.forest
  importance(subset.forest,type=2)
  subset.OOB.votes <- predict(subset.forest,subset.test[-ncol(subset.test)],type='prob')
  subset.OOB.pred <- subset.OOB.votes[,2]
  subset.pred.obj <- prediction(subset.OOB.pred,as.factor(subset.test$val))
  
  folds[[x]] <- cbind(as.numeric(subset.pred.obj@predictions[[1]]),  as.numeric(as.vector(subset.pred.obj@labels[[1]])))
  folds[[x]] <- folds[[x]][order(folds[[x]][,1],decreasing = T),]
}

recall_matrix <- matrix(nrow=(val_1+val_0),ncol=random)
precision_matrix <- matrix(nrow=(val_1+val_0),ncol=random)
for ( r in c(1:nrow(folds[[1]])) ) {
  recall <- r/nrow(folds[[1]])
  for ( f in c(1:random) ) {
    precision <- length(which(folds[[f]][1:r,2] == 1))/r
    recall2 <- length(which(folds[[f]][1:r,2] == 1))/val_1
    recall_matrix[r,f] <- recall2
    precision_matrix[r,f] <- precision
  }
}

rp_matrix2 <- cbind(apply(recall_matrix,1,mean),apply(precision_matrix,1,mean))
plot(rp_matrix2,type='l',ylim=c(0,1.2))
points(rp_matrix2[,1],rp_matrix2[,2]-apply(precision_matrix,1,sd),type='l',col='red')
points(rp_matrix2[,1],rp_matrix2[,2]+apply(precision_matrix,1,sd),type='l',col='red')

rp_matrix2


operation_point <- 40
precision <- rp_matrix2[operation_point,2]
recall <- rp_matrix2[operation_point,1]
prob_cutoff <- mean(unlist(lapply(folds,`[`,operation_point)))
output.forest <- randomForest(as.factor(val) ~ ., data=train_data,cutoff=c(1-prob_cutoff,prob_cutoff))
print(output.forest)
importance(output.forest,type=2)

forest <- predict(output.forest,newdata=test_data)
test_data$pred <- forest
table(test_data[,c("val","pred")])

#train_data$pred <- output.forest$predicted
#train_data$id <- train_data2$id

save(output.forest,file="randomforest.Rdata")












