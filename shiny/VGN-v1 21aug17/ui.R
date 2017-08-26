# ui.R for Visualizing Governance Net

# setwd("~/In Class Notes/Springboard/capstone projects/Visualizing_Gov_Nets/shiny/VGN-v1 21aug17")

library( shiny )
library( igraph )

shinyUI( fluidPage(
  titlePanel( "Visualizing Governance Networks-V1 21Aug17" ),
  sidebarLayout(
    sidebarPanel(
      
      # setup subnet selection dropbox
      selectInput( "net.select",
                   label = "Choose wich subnetwork to display",
                   choice = c("Information Sharing",
                              "Techncial Assistance",
                              "Program Coordination & Collaboration",
                              "Reporting",
                              "Financial Resource Sharing",
                              "Union: All Subnets")
                   )
      ),
    mainPanel(
      
      # render the map in the shiny app
      plotOutput( "net.map" )
    )
  )
))