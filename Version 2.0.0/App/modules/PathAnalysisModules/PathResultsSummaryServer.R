PathResultsSummaryServer <- function(id, Data){
  moduleServer(id, function(input, output, session){
    
    ns <- session$ns
    
    #Pathway Enrichment Uploads Data
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
    
    #Pvalue Table stats
    output$PvalStats <- renderDT({
      
      if(is.null(Data$Results())  || nrow(Data$Results()) < 1){return()}
      
      stats <- Data$Results() %>% na.exclude() %>%
        filter(lowest_p <= input$Pval) %>%
        summarize(
          "Max" = max(lowest_p),
          "Mean" = mean(lowest_p),
          "Min" = min(lowest_p)
        ) %>% t()
      
      stats2 <- Data$Results() %>% na.exclude() %>%
        filter(lowest_p <= input$Pval) %>%
        summarize(
          "Max" = max(highest_p),
          "Mean" = mean(highest_p),
          "Min" = min(highest_p)
        ) %>% t()
      
      stats <- cbind("Min P" = stats, "Max P" = stats2)
      
      datatable(
        format(stats, scientific = TRUE), 
        colnames = c("Lowest", "Highest"),
        options = list(
          dom = "t"
        )
      )
      
    })
    
    #Pval Histogram
    output$PvalHisto <- renderPlot({
      
      if(is.null(Data$Results()) || nrow(Data$Results()) < 1){return()}
      
      ggplot(Data$Results() %>% filter(lowest_p <= input$Pval)) +
        geom_histogram(aes(pmin(highest_p, 0.5)), bins = 10, fill = 'red', alpha = 0.2) +
        geom_histogram(aes(pmin(lowest_p, 0.5)), bins = 10, fill = '#677780') +
        theme_minimal() +
        theme(
          axis.text.x = element_text(color = 'black', size = 16),
          axis.text.y = element_blank(),
          axis.title = element_text(color = 'black', size = 17),
          panel.grid.major = element_line(color = 'grey25'),
          panel.grid.minor = element_blank(),
          plot.margin = margin(5,5,5,5,"pt")
        ) +
        labs(x = "P-value", y = "Count") +
        scale_x_continuous(breaks = c(0, 0.1, 0.5),
                           labels = c("0", "0.1", "> 0.5"))
      
    })
    
    #Fold Change Stats
    output$FoldStats <- renderDT({
      
      if(is.null(Data$Results()) || nrow(Data$Results()) < 1){return()}
      
      stats <- Data$Results() %>% na.exclude() %>%
        filter(lowest_p <= input$Pval) %>%
        summarize(
          "Max" = max(Fold_Enrichment),
          "Mean" = mean(Fold_Enrichment),
          "Min" = min(Fold_Enrichment)
        )
      
      datatable(
        t(stats), 
        colnames = c("Fold Enrichment"),
        options = list(
          dom = "t"
        )
      )
      
    })
    
    #Fold Change Histogram
    output$FoldHisto <- renderPlot({
      
      if(is.null(Data$Results()) || nrow(Data$Results()) < 1){return()}
      
      ggplot(Data$Results() %>% filter(lowest_p <= input$Pval), aes(pmax(pmin(Fold_Enrichment, 5), -5))) + 
        geom_histogram(bins = 12, fill = '#677780') + 
        theme_minimal() + 
        theme(
          axis.text.x = element_text(color = 'black', size = 16),
          axis.text.y = element_blank(),
          axis.title = element_text(color = 'black', size = 17),
          panel.grid.major = element_line(color = 'grey25'),
          panel.grid.minor = element_blank(),
          plot.margin = margin(5,5,5,5,"pt")
        ) +
        labs(x = "Fold Enrichment", y = "Count") +
        scale_x_continuous(breaks = c(-5, -1, 0, 1, 5), labels = c( "< -5", "-1", "0", "1", "> 5"))
      
    })
    
    #Main data table
    output$Res <- renderDT({
     
      datatable(
        Data$Results() %>%
          filter(lowest_p <= input$Pval) %>%
          select(
            ID, "Pathway" = Term_Description, 
            "Fold Enrich." = Fold_Enrichment,
            "Lowest P" = lowest_p, "Highest P" = highest_p,
            "# of Genes" = num_genes_in_path,
            Cluster,
            Status
          ),
        rownames = FALSE, 
        options = list(pageLength = 12)
      )
      
    })
    
    Search <- debounce(reactive(input$PathWayGeneListingSearch), 750)
    
    output$PathwayGeneListing <- renderUI({
      
      s <- Data$Results() %>% 
        filter( tolower(Term_Description) == tolower(Search())) 
      
      if(nrow(s) < 1){return()}
      
      Up <-  PivotList(s$Up_regulated)
      Down <-  PivotList(s$Down_regulated)
      All <-  PivotList(s$all_pathway_genes)
      All <- setdiff(All, c(Up, Down))
      
      fluidRow(
        
        column( width = 3,
          h4("Up Regulated"),
          div(
            tags$ul(
              HTML(paste("<li>", Up[[1]], "</li>", collapse = ""))
            ),
            style = "columns: 2; padding: 0px;"
          ),
          style = "border: 2.5px solid #bb0c00; padding: 10px; overflow: auto;text-align: center; margin-right: 5px;
          padding: 3px; border-radius: 15px;"
        ),
        
        column( width = 6,
          h4("Other Genes"),
          div(
            tags$ul(
              HTML(paste("<li>", All[[1]], "</li>", collapse = ""))
            ),
            style = "columns: 3; padding: 0px;"
          ),
          style = "border: 1.5px solid white; padding: 10px; overflow: auto;  text-align: center; margin-right: 5px;
          padding: 3px; border-radius: 15px;"
        ),
        
        column( width = 3,
          h4("Down Regulated"),
          div(
            tags$ul(
              HTML(paste("<li>", Down[[1]], "</li>", collapse = ""))
            ),
            style = "columns: 2; padding: 0px;"
          ),
          style = "border: 1.5px solid #2171b5; padding: 10px; overflow: auto; text-align: center;
          padding: 3px; border-radius: 15px;"
        ),
        style = "overflow: auto; width: 94%; display: flex; margin-right: 3%; margin-left: 3%;"
      )
      
      
    })
    
    
    
    
    #______________________________________SAVING____________________________________
    observeEvent(input$SaveTable,{
      
      showModal(modalDialog(
        title = "Enter File Name",  # Title of the modal
        textInput(ns("fileName"), "File Name:", value = ""),  # Text input for the file name
        radioButtons(ns("textension"), label = "Extension", choices = c(".csv", ".tsv"), selected = ".csv", inline = TRUE, width = "100%"),
        footer = tagList(
          modalButton("Cancel"),  # Cancel button to close the modal
          actionButton(ns("saveTable"), "Save")  # Save button to handle the file name
        )
      ))
      
    })
    observeEvent(input$saveTable, {
      removeModal()
      saveTable(Data$Results, input$fileName, input$textension)
    })
    
    
    
  })
}