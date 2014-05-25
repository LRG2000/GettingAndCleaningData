run_analysis <- function(){

      ## read in the data that applies to everything
      testd <- "UCI_Har_Dataset/test/"
      traind <- "UCI_Har_Dataset/train/"
      activity <- read.table("UCI_Har_dataset/activity_labels.txt", sep = "", stringsAsFactors = FALSE)
      features <- read.table("UCI_Har_dataset/features.txt", sep="", stringsAsFactors = FALSE)
      tempnames <- features[[2]]

      ## make the variable names "human-readable"

      ## I think there is a typo in the features file and Body was not meant to be repeated in any feature name
      tempnames <- gsub("fBodyBody", replacement="fBody", tempnames)
      
      
      tempnames <- gsub("tBodyAcc-", replacement = "time.body.acceleration.", tempnames)            
      tempnames <- gsub("tBodyGyro-", replacement = "time.body.gyroscope.", tempnames)            
      tempnames <- gsub("tGravityAcc-", replacement = "time.gravitational.acceleration.", tempnames)
      tempnames <- gsub("tBodyAccJerk-", replacement = "time.body.linear.acceleration.", tempnames)            
      tempnames <- gsub("tBodyGyroJerk-", replacement = "time.body.angular.velocity.", tempnames)  

      tempnames <- gsub("tBodyAccMag-", replacement = "time.body.acceleration.magnitude.", tempnames)            
      tempnames <- gsub("tGravityAccMag-", replacement = "time.gravity.acceleration.magnitude.", tempnames)
      tempnames <- gsub("tBodyAccJerkMag-", replacement = "time.body.linear.acceleration.magnitude.", tempnames)            
      tempnames <- gsub("tBodyGyroMag-", replacement = "time.body.gyroscope.magnitude.", tempnames)            
      tempnames <- gsub("tBodyGyroJerkMag-", replacement = "time.body.angular.velocity.magnitude.", tempnames)            
      
      tempnames <- gsub("fBodyAcc-", replacement = "frequency.body.acceleration.", tempnames)            
      tempnames <- gsub("fBodyGyro-", replacement = "frequency.body.gyroscope.", tempnames)            
      tempnames <- gsub("fGravityAcc-", replacement = "frequency.gravitational.acceleration.", tempnames)
      tempnames <- gsub("fBodyAccJerk-", replacement = "frequency.body.linear.acceleration.", tempnames)            
      tempnames <- gsub("fBodyGyroJerk-", replacement = "frequency.body.angular.velocity.", tempnames)  
            
      tempnames <- gsub("fBodyAccMag-", replacement = "frequency.body.acceleration.magnitude.", tempnames)            
      tempnames <- gsub("fGravityAccMag-", replacement = "frequency.gravity.acceleration.magnitude.", tempnames)
      tempnames <- gsub("fBodyAccJerkMag-", replacement = "frequency.body.linear.acceleration.magnitude.", tempnames)            
      tempnames <- gsub("fBodyGyroMag-", replacement = "frequency.body.gyroscope.magnitude.", tempnames)            
      tempnames <- gsub("fBodyGyroJerkMag-", replacement = "frequency.body.angular.velocity.magnitude.", tempnames)            
      
      tempnames <- gsub("\\()",replacement= "", tempnames)
      tempnames <- gsub("-X", ".x", tempnames)
      tempnames <- gsub("-Y", ".y", tempnames)
      tempnames <- gsub("-Z", ".z", tempnames)
      tempnames <- gsub("x,", replacement ="x.", tempnames)
      tempnames <- gsub("y,", replacement ="y.", tempnames)
      tempnames <- gsub("z,", replacement ="z.", tempnames)
      tempnames <- gsub(",", replacement =".to.", tempnames)
      
      tempnames <- gsub(".mad", ".median.absolute.deviation", tempnames)
      tempnames <- gsub(".iqr", ".interquartile.range", tempnames)
      tempnames <- gsub("bandsEnergy-", "energy.in.frequency.interval.", tempnames)
      tempnames <- gsub("meanFreq", "frequency.weighted.average", tempnames)
      tempnames <- gsub("arCoeff", "coefficients", tempnames)
      tempnames <- gsub(".sma", ".signal.magnitude.area", tempnames)
      tempnames <- gsub("maxInds", "index.of.max.frequency", tempnames)
      
      tempnames <- gsub("angle\\(tBodyAccJerkMean\\).to.gravityMean\\)", 
                        replacement = "angle\\(tBodyAccJerkMean.to.gravityMean\\)", tempnames)    
      
      ## now include the identifiers for each subject and activity:
      nms <- c("subject.id", "subject.type", "activity", tempnames)
      
      ## Now get started.
      ## Training sample:
      ## first make a column with readable activity names
      trainy <- read.table(paste(traind,"y_train.txt", sep=""), stringsAsFactors = FALSE)
      train_acts <- character(length(trainy[[1]]))
      for (i in 1:6){ 
            inds <- which(trainy[[1]] == i)
            train_acts[inds] <- activity[[2]][i]
      }
      subjectType <- rep("train", length(trainy[[1]]))
      
      trainx <- read.table(paste(traind,"X_train.txt", sep=""))   ## now read in the actual measurements in training set
      subs <- read.table(paste(traind,"subject_train.txt", sep=""))  ## read in the subject IDs for the training set
      bigTrain <- cbind(subs, subjectType, train_acts, trainx)  ## combine subject ID, subjectType (train), activity, 
      ## and measurements
      names(bigTrain) <- nms   ## rename the columns

      ## now do it again with the test data:
      testy <- read.table(paste(testd,"y_test.txt", sep=""), stringsAsFactors = FALSE)
      test_acts <- character(length(testy[[1]]))
      for (i in 1:6){ 
            inds <- which(testy[[1]] == i)
            test_acts[inds] <- activity[[2]][i]
      }
      subjectType <- rep("test", length(testy[[1]])) 
      testx <- read.table(paste(testd,"X_test.txt", sep=""), stringsAsFactors=FALSE)
      subs <- read.table(paste(testd,"subject_test.txt", sep=""), stringsAsFactors = FALSE)
      bigTest <- cbind(subs, subjectType, test_acts, testx)
      names(bigTest) <- nms

      ## combine test and training sets
      wholeSet <- rbind(bigTrain, bigTest)
      
      library(plyr)
      wholeSet <- arrange(wholeSet, wholeSet$subject.id)  ## rearrange in order of subject ID

      ## select only the columns that give means or standard deviations
      inds <- which(grepl("-mean", nms) | grepl("-std", nms))
      part1set <- wholeSet[,c(1,2, 3, inds)]
      write.table(part1set, file="gettingAndCleaningPart1.txt", col.names=TRUE)
      write.table(wholeSet, file="gettingAndCleaningPart1_wholeSet.txt", col.names=TRUE)
      
      ## Part 2 - tidy data set with just averages of each variable
            
      s <- split(wholeSet, wholeSet$subject.id)
      meanlist <- NULL
      nrows <- 0
      
      for (n in 1:length(names(s))) {
            tmp1 <- s[[n]]
            tmp <- split(tmp1, tmp1$activity)
            subj <- unique(s[[n]]$subject.id)
            type <- as.character(unique(s[[n]]$subject.type))
            for (m in unique(s[[n]]$activity)) {
                  newtmp <- tmp[[m]]
                  colmeans <- colMeans(newtmp[,4:564], na.rm=TRUE)
                  thisrow <- c(subj, type, m, colmeans)
                  meanlist <- rbind(meanlist,thisrow)
                  nrows <- nrows + 1
            }
      }
      row.names(meanlist) <- seq(1:nrows)
      meanlist <- data.frame(meanlist)
      names(meanlist) <- nms
      write.table(meanlist, file="gettingAndCleaningProject_tidyData.txt", col.names=TRUE)
      print(meanlist)
}