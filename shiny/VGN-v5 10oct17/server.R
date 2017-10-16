# server.R for Visualizing Governance Net

library( shiny )
library( igraph )
library( networkD3 )
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


# establish reactive functions and output
shinyServer( function ( input, output ) {
  
 
  # Each time a setting is changed, the appropriate reactive functions are re-run
  # reactive functions re-run whenever any of their inputs are changed by either the user or
  #   by another reactive function
  # Reactive functions and output (organized by functional sections):
  
  ## Edglist Selection
  #   1. get.raw.el({}) gets a new raw edgelist whenever a subnet is selected
  
  ## Org list filtering
  #   2. select.dm({}) renders the user's domain selection as a index value for filtering
  #   3. select.pt({}) renders the user's tool selection as a index value for filtering
  #   4. select.aa({}) renders the user's action arena selection as a index value for filtering
  #   5. filter.orgs({}) combines the above output together to create a single filtered org set
  #   6. ego.filter({}) futher filters the node list based on egonet options
  
  ## Edgelist filtering and network construction
  #   7. get.net({}) turns the filtered node and edgelists into an igraph net object
  
  ## Output generation
  #   8. forceNetwork({}) Convert data for mapping and make map.
  #   9. key.orgs.table({}) generate table for top 10 most connected nodes
  #  10. node.count({}) gives a network node count for the network statistics
  #  11. link.count({}) gives a network link count for the network statistics
  #  12. net.density({}) give a network density for the network statistics
  
  
  
  ## *************************
  # Setup Reactive functions *
  ## *************************
  
  
  ## Edgelist Selection
  
  # 1. get.raw.el({})
  # whenever the user changes their subnet selection, this function is re-run and new output produced
  get.raw.el <- reactive({
    switch( input$net.select,
            "Information Sharing" = is.el,
            "Techncial Assistance" = ta.el,
            "Program Coordination & Collaboration" = pc.el,
            "Reporting" = rt.el,
            "Financial Resource Sharing" = fs.el,
            "Union: All Subnets" = union.el )
  }) # end of get.raw.el({})
  
  
  ## Org list filtering
  
  # 2. select.dm({})
  # input is rendered as text
  # a look up table (ie, what python would call a dictionary) is used to transform text to number label
  # number label is recast as a number and returned
  select.dm <- reactive({
    return(as.numeric(dm.choice.index[input$dm.select]))
  }) # end of select.dm({})
  
  # 3. select.pt({})
  # render the user's tool selection as a vector of numbers
  # process is similar to domains and AA's except that tools are coded into three columns
  #   in the input org list
  # the columns for each tool are 12 columns apart
  # the look up table returns the first number and this function adds the second two
  # it then returns a vector with all three numbers
  select.pt <- reactive({
    pt.select <- as.numeric(pt.choice.index[input$pt.select])
    pt.select <- c(pt.select, pt.select + 12, pt.select + 24)
    return(pt.select)
  }) # end of select.pt({})
  
  # 4. select.aa({})
  # same logic/process and return as select.dm({})
  select.aa <- reactive({
    return(aa.select <- as.numeric(aa.choice.index[input$aa.select]))
  }) # end of select.aa({})
  
  # 5. filter.orgs({})
  # applies the filters obtained above, based on the chosen filtering method
  filter.orgs <- reactive({
    # get input data from reactive functions 3, 4, and 5
    dm.select <- select.dm()
    pt.select <- select.pt()
    aa.select <- select.aa()
    
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
        } # end of DM filtering
        
        # rinse and repeat for PT and AA
        if ( !is.na( pt.select[1] ) ) {    # policy tool
          additions <- select.orgs( orgs = org.list.bi.data,
                                    index.set = pt.select
          )$org.name
          additions <- unique( additions )
          raw.selection <- c( raw.selection, additions )
        } # end of PT filtering
        
        if ( !is.na( aa.select ) ) {       # action arena
          additions <- select.orgs( orgs = org.list.bi.data,
                                    index.set = aa.select
          )$org.name
          additions <- unique( additions )
          raw.selection <- c( raw.selection, additions )
        } # end of AA filtering
        
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
        
        # end of intersection filtering
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
        } # end of union filtering
      } # end of node filtering by AA/PT/DM
    
    return( nodes )
    
    }) # end of filter.orgs({})
  
  # 6. ego.filter({})
  # transfers user settings for egonets (focus orgs) into further org list filtering
  ego.filter <- reactive({
    return( as.vector(input$ego.list) )   # store any selected egos a vector of character names
  }) # end of ego.filter({})
  
  
  ## Network Construction
  
  # 7. get.net({})
  get.net <- reactive({
    
    # get edge and node lists from the reactive functions that read in input
    el <- get.raw.el()
    nodes <- filter.orgs()
    
    links <- filter_el(el = el,
                       orgs = nodes[,1])
    # binarize the edgelist (remove duplicate entries)
    links <- unique(links)
    
    # if any focus nodes have been selected further filter based on those nodes
    ego.list <- ego.filter()
    if ( length(ego.list) > 0 ) {
      ego.orgs <- get.ego.set( egos = ego.list,
                               links = links )
      links <- filter_el(el = links,
                         orgs = ego.orgs)
      nodes <- nodes[nodes[,1] %in% ego.orgs,]
    } # end of egonet selection filtering
    
    # change numeric labels to text labels
    nodes$capacity.group <- capacity.labels[nodes$capacity]
    nodes$sector.group <- sector.labels[nodes$sector]
    nodes$juris.group <- juris.labels[nodes$jurisdiction]
    nodes$juris.level.group <- juris.level.labels[nodes$juris.level]
    
    # generate the igraph network (graph) object
    net <- graph.data.frame( links,
                             directed = F,
                             vertices = nodes )
    
    # simplify the network to remove self loops and remove duplicate links
    net <- simplify(net)
    
    # obtain degree centrality measures
    # degree measures are extracted using igraph's degree() and stored as a network attribute
    # the measure is then normalized by dividing by the maximum possible degree
    # maximum degree = (# nodes - 1) as any node could be connected to any other node
    # normalization is provided by igraph
    V(net)$degree <- degree(net, 
                            normalized = T)
    
    # also obtain normalized betweenness
    # geodesics in a network are the shortests path from any given node to any other given node
    # betweenness centrality of a node is the number of geodesics that pass through a given node
    # betweenness normalized as: Bnorm=2*B/(n*n-3*n+2); where B is raw betweenness and n is number of nodes
    # normalization is provided by igraph
    V(net)$betweenness <- betweenness(net,
                                      normalized = T)
    
    # and also obtain eigenvector centrality
    # eigenvector centrality is a complex formula for supercharging degree centrality
    # it factors in both a node's own degree and the degrees of that nodes neighbors
    # high eigenvector indicates that a node is well-connected to neighbors who are also well-connected
    # normalization is often done by dividing by the maximum observed value and is not provided by igraph
    V(net)$eigenvector <- evcent(net)$vector
    V(net)$eigenvector <- V(net)$eigenvector / max(V(net)$eigenvector)
    
    return(net)
    
  }) # end of get.net({})
  
  
  
  ## ***********
  # Run Output *
  ## ***********
  
  # 8. generate network map
  output$net.map <- renderForceNetwork({
    
    # first, ensure that a network has been selected, else leave the area blank
    
    if( input$net.select != "Select a subnet" ) {
      
      ## Setup network for plotting
      
      # get the network to plot
      net <- get.net()
      
      # get edgelist from the network and reset column names
      links <- data.frame(get.edgelist(net))
      colnames(links) <- c("from", "to")
      
      # get nodelist from the network
      nodes <- get.node.list.from.net(net = net)
      
      if ( nrow( links ) > 0 ) {
        ## Add size and tool tip for use in the graph
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
        
        
        ## Render graph
        forceNetwork(Links    = links.d3,
                     Nodes    = nodes.d3,
                     Source   = "from.index",
                     Target   = "to.index",
                     NodeID   = "tool.tip", 
                     Group    = "sector.group",
                     Nodesize = "size",
                     #height  = 400,
                     #width   = 900,
                     legend   = T,
                     zoom     = T,
                     fontSize = 24,
                     charge   = -275,
                     linkColour = "wheat",
                     colourScale = JS("d3.scaleOrdinal(d3.schemeCategory10);"),
                     radiusCalculation = JS(" Math.sqrt(d.nodesize)+3")
        ) # end of forceNetwork
      } # end of if-statement for checking if any links remain after filtering
    } # end of if-statement for checking if a graph should be rendered or not based on edgelist selection
  }) # end of renderForceNetwork({})
  
  # 9. key.orgs.table({})
  output$key.orgs.table <- renderDataTable({
    
    # check to make sure there is input; if not, don't render the table
    if( input$net.select != "Select a subnet" ) {
      
      # get the network to find the most connected nodes
      net <- get.net()
      
      # get nodelist from the network
      nodes <- get.node.list.from.net(net = net)
      
      # cut out unnecessary columns; these are the numeric labels for attribute values
      nodes <- nodes[,-c(3:7)]
      
      # sort to move the top orgs to the top of the list
      nodes.sorted <- nodes[order(-nodes$degree),]
      
      return(nodes.sorted)
    } # end of test for input
  }) # end of key.orgs.table({})
  
  # 10. node.count({})
  # returns a text string of the number of nodes in the network
  output$node.count <- renderText({
    if( input$net.select != "Select a subnet" ) {
      net <- get.net()
      return(vcount(net))
    } else     # end of if to check if output should be generated
      return("0")
  }) # end of node.count({})
  
  # 11. link.count({})
  # returns a text string of the number links in the network
  output$link.count <- renderText({
    if( input$net.select != "Select a subnet" ) {
      net <- get.net()
      return(ecount(net))
    } else     # end of if to check if output should be generated
      return("0")
  }) # end of link.count({})
  
  # 12. net.density({})
  # returns a text string of the network's density
  # density is the % of the nodes that could be observed in a network that are observed
  # D = 2(l/(n(n-1))) where n = node count, l = link count, and the network is undirected
  output$net.density <- renderText({
    if( input$net.select != "Select a subnet" ) {
      net <- get.net()
      return(100 * graph.density(net))
    } else     # end of if to check if output should be generated
      return("0.00")
  }) # end of net.density({})
  
}) # end of shinyServer({})


