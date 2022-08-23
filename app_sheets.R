# from:
# https://deanattali.com/blog/shiny-persistent-data-storage/
# 20190502_1600
# 20190530 Created Github repository
# 20190604 created input form
#          created new name for database (taskdb)
# 20220823 using googlesheets intsead of sqlite


# library installs
# install.packages("googlesheets4")
# install.packages("googledrive")

#source("helpers.R")
library(shiny)
library(googlesheets4)
library(googledrive)
library(tidyverse)


# authorization
googledrive::drive_auth("chapmjs@gmail.com")
gs4_auth(token = drive_token())
#gs4_auth("chapmjs@gmail.com")



# googledrive functions
# googledrive::drive_find()
# ss <- drive_find("chicken")
# gs4_get(ss)
# read_sheet(ss)
# drive_user()


# scopes
# PACKAGE_auth(
#   ...,
#   scopes = c(
#     "https://www.googleapis.com/auth/drive.readonly",
#     "https://www.googleapis.com/auth/spreadsheets"
#   ),
#   ...
# )
# gs4_auth(
#   ...,
#   scopes = "https://www.googleapis.com/auth/spreadsheets.readonly",
#   ...
# )



## Retrieve data

ss <- "https://docs.google.com/spreadsheets/d/1OxSuTreC34W5XDZPhXBNw2_tfs-50N2N1J1edTnTJE4/edit#gid=183391959"
task_data <- read_sheet(ss)
task_data <- filter(task_data, status %in% c("Open", "Idea"))
categories <- sort(unique(task_data$category))



# Define the fields we want to save from the form
fields <- c("task_id", "create_date_time", "category", "organization", "importance",  
            "urgency", "status", "subject", "estimated_time", "note", "next_step")

# Shiny app for task input and management
shinyApp(
  ui = fluidPage(
    DT::dataTableOutput("task_data", width = 300), tags$hr(),
    #selectInput("created_by", "Name", choices = userlist),
    textInput("subject", "Task", "", width = '300px'),
    selectInput("category", "Category", choices = categories),
    textAreaInput("note", "Note (optional), rows = 2"),
    sliderInput("importance", "Importance (1 is Most Important, 3 is Least Important)",
                1, 3, 2, ticks = FALSE),
    sliderInput("urgency", "Urgency (1 is Extremely Urgent, 9 is not urgent)", 
                1, 3, 2, ticks = FALSE),
    #selectInput("assigned", "Proposed Assignee (who should complete the job?)", 
    #            choices = c("Dad","Mom","Josh","Anna","Elisa","Rebekah","Sarah")),
    div(
      # hidden input field tracking the timestamp of the submission
      textInput("create_date_time", "", get_time_epoch()),
      style = "display: none;"
    ),
    actionButton("submit", "Submit")

    
  ),
  server = function(input, output, session) {
    
    # Whenever a field is filled, aggregate all form data
    formData <- reactive({
      data <- sapply(fields, function(x) input[[x]])
      data
    })
    
    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      saveData(formData())
    })
    
    # Show the previous taskdb
    # (update with current response when Submit is clicked)
    output$taskdb <- DT::renderDataTable({
      input$submit
      loadData()
    })     
  }
)


