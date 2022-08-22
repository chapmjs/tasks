# from:
# https://deanattali.com/blog/shiny-persistent-data-storage/
# 20190502_1600
# 20190530 Created Github repository
# 20190604 created input form
#          created new name for database (taskdb)


source("helpers.R")
library(shiny)
library(RSQLite)
sqlitePath <- "taskdb.db"
table <- "tasks"

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
  query <- sprintf("SELECT name FROM %s", "users")
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}


# Define the fields we want to save from the form
fields <- c("submitname", "subject", "note", "importance", "urgency", 
            "assigned","timestamp")

# Shiny app for task input and managment
shinyApp(
  ui = fluidPage(
    DT::dataTableOutput("taskdb", width = 300), tags$hr(),
    selectInput("submitname", "Name", choices = userlist()),
    textInput("subject", "Task", "", width = '250px'),
    textAreaInput("note", "Note (optional), rows = 2"),
    sliderInput("importance", "Importance (1 is Most Important, 9 is Least Important)",
                1, 9, 5, ticks = FALSE),
    sliderInput("urgency", "Urgency (1 is Extremely Urgent, 9 is not urgent)", 
                1, 9, 5, ticks = FALSE),
    selectInput("assigned", "Proposed Assignee (who should complete the job?)", 
                choices = c("Dad","Mom","Josh","Anna","Elisa","Rebekah","Sarah")),
    div(
      # hidden input field tracking the timestamp of the submission
      textInput("timestamp", "", get_time_epoch()),
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


