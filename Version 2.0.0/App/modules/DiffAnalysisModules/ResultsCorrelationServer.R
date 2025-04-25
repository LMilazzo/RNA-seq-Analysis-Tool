ResultsCorrelationServer <- function(id, Data, Uploads){
  moduleServer(id, function(input, output, session){
    
    ns <- session$ns
    
    plot <- reactiveVal(NULL)
    #Data ~~~~~~~~~
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
    #Uploads ~~~~~~~~~
    # DiffUploads <- list(
    #   "RawCounts" = Reactive,
    #   "GeneNames" = Reactive,
    #   "MetaData" = Reactive,
    #   "PrevResults" = Reactive list,
    #   "status" = Reactive 0, 1, 2
    # )
    # #~~~~~~~~~~~~~~~
    
    #Debounce Text Inputs
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
      
      a <- Uploads$MetaData() %>% select(input$MetaData)
      Annotations(a)
      
      i <- 1
      
      colors <- list()
      for(ann in colnames(a)){
        colors[[ann]] <- gen_color_pallette(a %>% select(ann), i)
        i <- i + 1
      }
      Colors(colors)
      
    }, ignoreNULL = FALSE )
  
    #Meta Data selection                 #REMOVE RESTAINT
    output$Meta <- renderUI({
      
      checkboxGroupInput(
        ns("MetaData"),
        NULL,
        choices = colnames(Uploads$MetaData()),
        selected =
          ifelse(
            is.null(Data$ddsc()),
            colnames(Uploads$MetaData())[1],   # NULL case
            all.vars(design(Data$ddsc()))   #Not NULL case
          )
      )
      
    })
  
    output$plot <- renderPlot({
      #make/save
      plot(
        pheatmap(
          cor(Data$vstCounts()),
          angle_col = "45",
          show_colnames = TRUE,
          fontsize = input$Font,
          cellwidth = input$cW,
          cellheight = input$cH,
          annotation_row = Annotations(),
          annotation_colors = Colors(),
          display_numbers = input$NumDisplay,
          cluster_rows = input$ClusterRows,
          cluster_cols = input$ClusterCols
        ) %>% as.ggplot() +
          labs(
            title = Title(),
            subtitle = Subtitle(),
            caption = Caption(),
          ) + 
          theme(
            plot.title = element_text(size = input$Font + + 5, color = "black", margin=margin(20,20,5,10,"pt")),
            plot.subtitle = element_text(size = input$Font + 2, color = "black", margin=margin(5,5,15,10,"pt")),
            plot.caption = element_text(size = input$Font - 2, color = "black", margin=margin(10, 10, 10, 10, "pt"))
          )
      )
      #print
      plot()
        
     },
        width = function() {ifelse(is.na(input$W), 1000, input$W)},
        height = function() {ifelse(is.na(input$H), 750, input$H)}
    )
    
    
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