#
# adapted from:
# https://deanattali.com/2015/06/14/mimicking-google-form-shiny/
#

shinyApp(
  ui = fluidPage(
    titlePanel("Tasks App"),
    div(
      id = "form",
      
      textInput("task", "Task", ""),
      selectInput("category", "Category",c("1 God","2 Spouse", "3 Family", "4 Church","5 Work-Education", "6 Community-Friends", "7 Hobby-Interest")),
      textInput("notes", "Notes", ""),
      #textInput("favourite_pkg", "Favourite R package"),
      #checkboxInput("used_shiny", "I've built a Shiny app in R before", FALSE),
      #sliderInput("r_num_years", "Number of years using R", 0, 25, 2, ticks = FALSE),
      selectInput("priority", "Priority",
                  c("1",  "2", "3", "4","5")),
      #select.list(choices="Parent Task",multiple = FALSE,title="Parent Task"),
      actionButton("submit", "Submit", class = "btn-primary")
    )
  ),
  server = function(input, output, session) {
  }
)