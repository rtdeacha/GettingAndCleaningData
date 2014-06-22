
####  About the script:
    ## You should create one R script called run_analysis.R that does the following. 
    ## 1. Merges the training and the test sets to create one data set.
    ## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
    ## 3. Uses descriptive activity names to name the activities in the data set
    ## 4. Appropriately labels the data set with descriptive variable names. 
    ## 5. Creates a second, independent tidy data set with the average of each variable for each 
    ##    activity and each subject. 

#### About the data:
    ## The data for this project could be obtained here:
    ## https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
    ## Refer to this site where the data was obtained:
    ## http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

## This code assumes that the data was unzipped and the script is on the UCI HAR Dataset folder

## make sure the libraries are installed
if (!require("data.table")) {install.packages("data.table")}
if (!require("reshape2")) {install.packages("reshape2")}

require("data.table")
require("reshape2")

## Load tables

## The features data.frame includes the names of the variables
features <- read.table("features.txt")[,2]
## The activities data.frame includes de descriptions for each activity
activities <- read.table("activity_labels.txt")[,2]
## inside /test/
xtest <- read.table("./test/X_test.txt")
ytest <- read.table("./test/Y_test.txt")
stest <- read.table("./test/subject_test.txt")
## inside /train/
xtrain <- read.table("./train/X_train.txt")
ytrain <- read.table("./train/Y_train.txt")
strain <- read.table("./train/subject_train.txt")

## Create a logical vector for the features including mean or std
exclude.features <- grepl("[Mm]ean[(][)]|[Ss]td[(][)]", features)

## Join x_test.txt and x_train.txt data and assign the col names based
## on the features vector
x <- rbind(xtest,xtrain)
colnames(x)<- features
## Keep only the mean & std variables
x <- x[,exclude.features == T]

## Join the test and train activities 
y <- rbind(ytest,ytrain)

## Add names to the activities id
y[,2]<- activities[y[,1]]

## Join the test and train subjects
s <- rbind(stest,strain)

## Join the subjects with the activities
sa <- cbind(s,y[,2])
colnames(sa) <- c("subject", "activity")

##Join the the measurements
dfrm <- cbind(sa, x)
dfrm[,1] <- as.factor(dfrm[,1])

## Group by subject and activity
groups.id <- c("subject", "activity")

## Identify the columns of data to be summarized (not subject nor activity)
data.columns <- setdiff(colnames(dfrm), groups.id)

## create a data.frame with melt so the variables are included by rows
melt.dfrm <- melt(dfrm, id = groups.id, measure.vars = data.columns)

## Use dcast to group the melt.dfrm into the tidy data.frame
tidy <- dcast(melt.dfrm, subject + activity ~ data.columns, mean)

## Save the tidy file
write.table(tidy, "./tidy.txt")

## Remove all my variables

 rm("dfrm", "melt.dfrm", "s", "sa", "stest", "strain","x", "xtest" , "xtrain", "y", "tidy",
    "ytest", "ytrain", "activities", "data.columns", "exclude.features", "features", "groups.id")