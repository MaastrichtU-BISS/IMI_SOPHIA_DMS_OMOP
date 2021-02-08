# Script to truncate database

message("Starting to clear (truncate) database tables")

tableList <- c("person", "measurement")

status <- lapply(tableList, function(tableName) {
  query <- paste0("TRUNCATE TABLE ", tableName)
  message(query)
  dbSendQuery(connection, query)
})

rm(tableList)