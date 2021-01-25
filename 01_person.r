# Fill person table

message("Start to fill person table")

#Read dataset
dataSet <- readData()

#Read standard codes from mapping files and apply to the given column
dataSet <- convertColumnCategory("SEX")

# Make a data.frame object which is comparable to the OMOP person table
subSet <- dataSet[,c("RandomID", "SEX_concept", "GebYEAR", "SEX")]
subSet$month_of_birth <- 6
subSet$day_of_birth <- 1
subSet$race_concept_id <- 8527
subSet$ethnicity_concept_id <- 38003564

# Rename columns to match database column names
myNames <- colnames(subSet)
myNames[myNames=="RandomID"] <- "person_id"
myNames[myNames=="SEX_concept"] <- "gender_concept_id"
myNames[myNames=="GebYEAR"] <- "year_of_birth"
myNames[myNames=="SEX"] <- "gender_source_value"
colnames(subSet) <- myNames

# convert character database column to actual characters
subSet$gender_source_value <- as.character(subSet$gender_source_value)

# Insert the dataframe into the database
insertDbTable(connection, "person", subSet)