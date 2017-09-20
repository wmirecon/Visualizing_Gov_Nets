# server.R for Visualizing Governance Net

# load in the required R packages
library( shiny )
library( igraph )
library( networkD3 )
library( dplyr )
library( RColorBrewer )

# make sure strings are handled as strings
options( stringsAsFactors = F )

# load helper functions; see helpers.R
source("look up helpers.R")
source("function helpers.R")

# load in org data
org.list.bi.data <- read.csv( "data/org_list_bi_data.csv" )

# read in edge data for all of the functional subnetworks
is.el <- read.csv( "data/is_2015_el.csv" )
ta.el <- read.csv( "data/ta_2015_el.csv" )
pc.el <- read.csv( "data/pc_2015_el.csv" )
rt.el <- read.csv( "data/rt_2015_el.csv" )
fs.el <- read.csv( "data/fs_2015_el.csv" )

# node size factor is used to create greater contrast between more and less central nodes
# an unmodified degree measure, particularly a normalized measure, doesn't have sufficient
#   variation in size for someone looking at the map to see the difference
# later versions can make this an input, and allow for varying sizes
node.size.factor <- 150

# make a union network that inlcudes links from all the functional subnetworks
union.el <- unique( rbind( is.el, ta.el, pc.el, rt.el, fs.el ) )

# generate a network map from the input options
shinyServer( function ( input, output ) {
  
  # Each time a setting is changed, this code will run and produce a map
  # Steps:
  #   1. Select the apprropriate subnetwork and load its links as the primary edgelist
  #   2. Filter the organization list using the different filtering options
  #   3. Filter the primary edgelist based on the org list filtering; only retain dyads
  #      where both nodes are included in the filtered org list
  #   4. Gather network data for use in map display
  #   5. Convert data for mapping and make map.
  
  # create the network map
  # map is rendered as visNetwork map and stored in the output list as 'net.map'
  
  output$net.map <- renderForceNetwork({
    if( input$net.select != "Select a subnet" ) {        # if no subnetwork is chosen, skip all output to avoid an error message
      
      # select an edgelist to use to make the network map
      #print(input$net.select) #-- was used for bug testing
      el <- switch( input$net.select,
                    "Select a subnet" = data.frame(from = c(),
                                                   to = c()),
                    "Information Sharing" = is.el,
                    "Techncial Assistance" = ta.el,
                    "Program Coordination & Collaboration" = pc.el,
                    "Reporting" = rt.el,
                    "Financial Resource Sharing" = fs.el,
                    "Union: All Subnets" =  union.el )
      
      # indicate which DM/PT/AA filters have been chosen and link to column indices in the org list
      pt.select <- as.numeric(pt.choice.index[input$pt.select])
      pt.select <- c(pt.select, pt.select + 12, pt.select + 24)
      aa.select <- as.numeric(aa.choice.index[input$aa.select])
      dm.select <- as.numeric(dm.choice.index[input$dm.select])
      
      # filter nodes; if no filters are selected, step is by-passed
      if ( is.na(dm.select) && is.na(pt.select[1]) && is.na(aa.select ) ) {
        #nodes <- unique(head(org.list.bi.data[,c(1:9)], n = 50))
        nodes <- unique(org.list.bi.data[,c(1:9)])
      } else {
        if ( input$join.method == 1 ) {                  # proceed here if using intersection of filters
          
          # filtering for intersection works by joining together the filtered lists using each filter independently
          # this org names from each separate filter are then joined into a common vector and the number of 
          #   times that an organization appears in that vector is counted
          # an organization must be observed in that vector at least as many times as there are filters applied
          # this count is taken and the frequency count from the vector filtered to produce a filtered list or orgs
          
          # take the count of filters used
          # if a filter is empty, it will be recorded as 'NA' (system missing)
          # the filter is tested as being not NA and then the T/F transformed to 1/0
          filter.count <-
            as.numeric(!is.na(dm.choice.index[input$dm.select])) +
            as.numeric(!is.na(pt.choice.index[input$pt.select])) +
            as.numeric(!is.na(aa.choice.index[input$aa.select]))
          
          # an output vector is created to store the combined results from individual filters
          raw.selection <- c()
          
          # apply the individual filters
          if ( !is.na( dm.select ) ) {       # policy domain
            
            # filter for all orgs involved in this domain and record their org.name
            additions <- select.orgs( orgs = org.list.bi.data,
                                      index.set = dm.select
                                      )$org.name
            
            # remove duplicates from this specific domain-specific filter
            additions <- unique( additions )
            
            # add domain-based filter of organizations to the collective output
            raw.selection <- c( raw.selection, additions )
          } # rinse and repeat for PT and AA
          if ( !is.na( pt.select[1] ) ) {    # policy tool
            additions <- select.orgs( orgs = org.list.bi.data,
                                      index.set = pt.select
                                      )$org.name
            additions <- unique( additions )
            raw.selection <- c( raw.selection, additions )
          }
          if ( !is.na( aa.select ) ) {       # action arena
            additions <- select.orgs( orgs = org.list.bi.data,
                                      index.set = aa.select
                                      )$org.name
            additions <- unique( additions )
            raw.selection <- c( raw.selection, additions )
          }
          
          # create and store a frequency table to get a count of how many times each org appears in the separate filters
          org.freq.df <- data.frame(table(raw.selection))
          # it was more effective to save this as a data frame; that allowed for vectorized filtering
          # efforts to use vectorized filtering without saving the dataframe failed, giving bad index value errors
          
          # filter frequency count dataframe based on filter.count
          #   retain orgs that were in at least enough filters
          selected.orgs <- org.freq.df[org.freq.df$Freq >= filter.count,1]
          
          # filter overall orglist based on the above filtering results and retain attribute data
          # this approach avoids using an additional left_join step and so should be faster
          nodes <- org.list.bi.data[org.list.bi.data$org.name %in% selected.orgs,c(1:9)]
          nodes <- unique( nodes )      # remove duplicate rows to avoid errors in making the network
        } else {                                     # proceed here if using union of filters
          
          # join separate DM/PT/AA filtering info into a single vector
          filter.select <- c(pt.select,
                             aa.select,
                             dm.select
                             )
          
          # select all organizations that are in at least one of the filtering options
          nodes <- select.orgs( orgs = org.list.bi.data,
                                index.set = na.omit( filter.select ) )
          nodes <- unique( nodes )
        }
      }
      
    # if (TRUE) {
    #    filter.node.set <- nodes$org.name
    #    nodes <- unique(org.list.bi.data[,c(1:9)])
    #    nodes$opacity <- 0.8
    #    print(nodes$org.name[!(nodes$org.name %in% filter.node.set)])
    #    nodes$opacity[ !(nodes$org.name %in% filter.node.set) ] <- 0.2
    #    print(nodes[nodes$opacity == 0.2, c(1,10)])
    #  }
      
      # change numeric labels to text labels
      nodes$capacity.group <- capacity.labels[nodes$capacity]
      nodes$sector.group <- sector.labels[nodes$sector]
      nodes$juris.group <- juris.labels[nodes$jurisdiction]
      nodes$juris.level.group <- juris.level.labels[nodes$juris.level]
      
      #print(nodes) #-- was used for bug testing
      # filter the edgelist based on the node selection
      links <- filter_el(el = el,
                         orgs = nodes[,1])
      # binarize the edgelist (remove duplicate entries)
      links <- unique(links)
      
      # generate the igraph network (graph) object
      net <- graph.data.frame( links,
                               directed = F,
                               vertices = nodes )
      
      # simplify the network to remove self loops and remove duplicate links
      #   and reaquire the edge list in the format needed by networkD3 by
      #   extracting the simplified edgelist from the igraph network object
      net <- simplify(net)
      links <- data.frame(get.edgelist(net))
      colnames(links) <- c("from", "to")        # reassign column names
      
      # obtain degree centrality measures
      # degree measures are extracted using igraph's degree()
      degrees <- data.frame( degree(net) )
      degrees <- cbind(data.frame(rownames(degrees)),
                       degrees[,1])
      colnames(degrees) <- c("org.name", "degree")
      
      # the measure is then normalized by dividing by the maximum possible degree
      # maximum degree = (# nodes - 1) as any node could be connected to any other node
      degrees$degree <- degrees$degree / ( nrow(nodes) - 1 )
      
      # merge degree centrality into node list
      nodes <- left_join(nodes,
                         degrees,
                         by = "org.name")
      nodes$size <- nodes$degree * node.size.factor
      
      nodes$tool.tip <- paste(nodes$org.name,
                              " - ",
                              100 * round(nodes$degree, digits = 2),
                              "%",
                              sep = "")
      
      # transfrom data to work in network3D library
      nodes.d3 <- cbind(org.name.f = factor(nodes$org.name, levels = nodes$org.name), nodes)
      nodes.d3 <- nodes.d3[order(nodes.d3$org.name),]
      
      # create separate, ordered link lists for use with the d3 interactive map
      links.d3 <- links
      links.d3 <- links.d3[order(links.d3$from),]
      
      # create from and to indices that are matched to the d3 link lists
      # this ensures proper matching of nodes and links in the network map
      links.d3$from.index <- match(links.d3$from, nodes.d3$org.name) - 1
      links.d3$to.index <- match(links.d3$to, nodes.d3$org.name) - 1
      
      forceNetwork(Links    = links.d3,
                   Nodes    = nodes.d3,
                   Source   = "from.index",
                   Target   = "to.index",
                   NodeID   = "tool.tip", 
                   Group    = "sector.group",
                   Nodesize = "size",
                   #height  = 400,
                   #width   = 600,
                   legend   = T,
                   zoom     = T,
                   fontSize = 16,
                   charge   = -275
      ) # end of forceNetwork
      
    } # end of if-statement
  }) # end of map output
  
}) # end of shinyServer