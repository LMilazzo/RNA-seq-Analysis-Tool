# Raw Counts Files
readCountsDF <- function(df, filterTarget){

  #                   CHECK REQUIRED COLUMS
  #_______________________________________________________________
  req <- c("gene_id", "gene_name")
  if(! all( req %in% colnames(df) ) ){
    showErrorModal('Required columns ( gene_id or gene_name ) are missing in the counts matrix')
    return()
  }

  #                   CHECK DUPLICATE IDS
  #_______________________________________________________________
  if(anyDuplicated(df$gene_id)){
    showErrorModal('There were duplicate ids in the counts matrix')
    return()
  }
  
  #                   FIND SAMPLE COLUMN NAMES
  #_______________________________________________________________
  sample_cols <- df %>% select(starts_with('.'))
  if(ncol(sample_cols) < 2){
    showErrorModal('There were not enough samples present')
    return()
  }
  
  #                   SET THE RAW COUNTS DATA FRAME
  #_______________________________________________________________
  raw_counts <- df
  
  rownames(raw_counts) <- raw_counts$gene_name
  
  raw_counts <- raw_counts %>% select(all_of(colnames(sample_cols)))

  #                       FILTER THE COUNTS
  #_______________________________________________________________
  rowsToKeep <- rowSums(raw_counts) > filterTarget
  
  filtered_counts <- raw_counts[rowsToKeep,]
  
  #               CREATE A DATAFRAME OF GENE NAMES
  #_______________________________________________________________
  gene_names <- rownames(filtered_counts)
  
  #RETURN
  return(list("gene_names" = gene_names, "counts" = filtered_counts))
  
}

# Meta Data Files
readMetaDataDF <- function(md){
  
  # Error: Insufficient columns
  if ( ncol(md) < 2 || ! "sample" %in% colnames(md)) {
    showErrorModal("The meta data file is missing columns")
    return()
  }
  
  #               ASSERT SAMPLE NAMING CONVENTION
  #_____________________________________________________________
  md$sample <- ifelse(!grepl("^\\.", md$sample), paste0(".", md$sample), md$sample)
  md <- md %>%
    tibble::column_to_rownames('sample')
  
  md[] <- lapply(md, as.factor)
  
  return(md)
  
}

# DEG Results Files
readDegDF <- function(data, metaData){
  
  #                   CHECK FOR REQ COLUMNS
  #______________________________________________________________
  
  req_col <- c( "gene_id" , "gene_name" , "log2FoldChange" , "padj" )
  possible_col <- c("gene_id", "gene_name", "baseMean", 
                    "log2FoldChange", "lfcSE", "stat", "pvalue", "padj")
  
  if(! all( req_col %in% colnames(data) ) ){
    showErrorModal("DEG file missing either ('gene_id', 'gene_name', 'log2FoldChange', 'padj')")
    return()
  }
  
  #                   CHECK DUPLICATE IDS
  #_______________________________________________________________
  
  #Check duplicate ids
  if (anyDuplicated(data$gene_id)) {
    showErrorModal("Gene ids need to be unique for each row")
    return()
  }
  
  #                   READ THE DATA (exluding counts)
  #_______________________________________________________________
  
  #select all existent possible columns
  results <- data %>%
    select(all_of(intersect(colnames(data), possible_col)))
  
  #set rownames
  rownames(results) <- results$gene_name
  
  #get Gene Names
  gene_names <- rownames(results)
  
  #                   PROCESSING SAMPLE COLUMNS
  #_______________________________________________________________
  
  sample_cols <- data %>% select(starts_with('.'), gene_name)
  rownames(sample_cols) <- sample_cols$gene_name
  sample_cols <- sample_cols %>% select(-gene_name)
  
  #RETURN 1 NO COUNTS RETURN
  if (ncol(sample_cols) == 0) {
    
    showErrorModal("Warning: Some features not available because of missing sample data")
    
    return(list(results, gene_names, NULL, NULL, NULL))
    
  }
  
  #ERROR 1
  if (nrow(sample_cols) != nrow(results)) {
    showErrorModal("Error: number of rows in the sample data != rows in results data")
    return()
  }
  
  
  #ERROR 2
  if( ncol(sample_cols) != nrow(metaData) ){
    showErrorModal("Error: Number of samples in meta data is not the same as the number of samples in the counts data")
    return()
  }
  
  #     PROCESS OBJECTS
  #_________________________________
  counts <- sample_cols %>% as.matrix() %>% round()   
  
  v <- varianceStabilizingTransformation(counts, blind=TRUE)
  
  se <- SummarizedExperiment(assays = list(counts = v), colData = metaData)
  
  vsd <- DESeqTransform(se)
  
  
  return(
    list(
      "Results" = results %>% select(-gene_name, -gene_id), 
      "GeneNames" = gene_names,
      "NormalizedCounts" = sample_cols,
      "vst_counts" = data.frame(v),
      "vst_obj" = vsd
    )
  )
  
}

# Path Results Files
readPathDF <- function(data){

    
  req_cols <- c("ID","Term_Description","Fold_Enrichment","occurrence",
                "support","lowest_p","highest_p","non_Signif_Snw_Genes",
                "Up_regulated","Down_regulated","all_pathway_genes",
                "num_genes_in_path","Cluster","Status")
    
  if(!all(req_cols %in% colnames(data))){
      showErrorModal('There are some missing cols in the uploaded set, please ensure that your data is a *Clustered* result from the pathfindR package.')
      return()
    }
    
  #Assert correct classes
  original_na_counts <- sapply(colnames(data), 
                               function(col) sum(is.na(data[[col]]))) 
    
  data$ID <- as.character(data$ID)
  data$Term_Description <- as.character(data$Term_Description)
  data$non_Signif_Snw_Genes <- as.character(data$non_Signif_Snw_Genes)
  data$Up_regulated <- as.character(data$Up_regulated)
  data$Down_regulated <- as.character(data$Down_regulated)
  data$all_pathway_genes <- as.character(data$all_pathway_genes)
  data$Status <- as.character(data$Status)
  data$Fold_Enrichment <- as.numeric(data$Fold_Enrichment)
  data$occurrence <- as.numeric(data$occurrence)
  data$support <- as.numeric(data$support)
  data$lowest_p <- as.numeric(data$lowest_p)
  data$highest_p <- as.numeric(data$highest_p)
  data$num_genes_in_path <- as.numeric(data$num_genes_in_path)
  data$Cluster <- as.numeric(data$Cluster)
  
  for(i in colnames(data)){
    new_na <- sum(is.na(data[[i]]))
    if(!new_na == original_na_counts[[i]]){
      showErrorModal(paste0('Coercion of column ', i, ' to proper class introduced na values. ', i, ' requires numeric.'))
      return()
    }
  }
  
  return(data)

}

# Path Normalized Counts
readPathCounts <- function(data){
  #print(head(data))
  #                   CHECK REQUIRED COLUMS
  #_______________________________________________________________
  
  #Check for req columns
  if(! 'gene_id' %in% colnames(data) ){
    showErrorModal('Required columns gene_id is missing in the counts matrix')
    return()
  }
  if(! 'gene_name' %in% colnames(data) && !'Gene_symbol' %in% colnames(data)){
    showErrorModal('Required columns Gene_symbol is missing in the counts matrix')
    return()
  }
  
  #                   CHECK DUPLICATE IDS
  #_______________________________________________________________
  
  #Check duplicate ids
  if(anyDuplicated(data %>% select(gene_id))){
    showErrorModal('There were duplicate ids in the counts matrix')
    return()
  }
  
  #                   FIND SAMPLE COLUMN NAMES
  #_______________________________________________________________
  sample_cols <- data %>% select(starts_with('.'))
  if(ncol(sample_cols) < 2){
    showErrorModal('There were not enough samples present')
    return()
  }
  
  #                   FIND GENE NAMES COLUMN
  #_______________________________________________________________
  pos <- which(names(data) %in% c('gene_name', 'Gene_symbol'))
  pos <- pos[1]
  
  #                     BUILD DATAFRAME
  #_______________________________________________________________
  ab <- sample_cols
  ab$Gene_symbol <- data[, pos]
  ab <- ab %>% select(Gene_symbol, everything())
  
  #               CREATE A DATAFRAME OF GENE NAMES
  #_______________________________________________________________
  gene_names <- ab$Gene_symbol
  
  #RETURN
  return(list(ab, gene_names))
  
}