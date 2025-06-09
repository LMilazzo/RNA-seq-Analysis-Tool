
server <- function(input, output, session){
  
  #Reload Application Logic
  observeEvent(input$ReloadApp, {runjs("location.reload();")})

  
  #       APPLICATION STAGE 1 RAT DEG
  #________________________________________________
  
  
  #Differential Gene Expression Uploads Data
  # DiffUploads <- list(
  #   "RawCounts" = Reactive,
  #   "GeneNames" = Reactive,
  #   "MetaData" = Reactive,
  #   "PrevResults" = Reactive list,
  #   "status" = Reactive 0, 1, 2
  # )
  #~~~~~~~~~~~~~~~
  DiffUploads <- DiffUploadsServer("Diff-Uploads")
  
  #Differential Gene Expression Preview Data ( returns the calculated results)
  # DiffResults <- list(
  #    "contrasts" = list, can be null
  #    "ddsc" = Reactive, can be null
  #    "Results" = Reactive
  #    "vstObject" = Reactive
  #    "vstCounts" = Reactive
  #    "NormCounts" = Reactive
  #    "status" = Reactive 0, 1
  # )
  #~~~~~~~~~~~~~~~
  DiffResults <- DiffIntermediateServer("Diff-Intermediate", 
    DiffUploads #Data from the uploaded files to be run through DESeq2
  )
  
  #The UI Elements that make up a bulk of the analysis and app
  DiffResultsServer("Diff-Results", 
    DiffResults, #Results of DESeq2 or the uploaded files
    DiffUploads #Data from the uploaded files used for things like gene names and if the raw data is needed
  )
  
  #Validate Diff Display For Current Status
  observe({
    invalidateLater(500)

    #Case when there is any data at all
    if(DiffUploads$status() != 0 ){
      shinyjs::hide("Diff-Uploads")
    }
    
    #Case when data has been uploaded but deseq not run
    if(DiffUploads$status() == 1 && DiffResults$status() == 0){
      shinyjs::show("Diff-Intermediate")
    }
    
    #Case when there is results data 
    if(DiffUploads$status() > 0 && DiffResults$status() > 0){
      shinyjs::hide("Diff-Intermediate")
      shinyjs::show("Diff-Results")
    }
    
    
  })
  
  
  #       APPLICATION STAGE 2 RAT PATHS
  #________________________________________________
  
  #Pathway Enrichment Uploads Data
  # PathUploads <- list(
  #   "MetaData" = RCV.MetaData,
  #   "NormCounts" = RCV.Norm,
  #   "GeneNames" = RCV.Norm,
  #   "PrevResults" = RCV.Results,
  #   "status" = status
  # )
  PathUploads <- PathUploadsServer("Path-Uploads", DiffResults, DiffUploads)
  
  PathResultsServer("Path-Results",
    PathUploads,
    DiffResults
  )
  
  observe({
    invalidateLater(500)
    #Case when there is any data
    if(PathUploads$status() != 0){
      shinyjs::hide("Path-Uploads")
      shinyjs::show("Path-Results")
    }

  })
  
  #       DOWNLOADING SAVED FILES
  #________________________________________________
  output$downloadZip <- downloadHandler(
    filename = function() {
      
      paste0("SessionDownload_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".zip")

    },
    content = function(file) {
      
      files <- list.files("SavedFiles", full.names = TRUE)
      
      return(zip(zipfile = file, files = files))
      
    },
    contentType = "application/zip"
  )
  
  #Unlink temp directory on session end
  session$onSessionEnded(function() {
    # List all files in the directory
    files <- list.files("SavedFiles", full.names = TRUE)
    
    # Remove all files in the directory
    unlink(files, recursive = TRUE, force = TRUE)
    #print("unlinked temp dir")
    #
  })
  
  
  
  
}