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

# 1. Merges the training and the test sets to create one data set.

data_train <- cbind(data_train_x, data_train_y, data_train_subject)
data_test <- cbind(data_test_x, data_test_y, data_test_subject)
data <- rbind(data_train, data_test)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

data_features <- read.table("UCI HAR Dataset/features.txt", col.names = c("col_id", "col_desc"))

colids <- grep("mean|std", data_features$col_desc)
colnames <- as.character(data_features[colids, ]$col_desc)
colids <- paste(rep("V", length(colids)), colids, sep = "")
colids <- c(colids, "activity_id", "subject_id")

data_meanstd <- data[, colids]
names(data_meanstd) <- c(colnames, "activity_id", "subject_id")

# 3. Uses descriptive activity names to name the activities in the data set

data_activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("activity_id", "activity_text"))
data_meanstdact <- merge(data_meanstd, data_activitylabels, by.x = "activity_id", by.y = "activity_id")

# 4. Appropriately labels the data set with descriptive variable names. 

# this is already done
# write.csv(data_meanstdact, "tidy1.csv")

# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(reshape2)
data2 <- melt(data_meanstdact, id = c("subject_id", "activity_id", "activity_text"), measure.vars = colnames)
data2_dcasted <- dcast(data2, subject_id + activity_id + activity_text ~ variable, mean)
write.csv(data2_dcasted, "tidy.csv")

