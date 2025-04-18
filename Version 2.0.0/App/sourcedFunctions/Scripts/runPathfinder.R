# Function That runs pathfindR
runPathfindRFunc <- function(data_source){
  
  #Set up database
  kegg <- plyr::ldply(pathfindR.data::kegg_genes, data.frame) %>% 
    mutate(num_genes_in_path = 1) %>% 
    dplyr::group_by(.data$.id) %>% 
    dplyr::summarize(X..i.. = paste0(.data$X..i.., collapse = ", "), num_genes_in_path = sum(num_genes_in_path)) 
  names(kegg)[1] <- "ID"
  names(kegg)[2] <- "all_pathway_genes"
  
  showModal(
    modalDialog(
      div(
        tags$span("Performing Pathway Enrichment Search"),
        tags$span(class="custom-loader"),
        style = "margin: 0px; padding: 0px; display: inline-flex; font-size: 16px;"
      ),
      footer = NULL,
      size = "m")
  )
  #Run pathfinder
  
  tryCatch({
    
    res <- run_pathfindR(data_source,
                         pin_name_path = "KEGG",
                         enrichment_threshold = 0.05,
                         iterations = 25,
                         list_active_snw_genes = TRUE)
    
    if(ncol(res) == 0 || nrow(res) == 0){
      showErrorModal('No Enriched Terms were found for the provided pin')
      return()
    }
    
    if(length(intersect(colnames(res), colnames(kegg))) == 0){
      showErrorModal("No common variables in pin and pathfinder output")  
      return()
    }
    
    res <- left_join(res, kegg)
    
    res_clustered <- cluster_enriched_terms(res,  
                                            plot_dend = FALSE, 
                                            plot_clusters_graph = FALSE)
    
    showModal(modalDialog("pathfindR complete with no fatal errors", easyClose = TRUE, footer = NULL))
    dev.off()
    return(res_clustered)
    
  },
  error = function(e) {
    
    showErrorModal(paste("Error in pathfindR process:", e$message))
    
  })
  
}