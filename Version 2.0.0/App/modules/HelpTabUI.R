

helpTab <- function(){
  
  return(
    tabPanel(
      title = "Help",
      
      tabsetPanel(
        id = "Help Pages",
        
        tabPanel(
          title = "File Usage/Types/Requirments",
          includeHTML("Pages-Themes-Assets/HTML Pages/FileUsageDocumentation.HTML"),
          style = "margin-top: 10px; padding-bottom: 25; padding: 0px; z-index: 1;"
        ),
        
        tabPanel(
          title = "Saving Files",
          includeHTML("Pages-Themes-Assets/HTML Pages/SavingFilesDocumentation.HTML"),
          style = "margin-top: 10px; padding-bottom: 25; padding: 0px; z-index: 1;"
        )
        
      )
    )
  )  
}