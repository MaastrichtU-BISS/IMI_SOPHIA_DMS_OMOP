
# Load packages -----------------------------------------------------------
library(readxl)
library(haven)
library(data.table)



# Define paths ------------------------------------------------------------
path_conversion_table <- "./data/Maastricht_Study_Mapping_20211105.xlsx"
path_spss <- "./data/AV405v3_Johan_van_Soest_20211022.sav"
path_spss_drug <- "./data/AV405_Medication_Johan_van_Soest_20211102.sav"


# Read data ---------------------------------------------------------------
conversion_table <- read_excel(path_conversion_table)

# drop records that will not be mapped to tables
conversion_table <- conversion_table[which(conversion_table$Mapped_Table != "N.A."), ]

spss <- read_sav(path_spss)

# Convert columns into rows (warning: all values are set to character type)
mySet <- data.frame(melt(data.table(spss),
                         id.vars = c("Deelnemer_nr", "VISIT1_DATE"),
                         na.rm = TRUE))

# merge data file with conversion table
# convert both tables to lower case before merge
mySet$variable <- tolower(mySet$variable)
conversion_table$sourceCode <- tolower(conversion_table$sourceCode)

mySet <- merge(mySet, conversion_table, by.x = "variable", by.y = "sourceCode", all.x = TRUE, all.y = FALSE)



# keep records with missing sourceValue or where sourceValue == value
mySet <- subset(mySet, (is.na(sourceValue) | sourceValue == value))



# sort mySet on Deelnemer_nr, variable and Mapped_Column
mySet <- mySet[
  with(mySet, order(Deelnemer_nr, variable, Mapped_Column)),
]



# Determinie mapped variables per table -----------------------------------
# get table names
table_names <- unique(conversion_table$Mapped_Table)

# get variable names per table
for (i in 1:length(table_names)) {
  temp_table_name <- paste("vars", table_names[i], sep = "_")
  assign(temp_table_name, unlist(unique(subset(conversion_table, Mapped_Table == table_names[i])["sourceCode"])))
}


# map subject data to OMOP tables

# create empty data.frames to fill
table_measurement <- data.frame(matrix(ncol = 7, nrow = 0))
colnames(table_measurement) <- c("person_id", "measurement_concept_id", "measurement_date", "measurement_type_concept_id", "value_as_number", "unit_concept_id", "measurement")

table_condition <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(table_condition) <- c("person_id", "condition_concept_id", "condition_start_date", "condition_type_concept_id", "condition")

# table_person <- data.frame(matrix(ncol = 5, nrow = 0))
# colnames(table_person) <- c("person_id", "gender_concept_id", "year_of_birth", "race_concept_id", "ethnicity_concept_id")

table_observation <- data.frame(matrix(ncol = 8, nrow = 0))
colnames(table_observation) <- c("person_id", "observation_concept_id", "observation_date", "measurement_type_concept_id", "value_as_number", "value_as_concept_id", "observation", "value")



# fill empty data.frames
for (i in 1:nrow(mySet)) {
  
  # Measurement table
  if (mySet[i, "variable"] %in% vars_Measurement) {
    
    temp_measurement <- data.frame(person_id = mySet[i, "Deelnemer_nr"],
                                   measurement_concept_id = mySet[i, "targetConceptid"],
                                   measurement_date = mySet[i, "VISIT1_DATE"],
                                   measurement_type_concept_id = 32809,
                                   value_as_number = mySet[i, "value"],
                                   unit_concept_id = mySet[i, "valueConceptid"],
                                   measurement = mySet[i, "variable"])
    
    table_measurement <- rbind(table_measurement, temp_measurement)
  }
  
  
  # Condition occurance table
  if (mySet[i, "variable"] %in% vars_Condition_occurance) {
    
    temp_condition <- data.frame(person_id = mySet[i, "Deelnemer_nr"],
                                 condition_concept_id = mySet[i, "targetConceptid"],
                                 condition_start_date = mySet[i, "VISIT1_DATE"],
                                 condition_type_concept_id = 32809,
                                 condition = mySet[i, "variable"])
    
    table_condition <- rbind(table_condition, temp_condition)
  }
  
  
  # Person table (gaat niet goed)
  # if (mySet[i, "variable"] %in% vars_Person) {
  #   
  #   temp_person <- data.frame(person_id = mySet[i, "Deelnemer_nr"],
  #                             gender_concept_id = mySet[i, "sex"],
  #                             year_of_birth = mySet[i, "gebyear"],
  #                             race_concept_id = 0,
  #                             ethnicity_concept_id = 38003564)
  #   
  #   table_person <- rbind(table_person, temp_person)
  #   
  # }
  
  
  # Observation table
  if (mySet[i, "variable"] != "gebyear") {
  if (mySet[i, "Mapped_Table"] == "Observation") {

    temp_observation <- data.frame(person_id = NA,
                                   observation_concept_id = NA,
                                   observation_date = NA,
                                   measurement_type_concept_id = 32809,
                                   value_as_number = NA,
                                   value_as_concept_id = NA,
                                   observation = NA,
                                   value = NA)

    if (mySet[i, "Mapped_Column"] == "observation_concept_id") {

      temp_observation$person_id <- mySet[i, "Deelnemer_nr"]
      temp_observation$observation_concept_id <- mySet[i, "targetConceptid"]
      temp_observation$observation_date <- mySet[i, "VISIT1_DATE"]
      temp_observation$observation <- mySet[i, "variable"]
      temp_observation$value_as_number <- mySet[i, "value"]
      
      if (mySet[i+1, "Mapped_Column"] == "value_as_concept_id" & mySet[i, "Deelnemer_nr"] == mySet[i+1, "Deelnemer_nr"]) {
        
        temp_observation$value_as_concept_id <- mySet[i+1, "targetConceptid"]
        temp_observation$value <- mySet[i+1, "sourceValueLabel"]
        
      } else if (mySet[i+1, "Mapped_Column"] != "value_as_concept_id" | mySet[i, "Deelnemer_nr"] != mySet[i+1, "Deelnemer_nr"]) {
        
        temp_observation$value <- mySet[i, "sourceValueLabel"]
        
      }

    
    table_observation <- rbind(table_observation, temp_observation)

  }}
  }
  }






# Drug exposure --------------------------------------------------------------

# Read data ---------------------------------------------------------------
conversion_table_med <- read_excel(path_conversion_table, sheet = "Drug_mapping")
spss_drug <- read_sav(path_spss_drug)


# merge data file with conversion table
drugSet <- merge(spss_drug, conversion_table_med, by = "CONCEPT_CODE", all.x = TRUE, all.y = FALSE)


# sort drugSet on Deelnemer_nr, variable and Mapped_Column
drugSet <- drugSet[
  with(drugSet, order(Deelnemer_nr, CONCEPT_ID_1)),
]

# map subject data to OMOP tables

# create empty data.frames to fill
table_drug_exposure <- data.frame(matrix(ncol = 6, nrow = 0))
colnames(table_drug_exposure) <- c("person_id", "drug_concept_id", "drug_exposure_start_date", "drug_type_concept_id", "drug_source_value", "drug_source_concept_id")

# fill empty data.frames
for (i in 1:nrow(drugSet)) {
  
  temp_drug_exposure <- data.frame(person_id = NA,
                                drug_concept_id = NA,
                                drug_exposure_start_date = NA,
                                drug_type_concept_id = 32809,
                                drug_source_value = NA,
                                drug_source_concept_id = NA)
  
  temp_drug_exposure$person_id <- drugSet[i, "Deelnemer_nr"]
  temp_drug_exposure$drug_concept_id <- drugSet[i, "CONCEPT_ID_1"]
  temp_drug_exposure$drug_exposure_start_date <- 0
  temp_drug_exposure$drug_type_concept_id <- 32865
  temp_drug_exposure$drug_source_value <- drugSet[i, "CONCEPT_CODE"]
  temp_drug_exposure$drug_source_concept_id <- drugSet[i, "CONCEPT_ID"]

  table_drug_exposure <- rbind(table_drug_exposure, temp_drug_exposure)
}

