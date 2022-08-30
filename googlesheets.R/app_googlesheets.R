# from:
# https://deanattali.com/blog/shiny-persistent-data-storage/
# 20190502_1600
# 20190530 Created Github repository
# 20190604 created input form
#          created new name for database (taskdb)
# 20190604 transition from sqlite to googlesheets
#          after > 2 hrs on this and other googlesheets scripts, could not get any write function working


source("helpers.R")
library(googlesheets)


# my_sheets <- gs_ls()

table <- "tasks_googlesheet"
# tasks_googlesheet <- gs_key("1i43AsYO_uLXSae4BM3NWutqEQbnIfCoOABFi9SePHbA")


userlist <- gs_read_csv(gs_key("17yCNcGrSWi2j-zwRx8JOQXBRcvDWvirHumgsMjIRopc"), col_names=FALSE)

saveData <- function(data) {
  # grab the Google sheet
  sheet <- gs_title(table)
  # add the data as a new row
  gs_add_row(sheet, input = data)
}

loadData <- function() {
  # grab the google sheet
  sheet <- gs_title(table)
  # read the data
  gs_read_csv(sheet)
}



# Define the fields we want to save from the form
fields <- c("submitname", "subject", "note", "importance", "urgency", 
            "assigned","timestamp")

# Shiny app for task input and managment
shinyApp(
  ui = fluidPage(
    selectInput("submitname", "Name", choices = userlist),
    textInput("subject", "Task", "", width = '250px'),
    textAreaInput("note", "Note (optional), rows = 2"),
    sliderInput("importance", "Importance (1 is Most Important, 9 is Least Important)",
                1, 9, 5, ticks = FALSE),
    sliderInput("urgency", "Urgency (1 is Extremely Urgent, 9 is not urgent)", 
                1, 9, 5, ticks = FALSE),
    selectInput("assigned", "Proposed Assignee (who should complete the job?)", 
                choices = userlist),
    div(
      # hidden input field tracking the timestamp of the submission
      textInput("timestamp", "", get_time_epoch()),
      style = "display: none;"
    ),
    actionButton("submit", "Submit"),
    DT::dataTableOutput("tasks_googlesheet", width = 300), tags$hr()
    
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
    output$tasks_googlesheet <- DT::renderDataTable({
      input$submit
      loadData()
    })     
  }
)


