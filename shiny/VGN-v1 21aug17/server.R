# server.R for Visualizing Governance Net

library( shiny )
library( igraph )

# read in network data
org.list <- read.csv( "data/org_list.csv" )
is.el <- read.csv( "data/is_2015_el.csv ")
ta.el <- read.csv( "data/ta_2015_el.csv ")
pc.el <- read.csv( "data/pc_2015_el.csv ")
rt.el <- read.csv( "data/rt_2015_el.csv ")
fs.el <- read.csv( "data/fs_2015_el.csv ")

shinyServer( function ( input, output ) {
  
  output$net.map <- renderPlot({
    
    # select an edge to use to make the network map
    el <- switch( input$net.select,
                  "Information Sharing" = is.el,
                  "Techncial Assistance" = ta.el,
                  "Program Coordination & Collaboration" = pc.el,
                  "Reporting" = rt.el,
                  "Financial Resource Sharing" = fs.el,
                  "Union: All Subnets" = unique( rbind( is.el, ta.el, pc.el, rt.el, fs.el ) ) )
    
    # generate the igraph network (graph) object
    net <- graph.data.frame( el,
                             directed = F,
                             vertices = org.list
                             )
    
    # create the network map
    plot(net)
  })
  
})