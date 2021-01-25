## Inlezen van SPSS file
readData <- function() {
  dataset <- read.spss("../../../DMS_dataset_AV405/AV405v2_Johan_van_Soest_20200915.sav", 
                      to.data.frame = TRUE, 
                      use.value.labels = FALSE)
  
  # Herstellen van VISIT1_DATE naar date-format, is verloren gegaan bij inlezen met read.spss
  dataset$VISIT1_DATE <- as.Date(dataset$VISIT1_DATE/86400, origin = "1582-10-14")
  
  # teruggeven van dataset
  dataset
}