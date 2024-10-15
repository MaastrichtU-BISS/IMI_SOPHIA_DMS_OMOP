message("start with measurements")

#Read dataset
dataSet <- readData()

#Convert rows into columns
mySet <- data.frame(data.table::melt(data.table(dataSet),
                            id.vars = c("RandomID", "VISIT1_DATE"),
                            measure.vars = c("bmi", "height", "weight", "N_GTS_WHO")))
#Rename column names
colnames(mySet) <- c("person_id", "measurement_date", "measurement_concept_id", "value_as_number")

#Add necessary columns
mySet$measurement_id <- c(1:nrow(mySet))
mySet$measurement_type_concept_id <- 0

#Convert factor to character
mySet$measurement_concept_id <- as.character(mySet$measurement_concept_id)

#Convert height values
mySet$measurement_concept_id[mySet$measurement_concept_id=="height"] <- "3015514"

#Convert weight values
mySet$measurement_concept_id[mySet$measurement_concept_id=="weight"] <- "3013762"

#Convert to numeric when needed
mySet$measurement_concept_id <- as.numeric(mySet$measurement_concept_id)

#Remove NA values where type is unknown
mySet <- mySet[!is.na(mySet$measurement_concept_id),]

#Finally, insert the data.frame table into the database
insertDbTable(connection, "measurement", mySet)

#Clean variables not needed
rm(list=c("mySet", "dataSet"))
