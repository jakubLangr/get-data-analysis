# Load needed library and potentially set up working directory (uncomment if necessary)
library(plyr)
#setwd('UCI_HAR_Dataset/')

# STEP 1 
# reads the training and test data table and binds them
read.table("train/X_train.txt",sep="",header=F) -> X_train
read.table("test/X_test.txt",sep="",header=F) -> X_test
X = rbind(X_train,X_test)

# STEP 4
# reads in the descriptions of variables and applies them to the joint 
descriptions = read.table('features.txt',sep='',header=F)
descriptions = descriptions[,2]
names(X) = descriptions

# STEP 2
# only selects the mean and std variables
selected = grep("mean|std",names(X))
measurements = X[,selected]

# get activity labels (only in numbers), merge them together and then with the data set
train_labels = read.table("train/y_train.txt",sep="",header=F)
test_labels = read.table("test/y_test.txt",sep="",header=F)
labels = rbind(train_labels,test_labels)$V1
labeled_measurements = cbind(measurements,labels)

# get subject numbers and merge them together and then with the data set
subject_train = read.table("train/subject_train.txt",sep="",header=F)
subject_test = read.table("test/subject_test.txt",sep="",header=F)
subjects = rbind(subject_train,subject_test)
cbind(labeled_measurements,subjects) -> final

# rename the column so that it reads 'subjects' instead of 'V1'
names(final)[81] = "subjects"

# STEP 5
# use aggergate on the final dataset aggregated on labels and subject and calculated average
# so that each unique (activity,subject) tuple has its own row with means of the variables as columns
new = aggregate(final, list(final$labels,final$subject),mean)

# STEP 3
# apply readable labels to each activity in both data files
# this is done after all the other transformations because otherwise 'aggregate' returns an error.
final_labels = revalue(as.factor(final$labels), c("1"="WALKING", "2"="WALKING_UPSTAIRS", "3"="WALKING_DOWNSTAIRS","4"="SITTING","5"="STANDING","6"="LAYING"))
final_labelled = final
final_labelled$labels <- final_labels

new_labels = revalue(as.factor(new$labels), c("1"="WALKING", "2"="WALKING_UPSTAIRS", "3"="WALKING_DOWNSTAIRS","4"="SITTING","5"="STANDING","6"="LAYING"))
new_labelled = new
new_labelled$labels = new_labels

# write out the files
write.table(final_labelled, file="final_output.txt", sep="\t", row.names=FALSE)
write.table(new_labelled, file="step5_output.txt", sep="\t", row.names=FALSE)