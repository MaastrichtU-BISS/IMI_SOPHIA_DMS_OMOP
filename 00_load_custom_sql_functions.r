insertDbTable <- function(connection, tableName, insertSet) {
  curColNames <- colnames(insertSet)
  colNames <- paste0(colnames(insertSet), collapse = ", ")
  
  lapply(c(1:nrow(insertSet)), function(x) {
    row = insertSet[x,]
    
    valuesPrepared <- sapply(curColNames, function(y) {
      origClass <- class(row[1,y])
      value <- as.character(row[1,y])
      
      if (origClass == "character" ||
          origClass == "Date") {
        value <- paste0("'", as.character(value), "'")
      }
      
      value
    })
    
    valueString <- paste0(valuesPrepared, collapse = ", ")
    valueString <- gsub("NA, ", "NULL, ", valueString)
    
    query <- paste0("INSERT INTO ", tableName, "(", colNames, ") VALUES (", valueString, ")")
    
    dbSendStatement(connection, query)
  })
}