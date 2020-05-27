# Getting-and-Cleaning-Data-Course-Project
# Explanations
* This script will work in any working directory even in those where data set is not present because it will download it at the beginning. 
```R 
   #download and unzip raw data
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, paste0(workdir, "/data.zip"))
unzip("data.zip")
```
All files containing necessary data extracted into separate tables using __read.table()__ function. In all file reading __header__ parameter was set to FALSE in order read first raw as observation, not column names. 
From test and train folders files with similar data was read and binded one of after another. 
```R
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
```   
Extract features names and assign them to the column names. Also select only necessary columns containing standard deviation or mean values
```R
#load activity labels and feature names
labels<-read.table(file.path(workdir, "UCI HAR Dataset/activity_labels.txt"), sep="", header = FALSE)
features<-read.table(file.path(workdir, "UCI HAR Dataset/features.txt"), sep="", header = FALSE)[2]
#set names to the columns of the final data set and select only mean and std measurements
names(mergedSet)<-features[, 1]
mergedSet<-mergedSet[grepl("std|mean", names(mergedSet))]
```
Assign descriptive values for activity column
```R
mergedMove<-merge(mergedMove, labels, by.x="V1", by.y = "V1")[2]
mergedSet<-cbind(mergedId, mergedMove, mergedSet)
```
Rearrange data set so it will be tidy with columns personId, Activity and other columns for means of each feature
```R
#get table with average value for each person and activity
mergedSet <- reshape2::melt(data = mergedSet, id = c("PersonId", "Activity"))
mergedSet <- reshape2::dcast(data = mergedSet, PersonId + Activity ~ variable, fun.aggregate = mean)
```
Finally save data set on separate text file
```R
write.table(mergedSet, file="tidyset.txt", row.name=FALSE)
```
