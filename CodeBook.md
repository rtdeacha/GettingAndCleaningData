# CodeBook
This CodeBook describes the variables, the data, the transformations and the work performed to clean up the data.

## Data sources
The Dataset was obtained from the [UCI Machine Learning Repository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) site.
Here is a [direct link](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) to the raw data.

## About the script
The `run_analysis.R` script performs the following actions:
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

## Assumptions
I made the following assumptions:
1. The script is on the `UCI HAR Dataset` folder.
2. The data from `subject_test.txt` and the `y_test.txt` are in the same order as the `x_test.txt` data.
3. The data from `subject_train.txt` and the `y_train.txt` are in the same order as the `x_train.txt` data.

## Getting and Cleaning the data
#### Since the script is using the data.table and reshape2 packages, first it makes sure those are installed and loaded. 
```
if (!require("data.table")) {install.packages("data.table")}
if (!require("reshape2")) {install.packages("reshape2")}
require("data.table")
require("reshape2")
```
#### Then the script reads each file to data.frames
```
features <- read.table("features.txt")[,2]
activities <- read.table("activity_labels.txt")[,2]
xtest <- read.table("./test/X_test.txt")
ytest <- read.table("./test/Y_test.txt")
stest <- read.table("./test/subject_test.txt")
xtrain <- read.table("./train/X_train.txt")
ytrain <- read.table("./train/Y_train.txt")
strain <- read.table("./train/subject_train.txt")
```
#### After that, we need to use only the Mean and Std features, using Regular Expressions and grepl, I create a logical to keep track of only those variables.
```
exclude.features <- grepl("[Mm]ean[(][)]|[Ss]td[(][)]", features)
```
#### Then I merge the `xtest` and `xtrain` data frames (The new data frame `x` has 10299 observations and 561 variables), assign the `colnames` based on `features`. Then I subset the `x` data frame to only those Mean and Std features (The new file has only 66 variables).
```
x <- rbind(xtest,xtrain)
colnames(x)<- features
x <- x[,exclude.features == T]
```
#### Then the activity data is merged from the test and train data frames. And named based on the activity factors.
```
y <- rbind(ytest,ytrain)
y[,2]<- activities[y[,1]]
```
#### Then the subject data is also merged.
```
s <- rbind(stest,strain)
```
#### Then the subject and the activity factors are merged, and the result is merged to the measurements.
```
sa <- cbind(s,y[,2])
colnames(sa) <- c("subject", "activity")
dfrm <- cbind(sa, x)
dfrm[,1] <- as.factor(dfrm[,1])
```
#### Then the trasnsformation takes place, using `melt` and `dcast`.
```
## Group by subject and activity
groups.id <- c("subject", "activity")
## Identify the columns of data to be summarized (not subject nor activity)
data.columns <- setdiff(colnames(dfrm), groups.id)
## create a data.frame with melt so the variables are included by rows
melt.dfrm <- melt(dfrm, id = groups.id, measure.vars = data.columns)
## Use dcast to group the melt.dfrm into the tidy data.frame
tidy <- dcast(melt.dfrm, subject + activity ~ data.columns, mean)
```
#### Then tidy data set is saved as a .txt file.
```
write.table(tidy, "./tidy.txt")
```
#### Lastly, delete all the variables to remove the clutter from memory.
```
rm("dfrm", "melt.dfrm", "s", "sa", "stest", "strain","x", "xtest" , "xtrain", "y", "tidy",
    "ytest", "ytrain", "activities", "data.columns", "exclude.features", "features", "groups.id")
```

