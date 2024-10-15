insertDbTable <- function(connection, tableName, insertSet) {
  curColNames <- colnames(insertSet)
  colNames <- paste0(colnames(insertSet), collapse = ", ")
  
  for (x in c(1:nrow(insertSet))) {
    row = insertSet[x,]
    
    valuesPrepared <- sapply(curColNames, function(y) {
      origClass <- class(row[1,y])
      value <- as.character(row[1,y])
      
      if (origClass == "character" ||
          origClass == "Date") {
        value <- paste0("'", as.character(value), "'")
      }
      if (is.na(value)) {
          value <- "null"
      }
      
      value
    })
    
    valueString <- paste0(valuesPrepared, collapse = ", ")
    valueString <- gsub("NA, ", "NULL, ", valueString)
    # valueString <- gsub("\'NA\', ", "NULL, ", valueString)
    # valueString <- gsub("\'???\', ", "NULL, ", valueString)
    
    query <- paste0("INSERT INTO ", tableName, "(", colNames, ") VALUES (", valueString, ")")
    # print(query)

    tryCatch({
            sink = dbSendStatement(connection, query)
        },
        warning = function(e) { 
            message("WARNING")
            message(query)
            message(e)
        },
        error = function(e) { 
            message("ERROR")
            message(query)
            message(e)
        }
    )
  }
}