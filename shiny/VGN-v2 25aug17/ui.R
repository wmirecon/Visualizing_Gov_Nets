# ui.R for Visualizing Governance Net

# load in the required R packages
library( shiny )
library( igraph )
library( networkD3 )
library( dplyr )
library( RColorBrewer )

# make sure strings are handled as strings
options( stringsAsFactors = F )

# setup in the user interface
# options selected in the UI are stored in 'input'
# specific inputs are labeled here and accessed in server.R as 'input$varname'
shinyUI( fluidPage(
  
  # app title
  titlePanel( "Visualizing Governance Networks-V2 25Aug17" ),
  
  # use a sidebar layout; controls on the left, map on the right
  sidebarLayout(
    sidebarPanel(
      
      # setup subnet selection dropbox
      selectInput( "net.select",                                     # input varname for functional subnet selection
                   label = "Choose wich subnetwork to display",
                   
                   # list of values to include in the dropbox
                   choice = c("Select a subnet",
                              "Information Sharing",
                              "Techncial Assistance",
                              "Program Coordination & Collaboration",
                              "Reporting",
                              "Financial Resource Sharing",
                              "Union: All Subnets")
                   )
      ),
    
    # setup output panel
    # values determined in server.R; accessed here by name assigned there, placed in quotes ("")
    mainPanel(
      h3("Please select a subnetwork"),
      
      # render the map made in server.R as plot output
      forceNetworkOutput( "net.map", height = "650px" ),
      
      # setup text output for below the figure
      p("The number after a node's name is its connection rate, reporting how many links the node has out of its possible links (normalized degree centrality)."),
      br(),
      h4("Please be patient with large networks. They are loading but may be slow."),
      p("Use the selection criteria to view a smaller piece of the network.")
      
    )
  )
))