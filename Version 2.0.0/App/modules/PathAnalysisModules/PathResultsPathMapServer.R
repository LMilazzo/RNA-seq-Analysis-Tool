PathResultsPathMapServer <- function(id, Data, DiffData){
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
    #   #Differential Gene Expression Preview Data ( returns the calculated results)
    # DiffData <- list(
    #    "contrasts" = list, can be null
    #    "ddsc" = Reactive, can be null
    #    "Results" = Reactive
    #    "vstObject" = Reactive
    #    "vstCounts" = Reactive
    #    "NormCounts" = Reactive
    #    "status" = Reactive 0, 1
    # )
    
    Search <- debounce(reactive(input$PathWayGeneListingSearch), 750)
    gList <- debounce(reactive(ifelse(is.null(input$gList), "", PivotList(input$gList))), 750)
    gSlider <- debounce(reactive(input$gSlider), 750)
    Title <- debounce(reactive(input$Title), 750)
    Subtitle <- debounce(reactive(input$Subtitle), 750)
    Caption <- debounce(reactive(input$Caption), 750)
    
    #Annotations 
    Annotations <- reactiveVal(NULL)
    Colors <- reactiveVal(NULL)
    
    #Update annotations
    observeEvent(input$MetaData,{
      
      if(is.null(input$MetaData)){
        Annotations(NULL)
        Colors(NULL)
        return()
      }
      
      a <- Data$MetaData() %>% select(input$MetaData)
      Annotations(a)
      
      i <- 1
      
      colors <- list()
      for(ann in colnames(a)){
        colors[[ann]] <- gen_color_pallette(a %>% select(ann), i)
        i <- i + 1
      }
      Colors(colors)
      
    }, ignoreNULL = FALSE )
    
    #Meta Data selection                
    output$Meta <- renderUI({
      
      checkboxGroupInput(
        ns("MetaData"),
        NULL,
        choices = colnames(Data$MetaData())
      )
      
    })
    
    #Gene inclusion method
    output$InclusionMethod <- renderUI({
      
      if(input$InclusionMethod == "All"){
        return()
      }
      else if(input$InclusionMethod == "List"){
        div(
          textAreaInput(ns("gList"), label = NULL, width = "90%")
        )
      }
      else if(input$InclusionMethod == "Slider"){
        div(
          shinyWidgets::noUiSliderInput(
            ns("gSlider"), max = 1, min = 0.01, value = 0.35, label = NULL, width = "90%", color = "#ff6f61"
          ),
          style = "margin-right: 3px;"
        )
      }
      
    })
    
    #Plot
    output$plot <- renderPlot({
      
      p <- Data$Results() %>% filter(tolower(Term_Description) == tolower(Search()))
      
      if(nrow(p) < 1){return()}
      
      Genes.in.Path <- c(
        PivotList(p$non_Signif_Snw_Genes)[[1]],
        PivotList(p$Up_regulated)[[1]],
        PivotList(p$Down_regulated)[[1]],
        PivotList(p$all_pathway_genes)[[1]]
      )

      #Use upload
      if(!is.null(Data$NormCounts())){
        plot.data <- Data$NormCounts() %>%
          filter(tolower(Gene_symbol) %in% tolower(Genes.in.Path))
      }
      #Check old upload
      if(!is.null(DiffData$NormCounts()) && is.null(Data$NormCounts())){
        plot.data <- DiffData$NormCounts() %>%
          tibble::rownames_to_column("Gene_symbol") %>%
          filter(tolower(Gene_symbol) %in% tolower(Genes.in.Path))
      }
      if(is.null(DiffData$NormCounts()) && is.null(Data$NormCounts())){
        return()
      }

      #Filtering

      if(input$InclusionMethod == "List"){
        
        # print(class(gList()))
        # print(gList())
        # print(tolower(gList()))
        # 
        # print(class(unlist(gList())))
        # print(unlist(gList()))
        # print(tolower(unlist(gList())))
        
        ref <- unlist(gList())
        
        plot.data <- plot.data %>%
          filter(tolower(Gene_symbol) %in% tolower(ref))
      
        print(plot.data)
      }
      if(input$InclusionMethod == "Slider"){

        number <- ceiling(nrow(plot.data) * gSlider())
        
        if(length(number) < 1){return()}
        
        if(!is.null(DiffData$Results())){
          
          reference <- DiffData$Results() %>%
            tibble::rownames_to_column("id") %>%
            filter(tolower(id) %in% tolower(Genes.in.Path)) %>%
            arrange(padj) %>%
            head(n = number) %>% 
            select(id)
          
          plot.data <- plot.data %>%
            filter(tolower(Gene_symbol) %in% tolower(reference$id))
          
        }else{
          plot.data <- head(plot.data, number)
        }

      }
      
      rownames(plot.data) <- plot.data$Gene_symbol
      plot.data <- plot.data %>% select(-Gene_symbol)
      
      plot.data <- log2(as.matrix(plot.data) + 1)
      
      if(nrow(plot.data) < 1){return()}
      
      h <- pheatmap(
        plot.data,
        scale = "row",
        angle_col = "45",
        show_colnames = TRUE,
        fontsize = input$Font,
        cellwidth = input$cW,
        cellheight = input$cH,
        annotation_col = Annotations(),
        annotation_colors = Colors(),
        display_numbers = input$NumDisplay,
        cluster_rows = ifelse(nrow(plot.data > 1), input$ClusterRows, FALSE), 
        cluster_cols = input$ClusterCols,
        legend_breaks = c(-2, -1, 0, 1, 2)
      ) %>% as.ggplot() +
        labs(
          title = Title(),
          subtitle = Subtitle(),
          caption = Caption(),
        ) +
        theme(
          plot.title = element_text(size = input$Font + 5, color = "black", margin=margin(20,20,5,10,"pt")),
          plot.subtitle = element_text(size = input$Font + 2, color = "black", margin=margin(5,5,15,10,"pt")),
          plot.caption = element_text(size = input$Font - 2, color = "black", margin=margin(10, 10, 10, 10, "pt"))
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
    
    #look up table
    output$Lookup2 <- renderDT({
      
      p <- Data$Results() %>% filter(tolower(Term_Description) == tolower(Search()))
      print("1")
      if(nrow(p) < 1){
        shinyjs::hide(ns("Genes"))
      }
      print("2")
      df <- data.frame("Genes" = c(
        PivotList(p$non_Signif_Snw_Genes)[[1]],
        PivotList(p$Up_regulated)[[1]],
        PivotList(p$Down_regulated)[[1]],
        PivotList(p$all_pathway_genes)[[1]]
      ))
      print(head(df))
      datatable(
        df, rownames = FALSE, 
        options = list(
          pagelength = 15, dom = "ftpr", pagingType = "simple",
          language = list(
            search = ""
          )
        )
      )
      
    })
    
    
    
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