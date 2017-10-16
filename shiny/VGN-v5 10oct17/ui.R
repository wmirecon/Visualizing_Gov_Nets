# ui.R for Visualizing Governance Net

# load in the required R packages
library( shiny )
library( igraph )
library( networkD3 )
library( dplyr )
library( RColorBrewer )

# make sure strings are handled as strings
options( stringsAsFactors = F )
source("look up helpers.R")
org.list <- read.csv( "data/org_list_bi_data.csv" )[,1]
names(org.list) <- org.list  # values must be named in checkbox, so naming with values; names and values match

# setup in the user interface
# options selected in the UI are stored in 'input'
# specific inputs are labeled here and accessed in server.R as 'input$varname'
shinyUI( fluidPage(
  
  # app title
  titlePanel( "Visualizing Governance Networks" ),
  
  # use a sidebar layout; controls on the left, map on the right
  sidebarLayout(
    sidebarPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Network Filtering",
                           # setup subnet selection dropbox
                           h3("Network Filtering Options"),
                           selectInput( "net.select",                                     # input varname for functional subnet selection
                                        label = "Choose which subnetwork to display:",
                                        # list of values to include in the dropbox
                                        choice = subnet.choices
                           ),
                           # setup domain input selection
                           selectInput( "dm.select",
                                        label = "Choose a policy domain:",
                                        choice = dm.choices
                           ),
                           # setup policy tool input selection
                           selectInput( "pt.select",
                                        label = "Choose a policy tool focus:",
                                        choice = pt.choices
                           ),
                           # setup action arenas input selection
                           selectInput( "aa.select",
                                        label = "Choose an action arena:",
                                        choice = aa.choices
                           ),
                           # choose how to use the AA/DM/PT inputs - union or intersection
                           radioButtons( "join.method",
                                         label = "Choose a filtering method:",
                                         choices = c("Organizations in all of the selected filters (Intersection)" = 1,
                                                     "Organizations in any of the selected filters (Union)" = 2),
                                         selected = 1
                           ),
                           
                           # display network stats output
                           h3("Network Statistics"),
                           h5(strong("Number of Organizations:")),
                           verbatimTextOutput("node.count"),
                           h5(strong("Number of Links:")),
                           verbatimTextOutput("link.count"),
                           h5(strong("Network Density (%):")),
                           verbatimTextOutput("net.density")
                           
                  ),  # end of tabPanel1: network filtering
                  tabPanel("Focus Organizations",
                           h3("Select any focus organizations"),
                           p(" The network will contain only these organizations and their immediate neighbors"),
                           checkboxGroupInput("ego.list",
                                              label = ("Organization List"),
                                              choices = sort(org.list)
                                              )  # end of checkbox input
                  ) # end of tabPanel2: egonets selection
                  ) # end of tabsets
      ), # end of sidebar panel
    
    # setup output panel
    # values determined in server.R; accessed here by name assigned there, placed in quotes ("")
    mainPanel(
      tabsetPanel(
        type = "tabs",
        tabPanel(
          "Network Map",
          
          # render the map made in server.R as plot output
          forceNetworkOutput( "net.map", height = "650px" ),
          
          # setup text output for below the figure
          p("Use the selection criteria to view a smaller piece of the network."),
          p("If you've selected a subnetwork along with other filters and no network shows, no links were found within your selection."),
          p("The number after a node's name is its connection rate, reporting how many links the node has out of its possible links (normalized degree centrality).")
        ), # end of net map panel
        tabPanel(
          "Major Organizations",
          h4("The most connected organizations"),
          p("Initially sorted by degree centrality"),
          dataTableOutput("key.orgs.table")
        ), # end of key orgs panel
        tabPanel("More Information",
                 h3("Project Information"),
                 HTML("<p>Project Final Report <a href = \"https://github.com/wmirecon/Visualizing_Gov_Nets/blob/master/VGN%20Final%20Report%20v1%2016oct17.pdf\">on Github</a>."),
                 HTML("<p>Project Data Wrangling Report <a href = \"https://github.com/wmirecon/Visualizing_Gov_Nets/blob/master/data%20wrangling%20report.pdf\">on Github</a>."),
                 HTML("<p>Application data publicly available <a href = \"https://github.com/wmirecon/Water_Quality_Governance_Networks\">on Github</a>."),
                 HTML("<p>Dataset Codebook <a href = \"https://github.com/wmirecon/Water_Quality_Governance_Networks/blob/master/CodeBook%20v1%20Anonymized.pdf\">on Github</a>."),
                 HTML("<p>App Source Code <a href = \"https://github.com/wmirecon/Visualizing_Gov_Nets/tree/master/shiny/VGN-v5%2010oct17\">on Github</a>."),
                 HTML("<p><a href = \"http://igraph.org/r/\">R igraph network analysis package</a>, used for computing network statistics."),
                 HTML("<p><a href = \"http://christophergandrud.github.io/networkD3/\">NetworkD3 package</a>, used for generating the network map."),
                 h3("Network Terminology Definitions"),
                 p("Network Density: Number of links observed divided by total possible number of links (D = L/(n(n-1)) where L is link count and n is number of nodes)."),
                 p("Degree: The number of links a node has, normalized by dividing by the number of organizations minus 1 (n-1)."),
                 p("Eigenvector: Your degree as well as the degree of your neighbors, normalized to a range of 0-1."),
                 p("Betweenness: How many of the shortest paths from one node to another run through this node, normalized by dividing by a theoretical maximum.")
        ) # end of tabPanel3: references
      ) # end of main panel tab sets
    ) # end of main panel
  ) # end of sidebar layout
  
)) # end of shinyUI({})