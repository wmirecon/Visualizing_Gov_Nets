# this is a file for functions to be used in the shiny app

# setup a set of look up tables (R's equivalent to a Python dictionary) for transforming
#   attribute data to text labels

capacity.labels <- c("1" = "Very small orgaizations",
                     "2" = "Small organizations",
                     "3" = "Medium organizations",
                     "4" = "Large domestic organizations",
                     "5" = "Large international organizations")

sector.labels <- c("1" = "Federal agencies",
                   "2" = "State/Provincial agencies",
                   "3" = "Regional gov't agencies",
                   "4" = "Local gov't agencies",
                   "5" = "Profit/For-Profit",
                   "6" = "NGO/Non-Profit",
                   "7" = "Individuals",
                   "8" = "Research Inst.",
                   "9" = "Int'l gov't agencies")

juris.labels <- c("1" = "Vermont",
                  "2" = "New York",
                  "3" = "Quebec",
                  "4" = "United States",
                  "5" = "Canada",
                  "6" = "International")

juris.level.labels <- c("1" = "Village/Sub-town",
                        "2" = "Town/Municipality",
                        "3" = "County",
                        "4" = "Sub-state Region",
                        "5" = "Watershed",
                        "6" = "State",
                        "7" = "National",
                        "8" = "International")

filter_el <- function( el, orgs ) {
  # this function takes a vector of org names and returns a new edge list containing
  # the function relies on vectorized code to make sure it runs fast
  # the nodes that are to be included in the final edgelist are passed in a vector or org names
  # initial edgelist, respectively, area "to list" and a "from list" are generated where the 
  #   to node and the from node from the included in the passed vector of org names
  # edges must be in both lists to be included in the final edgelist
  # vectorization requires that only one column of data be considered at a time
  # to allow for comparison of one column, data are concatented into comparable string representations
  # only those edges with string representations found in both lists are included in the final data
  
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