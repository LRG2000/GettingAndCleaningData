README
========================================================

Getting and Cleaning Data Course Project - run_analysis.R and tidy data sets
------------------------------------------------------------
** A note to the reader: *In scientific papers it is customary to use the personal pronoun "we", even if there is only one author. Therefore, I have used "we" even though there is only one author for this work.* 


### Explanation of the data

The original data used to produce the files discussed in this README can be found at 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones using the "Data Folder" link. The information pertaining to how the data were measured and what each of the original variables means is in the "README.txt", "features_info.txt", and "features_info.txt" files.

To briefly summarize, an experiment involving 30 study participants was carried out using Samsung Galaxy S II Smartphones as triaxil accelerometers and gyroscopes. Measurements were made of 561 variables during 6 different activies (walking, standing, laying, walking upstairs, walking downstairs, and sitting) for each participant. The participants were assigned to one of two groups: test and training. A Fourier analysis was perfomred on the some of the raw data parameters. See the study's "README.txt" and features_info.txt" for more information.

In the final tidy data set lists, there is an entry for each activity for each of the 30 participants, whether the subject was in the "train" or "test" group, and the average values of each of the 561 variables. 

A word about the origin of the variable names:
"subject.id" is the number of the subject given in the original data, ranging from 1 to 30.
"subject.type" is the group the subject was in, either "test" or "train".
"activity" is the activity associated with the variable measurements (walking, walking upstairs, walking downstairs, laying, standing, sitting).

* "body" refers to the accelerometer data and "gyro" usually refers to the gyroscope data. However, "BodyGyro" in the origial data set referred to angular velocity, so we have renamed those variables with the more descriptive title, "angular.velocity".
* The triaxial directions of measurements are labeled in our data by .x, .y, or .z (original names: -X, -Y, -Z).
Any variable name that began with a "t" was renamed to begin with "time", while those beginning with "f" were renamed to begin with "frequency". 
* Variables with "magnitude" in their label are the scalar magnitude of the x, y, and z components of that variable.
* Variables with the text "coefficient" are the Autoregression coefficients with Burg order equal to 4.
* Variables with "index.of.max.frequency" were originally labeled "maxInds", and are the "inded of the frequency component with largest magnitude" in the Fourier analysis.

* The variable names in the form of  "angle.var1.to.var2" should be read as "the angle between var1 and var2". In this case, var1 and var2 are physical vectors. 
* We believe there was a typographical error in the name "angle(tBodyAccJerkMean),gravityMean)" so we removed the middle ")".
* We believe there was a typographical error in the names in which "Body" was repeated, so we reduced the instance of "Body" to one in those names.
* When abbreviations in the original column name involved more than one word we expanded the column name to include the full name of the variable.
* We chose not to change "std" because it is a very common abbrieviation for "standard deviation", which is what it means in this context as well. Similarly, "max" and "min" stand for "maximum" and "minimum", respectively.

* ...energy.in.frequency.interval.value1.to.value2: value1 and value2 are the minimum and maximum of that frequency band in the Fourier analysis performed on the raw data.



The Merging
-------------------------------------------
The UCI_HAR_Dataset.zip file contains the following files/directories:
activity_labels.txt
features_info.txt
features.txt
README.txt
test/
train/

train/
InertialSignals/
subject_train.txt
X_train.txt
y_train.txt

test/
InertialSignals/
subject_test.txt
X_test.txt
y_test.txt

InertialSignals/ contains files with the individual raw data and Fourier transformed data.

Each of the 3 .txt files in the train/ and test/ directories contain 7352 lines. X_train.txt contains the measurements for many time intervals of the 561 variables, measured a different number of times for each study participant. subject_train.txt contains one column, and each row is the number of the study participant corresponding to that row in X_train.txt. Similarly, each row in y_train.txt contains only the number of the activity being done while the motion measurements were taken. 

activity_labels.txt has one column for the name of the activity, and one column for the number used to denote that activity in y_train.txt and y_test.txt.

feautres.txt contains the name of the 561 variables measured. These names correspond to the columns of X_train.txt and X_test.txt.

After reading in each of the three training files as tables, we created a character vector with names corresponding to the numeric values of each activity listed in y_train.txt.

```r
traind <- "UCI_Har_Dataset/train/"
activity <- read.table("UCI_Har_dataset/activity_labels.txt", sep = "", stringsAsFactors = FALSE)
trainy <- read.table(paste(traind, "y_train.txt", sep = ""), stringsAsFactors = FALSE)
train_acts <- character(length(trainy[[1]]))
for (i in 1:6) {
    inds <- which(trainy[[1]] == i)
    train_acts[inds] <- activity[[2]][i]
}
```


We also created a character vector for the number of lines in the *_train.txt files, but with the word "train" repeated once for each line. We then combined these variables using cbind and renamed the columns with more descriptive titles (discussed above). We repeated this procedure for the *_test.txt files, then used rbind to combine the dataframes and write the result to a file ("gettingAndCleaningPart1_wholeSet.txt").

The assignment said to subset out only the mean and std values, so we added a step that will extract any column with a name containing "mean" or "std" write it to a second file ("gettingAndCleaningPart1.txt"). It didn't really seem like there was a place to submit either of these two file on the project page, so they are in the same repo as this README file.

Part 2 - Tidy Data
--------------------------
The next part of the assignment was to average each of the columns for each activity by each study participant, resulting in 180 line of 564 columns each (6 activities by each of 30 participants). We split the whole data set by study participant, then split the result by activity. We then used colMeans to find the average of the measurement columns and created a character vector for each row, binding the subject id, subject type, activity, and the averaged measurements. We used rbind as we looped through the participants and activities, converted the matrix to a dataframe, then renamed all of the columns using the names for the whole data set. We wrote this data set to a file called "gettingAndCleaningProject_tidyData.txt".






