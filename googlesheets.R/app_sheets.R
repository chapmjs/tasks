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
library(DT)
library(dplyr)


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



## Retrieve 
ss <- "https://docs.google.com/spreadsheets/d/1OxSuTreC34W5XDZPhXBNw2_tfs-50N2N1J1edTnTJE4/edit#gid=183391959"
task_data <- read_sheet(ss)
# create category list
categories <- sort(unique(task_data$category))

loadOpen <- function() {
  # read data from googlesheet
  task_list <- read_sheet(ss)
  # filter for open tasks
  open_tasks <- filter(task_list, task_list$status == "Open") %>% select(create_date_time, subject, category, note)
  # filter columns
  #open_tasks <- open_tasks %>% select(create_date_time, subject, category, note)
  
}
loadIdeas <- function() {
  # read data from googlesheet
  task_list <- read_sheet(ss)
  # filter for open tasks
  idea_tasks <- filter(task_list, task_list$status == "Idea")
  # filter columns
  idea_tasks <- idea_tasks %>% select(create_date_time, subject, category, note)
  idea_tasks <- idea_tasks %>% format(1,"toDateString")

}
loadClosed <- function() {
  # read data from googlesheet
  task_list <- read_sheet(ss)
  # filter for open tasks
  closed_tasks <- filter(task_list, task_list$status == "Closed")
  
}

saveData <- function(new_task_data) {
  ss %>% sheet_append(input$subject)
}

# Define the fields we want to save from the form
fields <- c("task_id", "create_date_time", "category", "importance",  
            "urgency", "status", "subject", "estimated_time", "note", "next_step")

# Shiny app for task input and management
shinyApp(
  ui = fluidPage(
    title = "Task List",
    sidebarLayout(
      sidebarPanel(
        width = 4,
        #selectInput("created_by", "Name", choices = userlist),
        textInput("subject", "Task", ""),
        selectInput("category", "Category", choices = categories),
        textAreaInput("note", "Note (optional), rows = 2"),
        numericInput("importance", "Importance", value = 1, min = 1, max = 3),
        numericInput("urgency", "Urgency", value = 1, min = 1, max = 3),
        selectInput("status", "Status", choices = c("Open","Idea", "Closed")),
        #selectInput("assigned", "Proposed Assignee (who should complete the job?)", 
        #            choices = c("Dad","Mom","Josh","Anna","Elisa","Rebekah","Sarah")),
        div(
          # hidden input field tracking the timestamp of the submission
          textInput("create_date_time", "", as.integer(Sys.time())),
          textInput("task_id", n_distinct(task_data$task_id + 1)),
          style = "display: none;"
        ),
        actionButton("submit", "Submit")
        

        # conditionalPanel(
        #   'input.dataset === "open_tasks"',
        # ),
        # conditionalPanel(
        #   'input.dataset === "idea_tasks"'
        # ),
        # conditionalPanel(
        #   'input.dataset === "closed_tasks"'
        # )
      ),
      mainPanel(
       
  
        tabsetPanel(
          id = 'dataset',
          tabPanel("Open Tasks", DT::DTOutput("open")),
          tabPanel("Ideas", DT::DTOutput("ideas")),
          tabPanel("Closed Tasks", DT::DTOutput("closed"))
        )
      )
    )
          
    
    #DT::DTOutput("task_list"), tags$hr(),

    
  ),
  server = function(input, output, session) {
    
    # Whenever a field is filled, aggregate all form data
    formData <- reactive({
      data <- sapply(fields, function(x) input[[x]])
      data
    })
    
    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      sheet_append(ss,formData(), sheet = 1)
    })
    
    # Show the previous task_data
    # (update with current response when Submit is clicked)
    output$open <- DT::renderDT({
      input$submit
      loadOpen()
    })
    output$ideas <- DT::renderDT({
      input$submit
      loadIdeas()
    })
    output$closed <- DT::renderDT({
      input$submit
      loadClosed()
    })
  }
)


