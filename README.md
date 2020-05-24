# Getting-and-Cleaning-Data-Project
The goal is to prepare tidy data that can be used for later analysis.
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.

# Review criteriamenos 
  1.  The submitted data set is tidy.
  2.  The Github repo contains the required scripts.
  3.  GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all the variables and summaries calculated, along with units, and any other relevant information.
  4.  The README that explains the analysis files is clear and understandable.
  5.  The work submitted for this project is the work of the student who submitted it.

# Getting and Cleaning Data Course Project 
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

  1.  Merges the training and the test sets to create one data set.
  2.  Extracts only the measurements on the mean and standard deviation for each measurement. 
  3.  Uses descriptive activity names to name the activities in the data set
  4.  Appropriately labels the data set with descriptive variable names.
  5.  From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
  
# Working Directory Structure

  Script: run_analysis.R
  
  Tidy data: tidyData.txt
  
# Script

#### Data Science Specilization 
#### 3. Getting and Cleaning Data Project  Coursera
#### Author: Arturo Vera
#### 2020/05/24

library(data.table)
library(reshape2)

# 1. Merges the training and the test sets to create one data set.

# Get the Data
dir <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(dir, "data.zip"))
unzip(zipfile = "data.zip")

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set

# Load activity labels and features
alabels <- fread(file.path(dir, "UCI HAR Dataset/activity_labels.txt"), col.names = c("class", "activity"))
features <- fread(file.path(dir, "UCI HAR Dataset/features.txt"), col.names = c("index", "features"))
features2 <- grep("(mean|std)\\(\\)", features[, features])
measurements <- gsub('[()]', '', features[features2, features])

# Load train datasets
train <- fread(file.path(dir, "UCI HAR Dataset/train/X_train.txt"))[, features2, with = FALSE]
setnames(train, colnames(train), measurements)
traina <- fread(file.path(dir, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
trains <- fread(file.path(dir, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))
train <- cbind(trains, traina, train)

# Load test datasets
test <- fread(file.path(dir, "UCI HAR Dataset/test/X_test.txt"))[, features2, with = FALSE]
setnames(test, colnames(test), measurements)
testa <- fread(file.path(dir, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
tests <- fread(file.path(dir, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))
test <- cbind(tests, testa, test)

# merge datasets
data <- rbind(train, test)

# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of 
#    each variable for each activity and each subject.

# Convert classLabels to activities. 
data[["Activity"]] <- factor(data[, Activity], levels = alabels[["class"]], labels = alabels[["activity"]])
data[["SubjectNum"]] <- as.factor(data[, SubjectNum])
data <- melt(data, id = c("SubjectNum", "Activity"))
data <- dcast(data = data, SubjectNum + Activity ~ variable, fun.aggregate = mean)

# Extra: Please upload your data set as a txt file created with write.table() using row.name=FALSE

write.table(x = data, file = "tidyData.txt", row.name=FALSE)
