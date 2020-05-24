# Data Science Specilization 
# 3. Getting and Cleaning Data Project  Coursera
# Author: Arturo Vera
# 2020/05/24

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
