#Strips all white space

PivotList <- function(list){
  
  
  list <- gsub("\\s+", "", list)

  vect <- list %>% strsplit(",")

  return(vect)
  
}

#Strips just before and after comma

PivotListba <- function(list){
  
  
  list <- gsub("\\s*,\\s*", ",", list)
  
  vect <- list %>% strsplit(",")
  
  return(vect)
  
}

#Strips no white space

PivotListNone <- function(list){
  
  vect <- list %>% strsplit(",")
  
  return(vect)
  
}