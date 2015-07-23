##Get Data

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data")
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files

###1. Merges the training and the test sets to create one data set.

DataActivity_Test  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
DataActivity_Train <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

DataSubject_Train <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
DataSubject_Test  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

DataFeatures_Test  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
DataFeatures_Train <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

DataSubject <- rbind(DataSubject_Train, DataSubject_Test)
DataActivity<- rbind(DataActivity_Train, DataActivity_Test)
DataFeatures<- rbind(DataFeatures_Train, DataFeatures_Test)

names(DataSubject)<-c("subject")
names(DataActivity)<- c("activity")
DataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(DataFeatures)<- DataFeaturesNames$V2

DataCombine <- cbind(DataSubject, DataActivity)
Data <- cbind(DataFeatures, DataCombine)


###2. Extracts only the measurements on the mean and standard deviation for each measurement. 

Sub_DataFeaturesNames<-DataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", DataFeaturesNames$V2)]
SelectedNames<-c(as.character(Sub_DataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=SelectedNames)

###3. Uses descriptive activity names to name the activities in the data set
ActivityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
head(Data$activity,30)


###4. Appropriately labels the data set with descriptive variable names. 
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

###5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)


