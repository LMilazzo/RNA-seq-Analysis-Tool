PathResultsSummaryUI <- function(id){
  
  ns <- NS(id)
  
  
  fluidPage(
  
    sidebarPanel(
      width = 3,
      saveTableButton(id),
      #CHANGE PVAL
      div(
        p("P-value: ", style = "margin-bottom: 18px; font-size: 18px;"),
        selectInput(ns("Pval"), label = NULL, 
                    choices = c("0.5", "0.1", "0.05", "0.01", "0.005", "0.001", "Ignore"),
                    selected = "Ignore",
                    width = "50%"
        ),
        style = "display: flex; align-items: center; gap: 5%; width: 100%; border: 2px solid #272b30; border-radius: 15px; 
        padding-left: 5px; padding-right: 5px; margin-top: 10px; padding-top: 5px;"
      ),
      
      #PVAL STATS
      div(
        div(
          DTOutput(ns("PvalStats")), #DT
          style = "width: 90%; text-align: center; font-size: 16px; overflow: auto;"
        ),
  
        div(
          plotOutput(ns("PvalHisto"), height = "100%", width = "90%"), #HISTOGRAM
          style = "max-height: 300px; height: 300px; margin-top: 15px; overflow: auto;"
        ),
        style = "border: 2px solid #272b30; border-radius: 15px; padding-left: 5px; padding-right: 5px;
        padding-top: 15px; margin-top: 10px;"
      ),
      #FOLD CHANGE STATS
      div(
        div(
          p("Fold Change: ", style = "margin-bottom: 18px; margin-top: 16px; font-size: 18px; text-align: left;"),
          DTOutput(ns("FoldStats")), #DT
          style = "width: 90%; text-align: center; font-size: 16px; overflow: auto;"
        ),
  
        div(
          plotOutput(ns("FoldHisto"), height = "100%", width = "90%"), #HISTOGRAM
          style = "max-height: 300px; height: 300px; margin-top: 15px; overflow: auto;"
        ),
        style = "border: 2px solid #272b30; border-radius: 15px; padding-left: 5px; padding-right: 5px;
        padding-top: 15px; margin-top: 10px;"
      )
    ),
    
    mainPanel(
      width = 9,
      div(
        DTOutput(ns("Res"))
      ),
      
      div(
        h4("Gene Listing / All Genes in a Pathway"),
        div(textInput(ns("PathWayGeneListingSearch"), "", width = "25%"), style = "align-items: center; justify-content: center; display: flex;"),
        uiOutput(ns("PathwayGeneListing")),
        style = "border: 2px solid black; padding: 5px; padding-bottom: 15px;
              background: #131517; border-radius: 15px; text-align: center;
              align-items: center; justify-content: center;"
      ) 
    ),
    
    style = "margin-top: 10px;"
  )
  
}