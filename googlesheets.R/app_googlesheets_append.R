# googlesheets_append_app
# 2022 08 29

library(shiny)
library(googlesheets4)


# authorization
googledrive::drive_auth("chapmjs@gmail.com")
gs4_auth(token = drive_token())
#gs4_auth("chapmjs@gmail.com")

ss <- "https://docs.google.com/spreadsheets/d/1VX9O_LwkF0jQye7BgYv401IhByxVonyiI01ZwWllj78/edit?usp=sharing"
sheet_data <- read_sheet(ss)

ui <- fluidPage(
    textInput("name", "What's your name?"),
    textAreaInput("story", "Tell me about yourself", rows = 3),
    actionButton("submit", "Submit"),
    textOutput("greeting"),
    dataTableOutput("ss_display")
)

server <- function(input, output, session) {
  output$greeting <- reactive({
    input$submit
    renderText(input$name)
  })
  output$ss_display <- renderDataTable(sheet_data)
  #sheet_append(ss,input)
  
}

shinyApp(ui, server)
