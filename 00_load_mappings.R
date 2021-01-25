# Inlezen concept_ids die zijn toegekend aan variabelen en values
mappings <- read.xlsx("../../Mapping/Mapping_DMS_to_OMOP_20201021.xlsx", 1)

# Add column containing the mapping value, with the suffix _concept
convertColumnCategory <- function(columnName) {
  newColumnConceptId <- paste0(columnName, "_concept")
  mappingSubset <- mappings[mappings$variable==columnName,]
  
  newColumnConcept <- sapply(c(1:nrow(dataSet)), function(x) {
    row <- dataSet[x,]
    origValue <- unlist(row[columnName][1])
    newValue <- mappingSubset$variable_concept_id[mappingSubset$source_value==origValue]
    newValue
  })
  
  dataSet[,newColumnConceptId] <- newColumnConcept
  dataSet
}