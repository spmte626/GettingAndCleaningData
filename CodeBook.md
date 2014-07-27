Getting and Cleaning Data - Peer Assessment
========================================================

This file describes the variables, the data, and the transformations that were performed in order to clean up the data

## Section 0 - Downloading, and reading data

The data is downloaded from the following link:  
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

It is then unzipped and loaded via a sequence of read.table commands


```r
#downloading data
url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfile = "dataset.zip"

download.file(url, destfile = destfile)
unzip(destfile)

# Reading data
data_train_x <- read.table("UCI HAR Dataset/train/X_train.txt")
data_train_y <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = c("activity_id"))
data_train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = c("subject_id"))

data_test_x <- read.table("UCI HAR Dataset/test/X_test.txt")
data_test_y <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = c("activity_id"))
data_test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = c("subject_id"))
```



## Section 1 - Merging the training and the test sets to create one data set

This is fairly straight forward and achived using 2 column bind commands and 1 row bind

```r
data_train <- cbind(data_train_x, data_train_y, data_train_subject)
data_test <- cbind(data_test_x, data_test_y, data_test_subject)
data <- rbind(data_train, data_test)
```
## Section 2 - Extracts only the measurements on the mean and standard deviation for each measurement

The features file is loaded and scanned for columns that contain the words "mean" or "std" in their name.
Once they are identified the index of these column names are used to select the relevant columns from the
merged data set.

Additionally, the Vxxx names for columns are replaced with the actual column names. This is required at a
later stage in the assignment.

```r
data_features <- read.table("UCI HAR Dataset/features.txt", col.names = c("col_id", "col_desc"))

colids <- grep("mean|std", data_features$col_desc)
colnames <- as.character(data_features[colids, ]$col_desc)
colids <- paste(rep("V", length(colids)), colids, sep = "")
colids <- c(colids, "activity_id", "subject_id")

data_meanstd <- data[, colids]
names(data_meanstd) <- c(colnames, "activity_id", "subject_id")
```

## Section 3 - Descriptive activity names in data set

This is done very easily by using the merge command. First we load the labels and then we
join our dataset with the activity labels by using the activity_ids. At this time
the activity ids columns are named the same in both data frames - "activity_id", but for
clarity the by.x and the by.y column specifies the column name anyway.

```r
data_activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("activity_id", "activity_text"))
data_meanstdact <- merge(data_meanstd, data_activitylabels, by.x = "activity_id", by.y = "activity_id")
```

## Section 4 - Appropriately labels the data set with descriptive variable names

Nothing required at this stage as the columns have already been renamed as part of **Section 2**.  
The variable data_meanstdact reflects this change.

## Section 5 - Create a tidy data set with the average of each variable for each activity and each subject

This is achieved by calling the melt function to transform the data from an horizontal to vertical description.  
Next, the mean values are calculated by calling the dcast function. The summary is written to **tidy.csv**.

```r
library(reshape2)
data2 <- melt(data_meanstdact, id = c("subject_id", "activity_id", "activity_text"), measure.vars = colnames)
data2_dcasted <- dcast(data2, subject_id + activity_id + activity_text ~ variable, mean)
write.csv(data2_dcasted, "tidy.csv")
```

