
#for plots
savePlotButton <- function(id){
  
  ns <- NS(id)
  
  return(
    div(id = "save",
        actionButton(
          ns("SavePlot"), 
          "Save Plot",
          style = "background-color: #4CAF50; color: black; border: 1px solid black; background-image: none;"
        ),
        style = "border: 2px solid #272b30; border-radius: 15px; margin-top: 5px;
        width: 100%; align-items: center; justify-content: center; display: flex; text-align: center;
        padding-top: 10px; padding-bottom: 10px;  overflow: auto;"
    )
  )
}

#for plots
saveFile <- function(objectReactive, filename, extension, width, height){
  
  
  print(class(objectReactive()))
  print(filename)
  print(width)
  print(height)
  
  png(paste0("SavedFiles/", filename, extension), height = height, width = width)
  
  print(objectReactive())
  
  dev.off()
  
}


#ADD TO ANY MODULE SERVER WITH A SAVABLE PLOT

#______________________________________SAVING____________________________________
# observeEvent(input$SavePlot,{
#   
#   showModal(modalDialog(
#     title = "Enter File Name",  # Title of the modal
#     textInput(ns("fileName"), "File Name:", value = ""),  # Text input for the file name
#     radioButtons(ns{"extension"}, choices = c(".jpeg", ".png"), selected = ".png", inline = TRUE, width = "100%"),
#     footer = tagList(
#       modalButton("Cancel"),  # Cancel button to close the modal
#       actionButton(ns("saveFile"), "Save")  # Save button to handle the file name
#     )
#   ))
#   
# })
# observeEvent(input$saveFile, {
#   removeModal()
#   saveFile(plot, input$fileName, input$extension, input$W, input$H)
# })


saveTableButton <- function(id){
  
  ns <- NS(id)
  
  return(
    div(id = "save",
        actionButton(
          ns("SaveTable"), 
          "Save Results",
          style = "background-color: #4CAF50; color: black; border: 1px solid black; background-image: none;"
        ),
        style = "border: 2px solid #272b30; border-radius: 15px; margin-top: 5px;
        width: 100%; align-items: center; justify-content: center; display: flex; text-align: center;
        padding-top: 10px; padding-bottom: 10px;  overflow: auto;"
    )
  )
}

saveTable <- function(table, filename, extension){
  
  if(extension == ".csv"){
    se <- ","
  }
  if(extension == "tsv"){
    se <- "\t"
  }
  
  write.csv(
    table(),
    file = paste0("SavedFiles/", filename, extension),
    sep = se
  )
  
  
  
}

#______________________________________SAVING____________________________________
# observeEvent(input$SaveTable,{
#   
#   showModal(modalDialog(
#     title = "Enter File Name",  # Title of the modal
#     textInput(ns("fileName"), "File Name:", value = ""),  # Text input for the file name
#     radioButtons(ns{"extension"}, choices = c(".csv", ".tsv"), selected = ".png", inline = TRUE, width = "100%"),
#     footer = tagList(
#       modalButton("Cancel"),  # Cancel button to close the modal
#       actionButton(ns("saveTable"), "Save")  # Save button to handle the file name
#     )
#   ))
#   
# })
# observeEvent(input$saveTable, {
#   removeModal()
#   saveTable(table, filename, extension)
# })
