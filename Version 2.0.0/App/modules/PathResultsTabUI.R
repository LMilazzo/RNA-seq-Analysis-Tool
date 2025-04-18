pathResultsTab <- function(id){
  
  ns <- NS(id)
  
  fluidPage(
    
    tabsetPanel(
      
      
      # Results / Summary TabPanel
      tabPanel(
       title = "Results / Summary",
       PathResultsSummaryUI(ns("Results-Summary"))
      ),
      
      tabPanel(
        title = "Gene Expression Heatmap",
        PathResultsPathMapUI(ns("Results-PathMap"))
      )
    
    )
  )
  
}