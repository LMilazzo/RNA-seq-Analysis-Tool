# RNA-seq Analysis Tool

 This applications provide an interactive interface for analyzing RNA sequencing data.

## Table of Contents
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [Requirements](#requirements)
- [Required R Packages](#required-r-packages)

---

## Installation

1. Clone this repository to your local machine using Git:
    ```bash
    git clone https://github.com/your-username/RNA-seq-Analysis-Tool.git
    cd RNA-seq-Analysis-Tool
    ```

   **Alternatively**, if you do not have Git installed, you can download the repository as a ZIP file:
   - Click the green "Code" button at the top of the repository page on GitHub.
   - Select "Download ZIP."
   - Extract the downloaded ZIP file to a directory of your choice.

2. Ensure you have R installed on your system. You can download it from [CRAN](https://cran.r-project.org/).

3. Install the required R packages listed in the [Required R Packages](#required-r-packages) section.

---

## Running the Application

To run the application, use the provided `run_app.R` script contained in either the Version 1.0.0 or Version 2.0.0 directories. 

1. Open your R console or an R IDE (e.g., RStudio).

2. Set your working directory to the location of the desired version `run_app.R` script. For example:

    ```R
    setwd("path/to/RNA-seq-Analysis-Tool/Version 2.0.0")
    ```

3. Run the script to launch the application

    If in Bash Terminal/Console
    ```bash
    Rscript run_app.R
    ```
    If in RStudio click 'run app' in the top right of your source file pane.


---

## Requirements

- A working installation of R (version 4.0 or higher is recommended).
- Internet connection if you think you may need to install some of the packages.

---

## Required R Packages

Below is a list of R packages required to run the application. Using the run_app.R script to launch the application should download any needed packages however if you are having trouble it is recommended to do it manually.

```R
  library(shiny) #Used to make the interactive app
  library(shinythemes) #Used to add ui themes
  library(shinyjs) #Used for javascript additions
  library(shinyFiles) #Saving files
  library(DT) #interactive data tables
  library(htmlwidgets) #additional html items and features
  library(devtools) #Used for installing github packages
  
  # For data
  library(dplyr) #Data wrangling 
  library(tidyr) #Data wrangling 
  library(readr) #reading and writing files
  library(DESeq2) #Used for Differential Gene Expression
  library(SummarizedExperiment) #Used for Differential Gene Expression
  devtools::install_github("Lmilazzo/BioVis")
  library(BioVis) #My R package from github with plotting functions (Only used in Version 1.0.0)
  library(pathfindR) #Used for Pathway Enrichment 
  
  # For plotting
  library(ggplot2) #Visualizations
  library(ggplotify)#Visualizations
  library(pheatmap)#Visualizations
  library(ggbeeswarm)#Visualizations
  library(ggrepel)#Visualizations
  library(plotly)#Visualizations
  library(grid)#Visualizations
  
  # Additional
  library(zip) #Downloading your saved session files to your local file system.
```


---
