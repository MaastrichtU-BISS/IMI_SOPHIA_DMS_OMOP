insertDbTable <- function(connection, tableName, insertSet) {
  curColNames <- colnames(subSet)
  colNames <- paste0(colnames(subSet), collapse = ", ")
  
  lapply(c(1:nrow(insertSet)), function(x) {
    row = insertSet[x,]
    
    valuesPrepared <- sapply(curColNames, function(y) {
      origClass <- class(row[1,y])
      value <- as.character(row[1,y])
      
      if (origClass == "character") {
        value <- paste0("'", value, "'")
      }
      
      value
    })
    
    valueString <- paste0(valuesPrepared, collapse = ", ")
    
    query <- paste0("INSERT INTO ", tableName, "(", colNames, ") VALUES (", valueString, ")")
    
    dbSendStatement(connection, query)
  })
}