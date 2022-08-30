# https://stackoverflow.com/questions/62479762/use-shiny-to-collect-data-from-users-in-google-sheet

#load libraries
library(shiny)
library(shinydashboard)
library(googlesheets4)
library(DT)

ui <- fluidPage(
  titlePanel("Seflie Feedback"),
  sidebarLayout(
    sidebarPanel(
      #This is where a user could type feedback
      textInput("feedback", "Plesae submit your feedback"),
    ),
    #This for a user to submit the feeback they have typed
    actionButton("submit", "Submit")),
  mainPanel())

server <- function(input, output, session) {
  
  textB <- reactive({
    
    as.data.frame(input$feedback)
    
  })
  
  observeEvent(input$submit, {
    Selfie <-   gs4_get('https://docs.google.com/spreadsheets/d/162KTHgd3GngqjTm7Ya9AYz4_r3cyntDc7AtfhPCNHVE/edit?usp=sharing')
    sheet_append(Selfie, data = textB())
  })
}
shinyApp(ui = ui, server = server)
