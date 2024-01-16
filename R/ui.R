
library(shiny)
library(shinyWidgets)
library(magrittr)
library(tidyverse)
library(shinyvalidate)

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel(h1("Survey Report Generator", align = "center")),
  mainPanel(width = 12,
            hr(),
            fluidRow(
              h3("Survey", align = "center"),
              column(6,textInput(inputId = "survID", 
                                  label = "Survey Code",
                                  value = "",
                                  placeholder = "e.g. 0422S"), align = "center"),
              column(6,selectInput(inputId = "survSeries", 
                                  label = "Survey Series",
                                  choices = c("Deepwater","HERAS","MACAS","IBTS",
                                              "Rockall","SIAMISS")), align = "center")
            ),
            hr(),
            fluidRow(
              h3("Dates", align = "center"),
              column(6,dateRangeInput(inputId = "schedDates", label = "Scheduled Dates"), align = "right"),
              column(6,dateRangeInput(inputId = "actDates", label = "Actual Dates"), align = "left")
            ),
            uiOutput("datesDiff"),
            fluidRow(
              column(6,numericInput("schedDays", label = "Scheduled Days", value = NA), align = "right"),
              column(6,numericInput("actDays", label = "Actual Days", value = NA), align = "left")
            ),
            uiOutput("daysDiff"),
            fluidRow(
              column(6,radioGroupButtons(inputId = "halfLanSwitch", 
                                         label = "Was there a half landing?", 
                                         choices = c("Yes", "No"),
                                         justified = TRUE, width = "300px"), align = "right"),
              conditionalPanel(condition = "input.halfLanSwitch == 'Yes'",
                               column(6,dateInput(inputId = "halfDate", label = "Half landing Date"), align = "left"))),
            hr(),
            fluidRow(
              h3("Hauls", align = "center"),
              column(6,numericInput("schedHauls", label = "Scheduled Hauls", value = 1), align = "right"),
              column(6,numericInput("actHauls", label = "Actual Hauls", value = 1), align = "left")
            ),
            uiOutput("haulsDiff"),
            hr(),
            fluidRow(
              h3("Ports", align = "center"),
              column(6, 
                selectizeInput(inputId = "depPort", label = "Departure Port",
                  multiple = FALSE,
                  choices = NULL,
                  options = list(
                    create = FALSE,
                    placeholder = "Search Me",
                    maxItems = '1',
                    onDropdownOpen = I("function($dropdown) {if (!this.lastQuery.length) {this.close(); this.settings.openOnFocus = false;}}"),
                    onType = I("function (str) {if (str === \"\") {this.close();}}")
                  )
                ), align = "right"
              ),
              column(6,
               selectizeInput(inputId = "arrPort", label = "Arrival Port",
                multiple = FALSE,
                choices = NULL,
                options = list(
                 create = FALSE,
                 placeholder = "Search Me",
                 maxItems = '1',
                 onDropdownOpen = I("function($dropdown) {if (!this.lastQuery.length) {this.close(); this.settings.openOnFocus = false;}}"),
                 onType = I("function (str) {if (str === \"\") {this.close();}}")
                )
               ), align = "left"
              )
            ),
            conditionalPanel(condition = "input.halfLanSwitch == 'Yes'",
            fluidRow(
              column(4,),
              column(4,                
                     selectizeInput(inputId = "halfPort", label = "Half Landing Port",
                                    multiple = FALSE,
                                    choices = NULL,
                                    options = list(
                                      create = FALSE,
                                      placeholder = "Search Me",
                                      maxItems = '1',
                                      onDropdownOpen = I("function($dropdown) {if (!this.lastQuery.length) {this.close(); this.settings.openOnFocus = false;}}"),
                                      onType = I("function (str) {if (str === \"\") {this.close();}}")
                                    )
                     ), align = "center"
              ),
              column(4,)
            )),
            hr(),
            fluidRow(
              h3("Personnel", align = "center"),
              numericInput("persNum", label = "Number of personnel", value = NA, min = 1), align = "center"
            ),
            uiOutput("personnel"),
            hr(),
            fluidRow(
              h3("Objectives", align = "center"),
              numericInput("objNum", label = "Number of associated objectives", value = NA, min = 1), align = "center"
            ),
            uiOutput("objectives"),
            hr(),
            fluidRow(
              h3("Project Days", align = "center"),
              numericInput("projNum", label = "Number of associated projects", value = NA, min = 1), align = "center"
            ),
            uiOutput("projects"),
            hr(),
            fluidRow(
            h3("Gear", align = "center"),
            textAreaInput("gears", label = "Gears Used", width = "300px", height = "200px"),
            align = "center"),
            hr(),
            fluidRow(
              h3("Narrative", align = "center"),
              textAreaInput("narrative", label = "Survey Narrative", width = "500px", height = "300px"),
              align = "center"),
            hr(),
            fluidRow(downloadButton("report", "Generate report"), align = "center")
            #uiOutput("narrative")
  )
)