## This function is designed to convert the results of an alter roster network survey into an edgelist
## Survey results using an alter roster tend to produce a non-square, unimodal adjacency matrix
## Such a matrix cannot be read into igraph or statnet or easily converted to a square matrix
## This function takes that non-square adj_matrix and converts it to an edgelist
## The function receives a data frame containing the data and then returns to the resultant edgelist

## THIS DATA FRAME SHOULD NOT HAVE HEADERS; THE FIRST ROW AND COLUMN OF DATA SHOULD BE NODE NAMES

## this version does not support valued data


survey.mat.convert <- function(ns.df) {
  
  num.init <- nrow(ns.df)
  num.respond <- ncol(ns.df)
  write.row <- 1
  
  edge.list <- data.frame()

  for( init in 2:num.init ) {
    for( respond in 2:num.respond ) {
      if ( ns.df[init,respond] >= 1 ) {
        edge.list[write.row, 1] <- ns.df[init, 1]
        edge.list[write.row, 2] <- ns.df[1, respond]
        write.row <- write.row + 1
        }
      }
    }
  colnames(edge.list) <- c("from", "to")  
  return(edge.list)
}

survey.mat.convert.valued <- function(ns.df) {
  
  num.init <- nrow(ns.df)
  num.respond <- ncol(ns.df)
  write.row <- 1
  
  edge.list <- data.frame()
  
  for( init in 2:num.init ) {
    for( respond in 2:num.respond ) {
      if ( ns.df[init,respond] > 0 ) {
        edge.list[write.row, 1] <- ns.df[init, 1]
        edge.list[write.row, 2] <- ns.df[1, respond]
        edge.list[write.row, 3] <- as.numeric(ns.df[init, respond])
        write.row <- write.row + 1
      }
    }
  }
  colnames(edge.list) <- c("from", "to", "value")  
  return(edge.list)
}