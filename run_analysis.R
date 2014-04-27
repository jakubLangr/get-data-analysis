library(plyr)
setwd('UCI_HAR_Dataset/')
read.table("train/X_train.txt",sep="",header=F) -> X_train
read.table("test/X_test.txt",sep="",header=F) -> X_test
X = rbind(X_train,X_test)
descriptions = read.table('features.txt',sep='',header=F)
descriptions = descriptions[,2]
names(X) = descriptions
selected = grep("mean|std",names(X))
measurements = X[,selected]
train_labels = read.table("train/y_train.txt",sep="",header=F)
test_labels = read.table("test/y_test.txt",sep="",header=F)
labels = rbind(train_labels,test_labels)$V1
# rename the lables to match descriptions
labeled_measurements = cbind(measurements,labels)
subject_train = read.table("train/subject_train.txt",sep="",header=F)
subject_test = read.table("test/subject_test.txt",sep="",header=F)
subjects = rbind(subject_train,subject_test)
cbind(labeled_measurements,subjects) -> final
names(final)[81] = "subjects"
new = aggregate(final, list(final$labels,final$subject),mean)

final_labels = revalue(as.factor(final$labels), c("1"="WALKING", "2"="WALKING_UPSTAIRS", "3"="WALKING_DOWNSTAIRS","4"="SITTING","5"="STANDING","6"="LAYING"))
final_labelled = final
final_labelled$labels <- final_labels

new_labels = revalue(as.factor(new$labels), c("1"="WALKING", "2"="WALKING_UPSTAIRS", "3"="WALKING_DOWNSTAIRS","4"="SITTING","5"="STANDING","6"="LAYING"))
new_labelled = new
new_labelled$labels = new_labels

write.table(final_labelled, file="final_output.txt", sep="\t", row.names=FALSE)
write.table(new_labelled, file="step5_output.txt", sep="\t", row.names=FALSE)
