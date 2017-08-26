# server.R for Visualizing Governance Net

# load in the required R packages
library( shiny )
library( igraph )
library( networkD3 )

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

# make a union network that inlcudes links from all the functional subnetworks
union.el <- unique( rbind( is.el, ta.el, pc.el, rt.el, fs.el ) )

# generate a network map from the input options
shinyServer( function ( input, output ) {
  
  # create the network map
  # map is rendered as visNetwork map and stored in the output list as 'net.map'
  output$net.map <- renderForceNetwork({
    
    # select an edge to use to make the network map
    el <- switch( input$net.select,
                  "Select a Subnet" = data.frame(from = c(),
                                                 to = c()),
                  "Information Sharing" = is.el,
                  "Techncial Assistance" = ta.el,
                  "Program Coordination & Collaboration" = pc.el,
                  "Reporting" = rt.el,
                  "Financial Resource Sharing" = fs.el,
                  "Union: All Subnets" =  union.el )
    
    # generate the igraph network (graph) object
    # net <- graph.data.frame( el,
    #                          directed = F,
    #                         vertices = org.list
    # )
    # render the map
    
    # filter node list - used now to speed up testing by getting a smaller network
    # will later be used to select nodes for egonets and DM/AA/PT/AM selection
    
    #nodes <- unique(head(org.list.bi.data[,c(1:9)],
    #                     n = 150))
    nodes <- unique(org.list.bi.data[,c(1:9)])
    
    # change numeric labels to text labels
    nodes$capacity.group <- capacity.labels[nodes$capacity]
    nodes$sector.group <- sector.labels[nodes$sector]
    nodes$juris.group <- juris.labels[nodes$jurisdiction]
    nodes$juris.level.group <- juris.level.labels[nodes$juris.level
                                                  ]
    # filter the edgelist based on the node selection
    links <- filter_el(el = el,
                       orgs = nodes[,1])
    
    # transfrom data to work in network3D library
    links$from <- as.numeric(factor(links$from)) - 1 
    links$to <- as.numeric(factor(links$to)) - 1
    nl <- cbind(org.name = factor(nodes$org.name, levels = nodes$org.name), nodes)
    
    
    
    forceNetwork(Links = links,
                 Nodes = nl,
                 Source = "from",
                 Target = "to",
                 NodeID = "org.name", 
                 Group = "sector.group",
                 height = 400,
                 width = 600,
                 legend = T,
                 zoom = T,
                 fontSize = 12
    )
  })
  
})