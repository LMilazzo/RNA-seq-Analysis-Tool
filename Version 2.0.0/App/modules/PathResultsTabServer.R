PathResultsServer <- function(id, Data, DiffData){
  moduleServer(id, function(input, output, session){
    
    ns <- session$ns
    
    #Pathway Enrichment Uploads Data
    # PathUploads <- list(
    #   "MetaData" = RCV.MetaData,
    #   "NormCounts" = RCV.Norm,
    #   "GeneNames" = RCV.Norm,
    #   "PrevResults" = RCV.Results,
    #   "status" = status
    # )
    #Differential Gene Expression Preview Data ( returns the calculated results)
    # DiffData <- list(
    #    "contrasts" = list, can be null
    #    "ddsc" = Reactive, can be null
    #    "Results" = Reactive
    #    "vstObject" = Reactive
    #    "vstCounts" = Reactive
    #    "NormCounts" = Reactive
    #    "status" = Reactive 0, 1
    # )
    
    PathResultsSummaryServer("Results-Summary", Data)
    PathResultsPathMapServer("Results-PathMap", Data, DiffData)
    
  })
}