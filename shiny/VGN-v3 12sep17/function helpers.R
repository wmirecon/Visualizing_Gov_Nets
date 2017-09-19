# this is a file for functions to be used in the shiny app



# this function takes a vector of org names and returns a new edge list containing
# the function relies on vectorized code to make sure it runs fast
# the nodes that are to be included in the final edgelist are passed in a vector or org names
# initial edgelist, respectively, area "to list" and a "from list" are generated where the 
#   to node and the from node from the included in the passed vector of org names
# edges must be in both lists to be included in the final edgelist
# vectorization requires that only one column of data be considered at a time
# to allow for comparison of one column, data are concatented into comparable string representations
# only those edges with string representations found in both lists are included in the final data
filter_el <- function( el, orgs ) {
  
  el.from <- el[el$from %in% orgs,]           # get edges where the from node is in the org vector ("from list")
  el.to <- el[el$to %in% orgs,]               # get edges where the to node is in the org vector ("to list")
  
  
  # get edge string represtations for the dyads in both the to and from lists
  # the representations are appended as a new, 3rd column
  el.from$string <- paste(el.from$from,
                          "-",
                          el.from$to,
                          sep = "")
  el.to$string <- paste(el.to$from,
                        "-",
                        el.to$to,
                        sep = "")
  
  # select only those dyads where the string representation is in both lists
  #  by getting the dyads in the from list that are also in the to list
  el.filtered <- el.from[el.from$string %in% el.to$string,]
  
  return( unique( el.filtered[,-3]) )        # return the filtered edgelist, w/out the string representation
}


# this function is used to select the organizations that should be included based on AA/DM/PT selection
# the app inputs will determine what index number(s) should be passed to the function
# the index will indicate what AA/DM/PT has been selected
# this function uses that selection to limit the org list to only those that use that AA/DM/PT
select.orgs <- function( orgs, index.set ) {
  col.set <- c( c(1:9), index.set )         # set of column indexes that contain attribute and filtering data
  orgs.filter <- orgs[,col.set]             # select only the relevant AA/DM/PT data, plus initial attributes
  # print(ncol(orgs.filter))
  if ( ncol( orgs.filter ) > 10 ) {         # PT is stored in three columns while AA/DM use only 1
    # PT must have 1 in at least one of the three columns
    # sum across columns to get a total
    # will retain data where the sum is at least 1
    # this will also hold for joining data from different tools, arenas, and domains
    orgs.filter$sum <- rowSums(orgs.filter[,c(10:ncol(orgs.filter))])     # if PT, use row sums
  } else {
    colnames(orgs.filter)[10] <- "sum"      # if DM/AA, rename last column to match PT row sum column
  }
  orgs.select <- orgs.filter[orgs.filter$sum >= 1, ]     # filter based on sum column; AA/DM == 1; PT >= 1
  return( orgs.select[,c(1:9)] )                         # return only the attr data from the filtered list
}