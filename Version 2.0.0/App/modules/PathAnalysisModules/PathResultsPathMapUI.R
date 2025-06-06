PathResultsPathMapUI <- function(id){
  
  ns <- NS(id)
  
  
  fluidPage(
    
    br(),
    
    sidebarPanel(
      width = 3,
      tabsetPanel(
        
        #----
        #   DATA    #TO-DO
        #----    
        tabPanel(
          "Data",
          div(id = ns("searching"),
            #Search for the pathway
            div(id = "Search1",
                h4("Search for Pathway: ", style = "margin-right: 15px; padding-bottom: 12px"),
                textInput(ns("PathWayGeneListingSearch"), label = NULL, value = "", width = "90%"), 
                style = "align-items: center; justify-content: center; "
            ),
            style = "border: 2.5px solid #272b30; border-radius: 15px; padding-left: 5px; margin-top: 5px; overflow: auto;"
          ),
          div(id = ns("searching2"),
              #Search for the pathway
              div(id = "Search1",
                  p("Gene Inclusion Method: ", style = "margin-right: 15px; padding-bottom: 12px"),
                  selectInput(ns("InclusionMethod"), label = NULL, choices = c("All", "List", "Slider"), selected = "Slider", 
                              width = "75%"),
                  style = "align-items: center; justify-content: center;"
              ),
              div(id = "Inclusions",
                  uiOutput(ns("InclusionMethod")),
                  style = ""
              ),
              style = "border: 2px solid #272b30; border-radius: 15px; padding-left: 5px; margin-top: 5px; font-size: 17px;"
          ),
          div(id = ns("Data-Stuff"),
              #Meta Data to show----
              div(class = "collapsible-container",
                  tags$details(
                    tags$summary(
                      p("Annotations", style = "margin-right: 5%; padding-bottom: 2%"),
                    ),
                    tags$div(class = "content", uiOutput(ns("Meta")))
                  ),
                  style = "padding-right: 5px; margin-top: 10px;"
              ),
              style = "border: 2px solid #272b30; border-radius: 15px; padding-left: 5px; margin-top: 5px; overflow: auto;"
          ),
          div(id = ns("Clust-Stuff"),
              #Cluster
              p("Euclidean Dendrograms: ", style = "margin-right: 15px; padding-bottom: 12px"),
              div(id="Dendrograms",
                  checkboxInput(ns("ClusterRows"), "Row", value = TRUE),
                  checkboxInput(ns("ClusterCols"), "Column", value = TRUE),
                  style = "font-size: 17px; display: flex; justify-content: space-evenly; align-items: center; width: 100%;"
              ),  
              div(id="NumDisplay",
                  p("Display Values: ", style = "margin-right: 15px; padding-bottom: 12px"),
                  checkboxInput(ns("NumDisplay"), "", value = FALSE),
                  style = "font-size: 17px; display: inline-flex; align-text: center; justify-content: center; align-items: center; overflow: auto;"
              ),  
              style = "border: 2px solid #272b30; border-radius: 15px; padding-left: 5px; margin-top: 5px; overflow: auto; font-size: 17px;"
          ),
          savePlotButton(id),
          style = "overflow: auto;"
        ),
        #----
        #   SETTINGS ----
        tabPanel(
          "Settings", 
          div(id = ns("Text-Stuff"),
              #Plot Title----
              div(
                p("Plot Title:", style = "margin-right: 5%; padding-bottom: 2%"),
                textInput(ns("Title"), label =  NULL, value = "", width = "50%"),
                style = "margin-top: 10px; margin-bottom: 5px; display: inline-flex; font-size: 17px; align-items: center;"
              ),
              #Subtitle----
              div(
                p("Sub Title:", style = "margin-right: 5%; padding-bottom: 2%"),
                textInput(ns("Subtitle"), label = NULL, value = "", width = "50%"),
                style = "margin-top: 10px; margin-bottom: 5px; display: inline-flex; font-size: 17px; align-items: center;"
              ),
              #Caption----                   
              div(
                p("Caption:", style = "margin-right: 5%; padding-bottom: 2%"),
                textInput(ns("Caption"), label = NULL, value = "", width = "50%"),
                style = "margin-top: 10px; margin-bottom: 5px; display: inline-flex; font-size: 17px; align-items: center;"
              ),
              #text size----           
              div(
                p("Font:", style = "margin-right: 5%; padding-bottom: 2%"),
                numericInput(ns("Font"), max = 32, min = 4, value = 18, label = NULL, width = "30%"),
                style = "margin-top: 10px; margin-bottom: 5px; display: inline-flex; font-size: 17px; align-items: center;
            width: 100%;"
              ),
              style = "border: 2px solid #272b30; border-radius: 15px; padding-left: 5px; margin-top: 5px;"
          ),
          #NOT USED YET
          # div(id=ns("Theme-Stuff"),
          #   style = "border: 2px solid #272b30; border-radius: 15px; padding-left: 5px; margin-top: 5px;"
          # ),
          div(id=ns("Size-Stuff"),
              # #Aspect Ratio (DETERMINED BY CELL SIZINGS---- 
              # div(
              #   p("Aspect Ratio:", style = "margin-right: 5%; padding-bottom: 2%"),
              #   selectInput(
              #     ns("Aspect"),label = NULL,
              #     choices = c("4:3" = 4/3, "3:4" = 3/4, "16:9" = 16/9, "9:16" = 9/16, "1:1" = 1), 
              #     selected = c(3/4), width = "100%"
              #   ),
              #   style = "margin-top: 10px; margin-bottom: 5px; display: inline-flex; font-size: 17px; align-items: center;"
              # ),
              #width----
              div(
                p("Width:", style = "margin-right: 5%; padding-bottom: 2%"),
                numericInput(ns("W"), max = 4280, min = 0, value = 750, label = NULL, width = "50%"),
                style = "margin-top: 10px; margin-bottom: 5px; display: inline-flex; font-size: 17px; align-items: center; width: 100%;"
              ),
              #height----
              div(
                p("Height:", style = "margin-right: 5%; padding-bottom: 2%"),
                numericInput(ns("H"), max = 4280, min = 0, value = 750, label = NULL, width = "50%"),
                style = "margin-top: 10px; margin-bottom: 5px; display: inline-flex; font-size: 17px; align-items: center; width: 100%;"
              ),
              #Cell-width----
              div(
                p("Cell Width:", style = "margin-right: 5%; padding-bottom: 2%"),
                numericInput(ns("cW"), max = 4280, min = 0, value = 40, label = NULL, width = "50%"),
                style = "margin-top: 10px; margin-bottom: 5px; display: inline-flex; font-size: 17px; align-items: center; width: 100%;"
              ),
              #Cell-height----
              div(
                p("Cell Height:", style = "margin-right: 5%; padding-bottom: 2%"),
                numericInput(ns("cH"), max = 4280, min = 0, value = 17, label = NULL, width = "50%"),
                style = "margin-top: 10px; margin-bottom: 5px; display: inline-flex; font-size: 17px; align-items: center; width: 100%;"
              ),
              style = "border: 2px solid #272b30; border-radius: 15px; padding-left: 5px; margin-top: 5px;"
          ),
          style = "overflow: auto;"
        ),
        tabPanel(
          "Term List",
          #Lookup table
          div(  
            DTOutput(ns("Lookup"), width = "100%"),
            style = "display: flex; justify-content: center; align-items: center; text-align: center; overflow: auto; margin-top: 10px;",
            tags$style(HTML(".dataTables_filter input {width: 70% !important;}"))
          )
        ),
        tabPanel(
          "Genes",
          #Lookup table
          div(  
            DTOutput(ns("Lookup2"), width = "100%"),
            style = "display: flex; justify-content: center; align-items: center; text-align: center; overflow: auto; margin-top: 10px;",
            tags$style(HTML(".dataTables_filter input {width: 70% !important;}"))
          )
        )
      )
    ),
    
    mainPanel(
      width = 9,
      
      div(
        withSpinner(
          plotOutput(ns("plot")),
          type = 6
        )
      )
      
    )
    
  )
  
  
}