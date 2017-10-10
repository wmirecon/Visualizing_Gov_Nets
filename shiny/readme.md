******************************
# Shiny Apps for Visualizing Governance Networks
******************************

V4 of the app has been deployed on shinyapps.io:
https://wmirecon.shinyapps.io/vgn-v4_3oct17/

=======
## Versioning Information

Design aspect added for each version:
1. Subnetwork selection and static mapping
2. Dynamic/Interactive mapping
3. Subnet filtering and improved map readability
4. Individual node selection
5. Rebuild with reactive functions and add network stats and top orgs output

=======

If you wish to run the app locally:
1. Download and Install R and RStudio

R: https://www.r-project.org/

RStudio: https://www.rstudio.com/


2. From RStudio, download and install R/shiny:

`install.packages("shiny")`

`library(shiny)`


3. Shiny apps are made up of a ui.R (for the interface) and server.R (for the backend) files, associated data folders, and any R scripts for helper functions. Download the whole folder that contains all of these files, not just the contents.
4. Open ui.R, server.R, or both in RStudio. Press the 'Run App' button in the top-right corner of the R script panel.

=======
## Fixing the Legend in place while zooming and panning the map

The current (as of 13 September 17) CRAN release of _networkD3_ does not support fixing the legend in place while panning and zooming the map. But the current developer version of the package does. To fix the legend in place, install the developer version using the following steps:

1. Install the *devtools* package in R/RStudio: `install.packages("devtools")`
2. Attach the *devtools* package: `library(devtools)`
3. Install the dev version of *networkD3*: `install_github('christophergandrud/networkD3')`

=======

**Note**: If you wish to run the app from a browser, in RStudio, select the drop down menu (small black arrow) to the right of the 'Run App' button and select 'Run external'.
For v2 and later, I **strongly** recommend opening in a browser, as this is necessary to support all of the interactive map's features.

If you find you need to install any other packages, they can always be installed with:

`install.packages("<package name>")`

for example:
`install.packages("igraph")`

To install all necessary packages use:
`install.packages(c("shiny", "igraph","networkD3","dplyr", "RColorBrewer"))`

