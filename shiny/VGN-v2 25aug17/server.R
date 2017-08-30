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
source( "helpers.R" )

# load in org data
org.list.bi.data <- read.csv( "data/org_list_bi_data.csv" )


# read in edge data for all of the functional subnetworks
is.el <- read.csv( "data/is_2015_el.csv ")
ta.el <- read.csv( "data/ta_2015_el.csv ")
pc.el <- read.csv( "data/pc_2015_el.csv ")
rt.el <- read.csv( "data/rt_2015_el.csv ")
fs.el <- read.csv( "data/fs_2015_el.csv ")

# node size factor is used to create greater contrast between more and less central nodes
# an unmodified degree measure, particularly a normalized measure, doesn't have sufficient
#   variation in size for someone looking at the map to see the difference
# later versions can make this an input, and allow for varying sizes
node.size.factor <- 75

# make a union network that inlcudes links from all the functional subnetworks
union.el <- unique( rbind( is.el, ta.el, pc.el, rt.el, fs.el ) )

# generate a network map from the input options
shinyServer( function ( input, output ) {
  
  # create the network map
  # map is rendered as visNetwork map and stored in the output list as 'net.map'
  
  output$net.map <- renderForceNetwork({
    if( input$net.select != "Select a subnet" ) {
      
      # select an edge to use to make the network map
      el <- switch( input$net.select,
                    "Select a subnet" = data.frame(from = c(),
                                                   to = c()),
                    "Information Sharing" = is.el,
                    "Techncial Assistance" = ta.el,
                    "Program Coordination & Collaboration" = pc.el,
                    "Reporting" = rt.el,
                    "Financial Resource Sharing" = fs.el,
                    "Union: All Subnets" =  union.el )
      
      # filter node list - used now to speed up testing by getting a smaller network
      # will later be used to select nodes for egonets and DM/AA/PT/AM selection
      
      #nodes <- unique(head(org.list.bi.data[,c(1:9)], n = 50))
      nodes <- unique(org.list.bi.data[,c(1:9)])
      
      # change numeric labels to text labels
      nodes$capacity.group <- capacity.labels[nodes$capacity]
      nodes$sector.group <- sector.labels[nodes$sector]
      nodes$juris.group <- juris.labels[nodes$jurisdiction]
      nodes$juris.level.group <- juris.level.labels[nodes$juris.level]
      
      # filter the edgelist based on the node selection
      links <- filter_el(el = el,
                         orgs = nodes[,1])
      
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
      degrees$degree <- ( degrees$degree / ( nrow(nodes) - 1 ) ) * node.size.factor
      
      # merge degree centrality into node list
      nodes <- left_join(nodes,
                         degrees,
                         by = "org.name")
      
      nodes$tool.tip <- paste(nodes$org.name,
                              " - ",
                              round(nodes$degree, digits = 2),
                              "%",
                              sep = "")
      
      # transfrom data to work in network3D library
      nodes.d3 <- cbind(org.name.f = factor(nodes$org.name, levels = nodes$org.name), nodes)
      nodes.d3 <- nodes.d3[order(nodes.d3$org.name),]
      
      links.d3 <- links
      links.d3 <- links.d3[order(links.d3$from),]
      links.d3$from.index <- match(links.d3$from, nodes.d3$org.name) - 1
      links.d3$to.index <- match(links.d3$to, nodes.d3$org.name) - 1
      
      
      # correctly matching nodes and links requires sorting the 'source' data in the same order
      #   as the node ids
      
      
      forceNetwork(Links = links.d3,
                   Nodes = nodes.d3,
                   Source = "from.index",
                   Target = "to.index",
                   NodeID = "tool.tip", 
                   Group = "sector.group",
                   Nodesize = "degree",
                   #colourScale = Dark2,
                   #height = 400,
                   #width = 600,
                   legend = T,
                   zoom = T,
                   fontSize = 12
      ) # end of forceNetwork
      } # end of if-statement
  }) # end of map output
  
}) # end of shinyServer