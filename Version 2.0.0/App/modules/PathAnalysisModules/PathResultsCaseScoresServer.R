PathResultsCaseScoresServer <- function(id, Data){
  moduleServer(id, function(input, output, session){
    
    ns <- session$ns
    
    plot <- reactiveVal(NULL)
    
    #Pathway Analysis Results
    # Data <- list(
    #   "MetaData" = RCV.MetaData,
    #   "NormCounts" = RCV.Norm,
    #   "GeneNames" = RCV.Norm,
    #   "Results" = RCV.Results,
    #   
    #     # [1] "ID"                   "Term_Description"    
    # [3] "Fold_Enrichment"      "occurrence"          
    # [5] "support"              "lowest_p"            
    # [7] "highest_p"            "non_Signif_Snw_Genes"
    # [9] "Up_regulated"         "Down_regulated"      
    # [11] "all_pathway_genes"    "num_genes_in_path"   
    # [13] "Cluster"              "Status"    
    #   
    #   
    #   
    #   "status" = status
    # )
    # 
   
    
    Search <- debounce(reactive(input$PathWayGeneListingSearch), 750)
    pList <- debounce(reactive(ifelse(is.null(input$pList), "", PivotListba(input$pList))), 750)
    pSlider <- debounce(reactive(input$pSlider), 750)
    Title <- debounce(reactive(input$Title), 750)
    Subtitle <- debounce(reactive(input$Subtitle), 750)
    Caption <- debounce(reactive(input$Caption), 750)
    CaseTitle <- debounce(reactive(input$CaseTitle), 750)
    ControlTitle <- debounce(reactive(input$ControlTitle), 750)

    #Meta Data selection                
    output$Meta <- renderUI({
      
      checkboxGroupInput(
        ns("MetaData"),
        NULL,
        choices = rownames(Data$MetaData())
      )
      
    })
    
    #Gene inclusion method
    output$InclusionMethod <- renderUI({
      
      if(input$InclusionMethod == "All"){
        return()
      }
      else if(input$InclusionMethod == "List"){
        div(
          textAreaInput(ns("pList"), label = NULL, width = "90%")
        )
      }
      else if(input$InclusionMethod == "Slider"){
        div(
          shinyWidgets::noUiSliderInput(
            ns("pSlider"), max = 1, min = 0.01, value = 0.35, label = NULL, width = "90%", color = "#ff6f61"
          ),
          style = "margin-right: 3px;"
        )
      }
      
    })
    
    #Plot
    output$plot <- renderPlot({
      
      #Filtering Data
      if(input$InclusionMethod == "List"){
        
        ref <- unlist(pList())

        data <- Data$Results() %>% 
          filter(tolower(Term_Description) %in% tolower(ref))
        
      }
      if(input$InclusionMethod == "Slider"){
        
        if(!is.numeric(pSlider())){
          return()
        }
        
        data <- Data$Results() %>%
          head(n = round(nrow(Data$Results()) * pSlider()) )
        
        #print(nrow(data))
        
      }
      if(input$InclusionMethod == "All"){
        data <- Data$Results()
        #print(head(Data$Results()$Term_Description))
      }
      
      #   SET UP CASE VS CONTROL PARAM
      #____________________________________
      if(is.null(input$MetaData)){
        caseSamples <- NULL
      } else {
        caseSamples <- input$MetaData
      }
      
      if(nrow(data) < 1){return()}

      # h <- score_terms(
      #   enrichment_table = data,
      #   exp_mat = as.matrix(Data$NormCounts()),
      #   cases = as.vector(caseSamples),
      #   use_description = TRUE, # default FALSE
      #   label_samples = TRUE, # default = TRUE,
      #   plot_hmap = FALSE
      # )

      h <- plotWrapper(
        data = data,
        abundance = Data$NormCounts(),
        cases = caseSamples,
        repOnly = FALSE,
        pathways = NULL,
        case_title = ifelse(length(CaseTitle()) > 0, CaseTitle(), "Case"),
        control_title = ControlTitle()
      ) + 
        theme(
          panel.background = element_rect("white"),
          text = element_text(color = "black", size = input$Font),
          legend.text = element_text(color = "black", size = input$Font),
          legend.title = element_text(color = "black", size = input$Font + 1),
          strip.text.x = element_text(color = "black", size = input$Font + 1),
          plot.title = element_text(size = input$Font + 5, color = "black", margin=margin(20,20,5,10,"pt"), hjust = 0.5),
          plot.subtitle = element_text(size = input$Font + 2, color = "black", margin=margin(5,5,15,10,"pt"), hjust = 0.5),
          plot.caption = element_text(size = input$Font - 2, color = "black", margin=margin(10, 10, 10, 10, "pt"))
        ) + 
        labs(
          title = Title(),
          subtitle = Subtitle(),
          caption = Caption(),
        )
      
      plot(h)
      
      plot()

      
    },
      width = function() {ifelse(is.na(input$W), 1000, input$W)},
      height = function() {ifelse(is.na(input$H), 750, input$H)}
    )
    
    #look up table
    output$Lookup <- renderDT({
      
      df <- Data$Results() %>%
        select(Term_Description)
      
      colnames(df) <- "Pathways"
      
      datatable(
        df, rownames = FALSE, 
        options = list(
          pagelength = 15, dom = "ftp", pagingType = "simple",
          language = list(
            search = ""
          )
        )
      )
      
    })
    
    #Wrapper for pathfindR plotting functions adds custom filtering and naming conventions
    plotWrapper <- function(data = NULL, abundance = NULL, cases = NULL, repOnly = TRUE,
        pathways = NULL, case_title = "case", control_title = "control"
      ){
        
        if(is.null(data)){
          stop('No data was passed')
        }
        
        if(is.null(abundance)){
          stop('No abundance data')
        }
        
        rownames(abundance) <- abundance$Gene_symbol
        abundance <- abundance %>% select(-Gene_symbol)
        abundance <- as.matrix(abundance)
        
        if(!is.numeric(abundance)){
          stop('non numeric value found in abundance data matrix')
        }
        
        #_________________________________________________________________________#
        
        #filter if
        if(repOnly == TRUE){
          data <- data %>% filter(Status == 'Representative')
        }
        
        #Make scores
        scores <- score_terms(
          enrichment_table = data,
          exp_mat = abundance,
          cases=cases,
          use_description = TRUE, # default FALSE
          label_samples = TRUE, # default = TRUE,
          plot_hmap = FALSE
        )
        #make plot
        plot <- plot_scores(
          score_matrix = scores,
          label_samples = TRUE, # default = TRUE
          cases=cases,
          low = "#f7797d", # default = "green"
          mid = "#fffde4", # default = "black"
          high = "#1f4037" # default = "red"
        )
        
        plot$facet$params$labeller <- labeller(
          Type = as_labeller(
            c(
              Case = ifelse(case_title == "", "Case", case_title),
              Control = ifelse(control_title == "", "Control", control_title)
            )
          )
        )
        
        return(plot)  
      
    }
    
    #______________________________________SAVING____________________________________
    observeEvent(input$SavePlot,{
      
      showModal(modalDialog(
        title = "Enter File Name",  # Title of the modal
        textInput(ns("fileName"), "File Name:", value = ""),  # Text input for the file name
        radioButtons(ns("extension"), label = "File Extension", choices = c(".jpeg", ".png"), selected = ".png", inline = TRUE, width = "100%"),
        footer = tagList(
          modalButton("Cancel"),  # Cancel button to close the modal
          actionButton(ns("saveFile"), "Save")  # Save button to handle the file name
        )
      ))
      
    })
    observeEvent(input$saveFile, {
      removeModal()
      saveFile(plot, input$fileName, input$extension, input$W, input$H)
    })
    
  })
}