# from:
# https://deanattali.com/blog/shiny-persistent-data-storage/
# 20190502_1600
# 20190530 Created Github repository
# 20190604 created input form
#          created new name for database (taskdb)
# 20220830 updated task input fields


#source("helpers.R")
library(shiny)
library(RSQLite)
library(dplyr)

saveData <- function(data) {
  # Connect to the database
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the update query by looping over the data fields
  query <- sprintf(
    "INSERT INTO %s (%s) VALUES ('%s')",
    table, 
    paste(names(data), collapse = ", "),
    paste(data, collapse = "', '")
  )
  # Submit the update query and disconnect
  dbGetQuery(db, query)
  dbDisconnect(db)
}

loadData <- function() {
  # Connect to the database
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the fetching query
  query <- sprintf("SELECT * FROM %s", table)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}

userlist <- function() {
  db <- dbConnect(SQLite(), sqlitePath)
  query <- sprintf("SELECT name FROM %s", "tbl_contacts")
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}

# Define sqlite
sqlitePath <- "taskdb.sqlite"

# Define categories
table <- "tbl_categories"
categories <- loadData()

# Define tasks table
table <- "tbl_tasks"



# Define the fields we want to save from the form
fields <- c("task_id", "task_create_datetime", "task_subject", "task_status", 
            "task_estimated_time", "category_id", "task_importance",
            "task_urgency")

# Shiny app for task input and management
shinyApp(
  ui = fluidPage(
    title = "Tasks",
    sidebarLayout(
      sidebarPanel(
        width = 4,
        div(
          # hidden input field tracking the timestamp of the submission
          textInput("task_create_datetime", "", Sys.Date()),
          #textInput("task_id", n_distinct(data$task_id + 1)),
          style = "display: none;"
        ),
        textInput("task_subject", "Task", ""),
        selectInput("status", "Status", choices = c("Open","Idea", "Closed")),
        numericInput("task_estimated_time","Time (hours)", ""),
        selectInput("category_id", "Category", choices = categories),
        numericInput("task_importance", "Importance", value = 1, min = 1, max = 3),
        numericInput("task_urgency", "Urgency", value = 1, min = 1, max = 3),
      
        actionButton("submit", "Submit")
        

        ),
    mainPanel(
      tabsetPanel(
        id = 'dataset',
        tabPanel("Tasks", DT::DTOutput("data"))
      )
    )
  )
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


