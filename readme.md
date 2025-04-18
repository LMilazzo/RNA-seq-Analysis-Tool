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

# File Usage Documentation

## Basic File Rules

- Headers are case sensitive.
- All files should be CSV or TSV format.
- All listed required columns must be present for the file to be accepted.
- Any ID-type columns must not have duplicate values.
- All sample columns must include a header that starts with a `.` character to be identified by the application.

## File Type Summaries and Examples

### 1. Metadata File

Maps each sample to a row of variables that describe the sample.

#### Required Columns:

- `sample`: Contains the sample names, which should match the sample names in other uploaded files. (The application automatically prepends a `.` to sample names if missing.)

#### Example:

| sample  | condition |
| ------- | --------- |
| .sample1 | treatment |
| .sample2 | control   |
| .sample3 | treatment |

---

### 2. Raw Count Table

A matrix of counts representing the number of times each gene occurred within each sample.

#### Required Columns:

- `gene_id`: Unique identifier for each gene.
- `gene_name`: Name of the gene (recommended to represent actual genes).
- Sample columns: Contain raw count data.

#### Example:

| gene_id | gene_name | .sample1 | .sample2 | .sample3 |
| ------- | --------- | -------- | -------- | -------- |
| G1      | NME1     | 100      | 200      | 150      |
| G2      | AK1      | 50       | 75       | 60       |
| G3      | AK6      | 400      | 410      | 420      |

---

### 3. Differential Expression Analysis Results Output

Not all the columns that are returned from DESeq2 are required to use this file. DESeq2 does not append the sample counts to the results, rather this must be done manually before uploading with the DESeq results and the normalized counts matrix given by DESeq2.

#### Required Columns:

- `gene_id`: Unique identifier for each gene.
- `gene_name`: Name of the gene.
- `log2FoldChange`: Log2 fold change value.
- `padj`: Adjusted p-value.

#### Example:

| gene_id | gene_name | log2FoldChange | padj | .sample1 | .sample2 |
| ------- | --------- | -------------- | ---- | -------- | -------- |
| G13     | DCK      | -1.2           | 0.05 | 120      | 100      |
| G65     | ADSS2    | 2.3            | 0.01 | 210      | 230      |
| G4      | ADSL     | 1.8            | 0.003| 400      | 450      |

---

### 4. Abundance Data File

A matrix of normalized counts for each gene and sample to be used in the pathway analysis portion of the application. The normalized counts can be retrieved from a DESeq2 experiment and modified to the required format.

#### Required Columns:

- `gene_name`: Name of the gene (must represent actual genes).
- Sample columns: Contain normalized count data.

#### Example:

| gene_name | .sample1 | .sample2 | .sample3 |
| --------- | -------- | -------- | -------- |
| ENPP3     | 1.2      | 1.1      | 1.3      |
| APRT      | 1.6      | 1.5      | 1.4      |
| RRM2      | 2.1      | 2.2      | 2.0      |

---

### 5. Previous Pathway Analysis Results Output

The output/results from a previous `pathfindR` pathway analysis experiment. The results must include a clustered column, as `pathfindR` clusters pathways automatically.

#### Required Columns:

- `ID`: Unique identifier for each pathway.
- `Term_Description`: Name of the pathway.
- `Fold_Enrichment`: Fold enrichment value.
- `occurrence`: Integer representing the number of occurrences of the pathway.
- `support`: Float value representing the pathway's support.
- `lowest_p`: Lowest p-value in the pathway.
- `highest_p`: Highest p-value in the pathway.
- `non_Signif_Snw_Genes`: Comma-separated list of non-significant genes in the pathway.
- `Up_regulated`: Comma-separated list of upregulated genes.
- `Down_regulated`: Comma-separated list of downregulated genes.
- `all_pathway_genes`: Comma-separated list of all genes in the pathway.
- `num_genes_in_path`: Number of genes in the pathway.
- `Cluster`: Cluster ID (integer).
- `Status`: Either `Representative` or `Member`.

#### Example:

| ID  | Term_Description  | Fold_Enrichment | occurrence | support | lowest_p | highest_p | Cluster | Status      | non_Signif_Snw_Genes | Up_regulated  | Down_regulated  | all_pathway_genes             | num_genes_in_path |
| --- | ---------------- | --------------- | ---------- | ------- | -------- | --------- | ------- | ----------- | --------------------- | ------------- | --------------- | ----------------------------- | ------------------ |
| P01 | Prion Disease     | 2.5             | 5          | 0.8     | 0.0001   | 0.1       | 1       | Representative | GMPS, CMPK1           | TK1, DUT      | TYMS, CTPS1     | GMPS, CMPK1, TK1, DUT, TYMS, CTPS1 | 6                  |
| P02 | Huntington Disease| 1.8             | 3          | 0.5     | 0.00003  | 0.02      | 2       | Member        | UCK2, NT5C3B          | HPRT1, IMPDH2 | UCK2, NT5C3B, HPRT1, IMPDH2 | 4                  |

---

## When to Use Each File

The application can be experienced in its entirety with the use of just the two following files: **Metadata** and **Raw Counts Table**.

1. **Metadata** files are required with any use of the application.
2. **Raw Count Table** is used when a new Differential Gene Expression Analysis needs to be done. The application can then directly run the results into the pathway analysis portion of the application.

The next three files are useful if an experiment has already been done outside of the application with DESeq2 or pathfindR and the user just wants access to the visuals the application provides. This allows more flexibility if the user wishes to do advanced experimental designs, formulas, or custom filtering of the results, which are not accessible within the application. The downside, however, is that some features may become unavailable due to missing information.

3. **Differential Expression Analysis Results Output** is used in conjunction with a **Metadata** file to skip the process of running DESeq2 and to just visualize results that have already been acquired. After uploading these two files, you may also directly pass them into the pathway analysis portion of the application without uploading anything else.
4. **Abundance Data** and **Pathway Analysis Results Output** may be used in conjunction with **Metadata** to bypass the rest of the application and just visualize and explore previously acquired results from a pathway analysis. An abundance data file is not required to use this method; however, some features may not be available without it.


# Saving Files Documentation

All main plots shown in the application can be saved as a PDF file.

### How to Save a File

- Click the green **Save Plot** or **Save Results** button found on the page this will save the currently displayed plot on that page, or in the case of save Results will save the  unfiltered output or Diffrential Gene Expression or Pathway Enrichment Analysis displayed in the corresponding table. 
- You will be prompted to enter a name for the file.
- After inputting the name and closing the pop-up, the file will be stored in a background directory.
- **This directory is cleared upon closing the application & you will lose any files that you saved unless you complete the following download step**

### Downloading Saved Files

- Locate the **“Download Saved Files”** button at the top right of any page.
- Clicking this button will download a zipped directory containing all saved plots or results from your session. A default name of "SessionDownload*Date Time*" will be provided for the directory. 
