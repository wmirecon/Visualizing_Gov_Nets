******************************
# Shiny Apps for Visualizing Governance Networks
******************************

To view the app:
1. Download and Install R and RStudio

R: https://www.r-project.org/

RStudio: https://www.rstudio.com/


2. From RStudio, download and install R/shiny:

> install.packages("shiny")

> library(shiny)


3. Shiny apps are made up of a ui.R (for the interface) and server.R (for the backend) files, associated data folders, and any R scripts for helper functions. Download the whole folder that contains all of these files, not just the contents.
4. Open ui.R, server.R, or both in RStudio. Press the 'Run App' button in the top-right corner of the R script panel.

=======

**Note**: If you wish to run the app from a browser, select the drop down menu (small black arrow) to the right of the 'Run App' button and select 'Run external'.
For v2 and later, I **strongly** recommend opening in a browser, as this is necessary to support all of the interactive map's features.

If you find you need to install any other packages, they can always be installed with:

> install.packages("<package name>")

for example:
  > install.packages("igraph")

To install all necessary packages use:
  > install.packages(c("shiny", "igraph","networkD3","dplyr"))
