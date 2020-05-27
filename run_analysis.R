#add necessary package
library(reshape2)

#get working directory in separate variable
workdir<-getwd()
#download and unzip raw data
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, paste0(workdir, "/data.zip"))
unzip("data.zip")

#load activity labels and feature names
labels<-read.table(file.path(workdir, "UCI HAR Dataset/activity_labels.txt"), sep="", header = FALSE)
features<-read.table(file.path(workdir, "UCI HAR Dataset/features.txt"), sep="", header = FALSE)[2]

#load and merge main data sets
testingSet<-read.table(file.path(workdir, "UCI HAR Dataset/test/X_test.txt"), sep="", header = FALSE)
trainingSet<-read.table(file.path(workdir, "UCI HAR Dataset/train/X_train.txt"), sep="", header = FALSE)
mergedSet<-rbind(testingSet, trainingSet)

#load and merge move data
testingMove<-read.table(file.path(workdir, "UCI HAR Dataset/test/Y_test.txt"), sep="", header = FALSE)
trainingMove<-read.table(file.path(workdir, "UCI HAR Dataset/train/Y_train.txt"), sep="", header = FALSE)
mergedMove<-rbind(testingMove, trainingMove)

#load and merge PersonId
testingId<-read.table(file.path(workdir, "UCI HAR Dataset/test/subject_test.txt"), sep="", header = FALSE)
trainingId<-read.table(file.path(workdir, "UCI HAR Dataset/train/subject_train.txt"), sep="", header = FALSE)
mergedId<-rbind(testingId, trainingId)

#set names to the columns of the final data set and select only mean and std measurements
names(mergedSet)<-features[, 1]
mergedSet<-mergedSet[grepl("std|mean", names(mergedSet))]
#merge separate tables into one table and set appropriate names
mergedMove<-merge(mergedMove, labels, by.x="V1", by.y = "V1")[2]
mergedSet<-cbind(mergedId, mergedMove, mergedSet)
names(mergedSet)[1:2]<-c("PersonId", "Activity")
#get table with average value for each person and activity
mergedSet <- reshape2::melt(data = mergedSet, id = c("PersonId", "Activity"))
mergedSet <- reshape2::dcast(data = mergedSet, PersonId + Activity ~ variable, fun.aggregate = mean)
#save data set into text file
write.table(mergedSet, file="tidyset.txt", row.name=FALSE)

