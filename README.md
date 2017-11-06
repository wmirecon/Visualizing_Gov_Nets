# Visualizing_Gov_Nets
Repository for Developing an  R/Shiny App to display WQIN data

## Project Structure

Large organizational networks are difficult to communicate while their complexity limits the use of network maps, usually the best tool for quickly communicating about networks, as a communication tool.
Developing and deploying a tool for an interactive network map, a map that allows users to engage with the network and to explore the network on their own, reclaims much of that communications value.
This project develops and deploys an interactive tool for participants in Vermont's efforts to improve water quality in the Lake Champlain Basin (LCB) to engage with the network that is making and implementing
water quality policy in the LCB.

## Shiny App

The final version of the app can be accessed on ShinyApps.io: https://wmirecon.shinyapps.io/vgn-v5_10oct17/

## Repository Structure

Files within this section of the repository contain project final and milestone reports and the project's initial proposal.
1. VGN User Guide
2. VGN Technical Guide (VGN Tech Guide.pdf)
3. Milestone Report (Capstone 1 - Visualizing ... .ipynb)
4. Data Wrangling Report
5. Final results presentation (VGN Presentation v1 16oct17.pptx)

Additional files include
1. IPyNB for data wrangling in Python (ipython script prep.ipynb)
2. Script for data wrangling in R

## Subfolders

### shiny

Source code for the app and data used in the app. The app can be accessed from ShinyApps.io but it can be downloaded from here, as a complete package. See the folder's README for instructions for downloading and running locally.

### data

Raw project data, used for data wrangling. See the Codebook in this folder for a detailed description of the data.
The data are publicly available here: https://github.com/wmirecon/Water_Quality_Governance_Networks

### Working Code

A set of Jupyter notebooks that test different portions of the app's source code prior to their inclusion in the app.

## Reports

**VGN User Guide:** Provides a full explanation of this project and the app's features.

**VGN Tech Guide:** Provides an explanation of the data wrangling code and app source code.

**Milestone Report:** Shows the limits of maps in displaying large networks and demonstrates the use of interactive maps.
Opening the report from here will not display the interactive map. Download and run in
Jupyter Notebook to see the interactive network map. If you do not have R installed,
then select and install RStudio from your Anaconda Navigator. This will install the
R kernel necessary to run this notebook.

After downloading, run the following line of code to install the packages used in the report:

`install.packages(c("dplyr","igraph","networkD3"))`

**Data Wrangling:** Provides a detailed explanation of the data wrangling process and Python code.