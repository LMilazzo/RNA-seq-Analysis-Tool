PathUploadsServer <- function(id, DiffData, DiffUploads){
  moduleServer(id, function(input, output, session){
    
    ns <- session$ns
      
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
    #  #Differential Gene Expression Uploads Data
    # DiffUploads <- list(
    #   "RawCounts" = Reactive,
    #   "GeneNames" = Reactive,
    #   "MetaData" = Reactive,
    #   "PrevResults" = Reactive list,
    #   "status" = Reactive 0, 1, 2
    # )
    
    status <- reactiveVal(0)
    
    #       NEW DATA
    #____________________________
    
    RCV.Results <- reactiveVal(NULL)
    RCV.Norm <- reactiveVal(NULL)
    RCV.MetaData <- reactiveVal(NULL)
    RCV.GeneNames <- reactiveVal(NULL)
    
    observeEvent(input$ContinueSessionWithPathway,{
      
      #Local Save
      normCounts <- DiffData$NormCounts()
      Deg <- DiffData$Results()
      
      if(is.null(Deg)){
        showErrorModal("Complete/Upload Differential Gene Expression Results")
        return()
      }
     
      #Set Up Data
      #
      #results
      Deg$Gene_symbol <- rownames(Deg)
      Deg <- Deg %>% 
        select(Gene_symbol, logFC = log2FoldChange, Padj = padj) %>%
        filter(!is.na(Padj))
      #counts
      normCounts$Gene_symbol <- rownames(normCounts)
      normCounts <- normCounts %>% select(Gene_symbol, everything())
      
      RCV.Results(runPathfindRFunc(Deg))
      RCV.Norm(normCounts)
      RCV.GeneNames(DiffUploads$GeneNames())
      RCV.MetaData(DiffUploads$MetaData())
      status(1)
      
      
    })
    
    #     OLD DATA
    #____________________________
    
    #User uploads some old data
    observeEvent(input$UploadPrevPathData, {
      showModal(
        modalDialog(
          div( 
            
            p('Pathway Analysis Results'),
            HTML('<p>This is the standard output from a pathfindR clustered experiment.</p>'),
            p("Accepted File Types:  .csv   .tsv "),
            HTML('<p>Must contain all following columns:</p>'),
            HTML('<p>(ID,	Term_Description,	Fold_Enrichment, occurrence, support,	lowest_p,	highest_p,	non_Signif_Snw_Genes,	Up_regulated,	Down_regulated,	all_pathway_genes,	num_genes_in_path,	Cluster, Status)</p>'),
            
            fileInput(ns('Path_Prev_Data'), 'Pathway Analysis Results'),
            
            HTML('<p>Normalized Gene Counts'),
            p("Accepted File Types:  .csv   .tsv "),
            HTML('<p>Format: (gene_name, samples...)</p>'),
            p('All sample column headers should start with a "." character to be recognized'),
            
            fileInput(ns('Path_Norm_Counts'), 'Gene Counts'),
            
            h5("Sample Conditions Table"),
            p("Accepted File Types:  .csv   .tsv "),
            p("Format: (sample, conditions...) "),
            p("Sample column should include sample names that are found in your experiment data"),
            
            fileInput(ns("Path_Meta_Data"), "Sample Conditions")
            
          ), footer = actionButton(ns("LoadPathPrevData"), 'Finish'),
          easyClose = TRUE
        )
      )
      
    })
    
    
    observeEvent(input$LoadPathPrevData, {
      removeModal()
      
      #     RESULTS DATA
      #______________________________
      RCV.Results(AssertFile(input$Path_Prev_Data$datapath))
      if(!is.data.frame(RCV.Results())){
        showErrorModal("(Results) Invalid File Type Error")
        return()
      }
      
      RCV.Results(readPathDF(RCV.Results()))
      if(!is.data.frame(RCV.Results())){
        showErrorModal("Missing Data in Pathfinder output file")
        return()
      }
      
      #          META DATA
      #_______________________________
      RCV.MetaData(AssertFile(input$Path_Meta_Data$datapath))
      if(!is.data.frame(RCV.MetaData())){
       showErrorModal("Meta Data Missing some features not available")
      }else{
        RCV.MetaData(readMetaDataDF(RCV.MetaData()))
      }

      #       Normalized Counts
      #_______________________________
      RCV.Norm(AssertFile(input$Path_Norm_Counts$datapath))
      if(!is.data.frame(RCV.Norm())){
        RCV.GeneNames(NULL)
        RCV.Norm(NULL)
      }else{
        temp <- readPathCounts(RCV.Norm())
        RCV.GeneNames(temp[[2]])
        RCV.Norm(temp[[1]])
      }
     
      status(1)
      
    })
    
    
    
    #     RETURN
    #____________________________
    
    return(
      
      list(
        "MetaData" = RCV.MetaData,
        "NormCounts" = RCV.Norm,
        "GeneNames" = RCV.GeneNames,
        "Results" = RCV.Results,
        "status" = status
      )
      
    )
    
  })
}