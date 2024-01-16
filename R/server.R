# Define server logic required to draw a histogram
#locs = read.csv("data/code-list_csv.csv")

server <- function(input, output, session) {
  
  iv <- InputValidator$new()
  
  iv$add_rule("survID", sv_required())
  #iv$add_rule("survID", , "Please check that you are entering a valid survey code!")
  
  iv$enable()
  
  observe({
    if(input$schedDates[1] != input$actDates[1] | input$schedDates[2] != input$actDates[2]) {
      output$datesDiff = renderUI({
        fluidRow(textAreaInput(inputId = "dateDiff", label = "Please give further detail on the survey date changes.", width = "500px", height = "100px"), align = "center")
      })
    } else {
      output$datesDiff = renderUI({return(NULL)})
    }
  })
  
  observe({
    calcSchedDays = as.numeric(difftime(input$schedDates[2], input$schedDates[1]))
    calcActDays = as.numeric(difftime(input$actDates[2], input$actDates[1]))
    
    updateNumericInput(session = session, inputId = "schedDays", value = calcSchedDays)
    updateNumericInput(session = session, inputId = "actDays", value = calcActDays)
    
    validate(
      need(input$schedDays,"Please provide a number"),
      need(input$actDays,"Please provide a number"))
    
    if(input$schedDays != input$actDays) {
      output$daysDiff = renderUI({
        fluidRow(textAreaInput(inputId = "dayDiff", label = "Please give further detail on the number of day changes.", width = "500px", height = "100px"), align = "center")
      })
    } else {
      output$daysDiff = renderUI({return(NULL)})
    }
  })
  
  observe({
    validate(
      need(input$schedHauls,"Please provide a number"),
      need(input$actHauls,"Please provide a number"))
    
    if(input$schedHauls != input$actHauls) {
      output$haulsDiff = renderUI({
        fluidRow(textAreaInput(inputId = "haulDiff", label = "Please give further detail on the number of hauls changes.", width = "500px", height = "100px"), align = "center")
      })
    } else {
      output$haulsDiff = renderUI({return(NULL)})
    }
  })
  
 # observe({
 #   
 #   narDates = seq(input$actDates[1], input$actDates[2], by = "days")
 #   
 #   output$narrative = renderUI({
 #     lapply(1:length(narDates), function(i) {
 #       fluidRow(textAreaInput(inputId = paste0("nar", i), label = narDates[i], width = "400px", height = "100px"), align = "center")
 #     })
 #   })
    
    
 # })
  
  observe({
    
    if(! is.na(input$persNum) & input$persNum > 0){
      output$personnel = renderUI({
        validate(
          need(input$persNum,"Please provide a number"))
        lapply(1:input$persNum, function(i) {
          fluidRow(
            column(2,textInput(inputId = paste0("persInitial",i), label = paste0("Initial of Person ", i))), 
            column(2,textInput(inputId = paste0("persSurname", i), label = paste0("Surname of Person ", i))), 
            column(2,awesomeCheckbox(inputId = paste0("sic", i), label = "Is person SIC?"), style = 'margin-top:32px'), 
            column(2,selectInput(inputId = paste0("duration", i), label = "Duration on trip", choices = c("Whole trip", "First Half", "Second Half"))),
            column(2,textInput(inputId = paste0("external", i), label = "External Body")),
            column(2,textInput(inputId = paste0("project", i), label = "Project Code")),
            align = "center")
        })
      })
      print(input$persInitial) 
    } else {
      output$personnel = renderUI({return(NULL)})
    } 
    
  })
  
  observe({
    
    if(! is.na(input$objNum) & input$objNum > 0){
      output$objectives = renderUI({
        validate(
          need(input$objNum,"Please provide a number"))
        lapply(1:input$objNum, function(i) {
          fluidRow(textAreaInput(inputId = paste0("obj",i), label = paste0("Objective ",i)), align = "center")
        })
      })
    } else {
      output$personnel = renderUI({return(NULL)})
    } 
    
  })
  
  observe({
    if(! is.na(input$projNum) & input$projNum > 0){
      output$projects = renderUI({
        validate(
          need(input$projNum,"Please provide a number"))
        lapply(1:input$projNum, function(i) {
          fluidRow(
            column(3,),
            column(3,textInput(inputId = paste0("proj",i), label = paste0("Project ", i, " Code"))),
            column(3,numericInput(inputId = paste0("projDays",i), label = paste0("Project ", i, " Anticipated Days"), value = NA)),
            column(3,),
          align = "center")
        })
      })
    } else {
      output$personnel = renderUI({return(NULL)})
    } 
  })
  
  updateSelectizeInput(session, 'depPort', choices = locs %>% filter(Country == "GB") %>% pull(NameWoDiacritics), server = TRUE)
  updateSelectizeInput(session, 'halfPort', choices = locs %>% filter(Country == "GB") %>% pull(NameWoDiacritics), server = TRUE) 
  updateSelectizeInput(session, 'arrPort', choices = locs %>% filter(Country == "GB") %>% pull(NameWoDiacritics), server = TRUE)

  output$report <- downloadHandler(
    filename = "report.doc",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      persdeets = list()
      for(i in 1:input$persNum) {
        if(eval(str2expression(paste0("input$sic",i)))) {sic = "(SIC)"} else {sic = ""}
        if(eval(str2expression(paste0("input$duration",i)))=="Whole trip") {duration = ""} else {duration = eval(str2expression(paste0("input$duration",i)))}
        persdeets[[i]] = 
          paste(
            paste0(eval(str2expression(paste0("input$persInitial",i))),".",eval(str2expression(paste0("input$persSurname",i)))),
                sic,
                duration,
                sep="\t")
      }
      
      # Set up parameters to pass to Rmd document
      params <- list(survey = input$survID, 
                     schedDepDate = input$schedDates[1],
                     schedArrDate = input$schedDates[2],
                     halfDate = input$halfDate, 
                     actDepDate = input$actDates[1],
                     actArrDate = input$actDates[2],
                     personnel = persdeets,
                     depPort = input$depPort,
                     halfPort = input$halfPort,
                     arrPort = input$arrPort,
                     objNum = input$objNum
                     )
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
  
}