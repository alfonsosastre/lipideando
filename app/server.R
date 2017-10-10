library(shiny)

dtLipids<-data.table(
           lipidComponent=c("DOPC","DOPS","Cholesterol (ovine)","DPPC","17:0-20:4 PI(4,5)P2"),
           MW=c(786.113,810.025,386.654,734.039,1084.153)
           )

dtSelected<-data.table(lipidComponent=character(),
                       MW=numeric(),
                       conc=integer(),
                       ratio=numeric())

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  values <- reactiveValues() 

  values$dtSelected<-data.table(lipidComponent=character(),
                         MW=numeric(),
                         conc=integer(),
                         ratio=numeric())
  
  values$dtSolution<-data.table(lipidComponent=character(),
                                volume=numeric())

  values$dtLipids <- dtLipids  
  output$lipids <- DT::renderDataTable(values$dtLipids,select = "single",colnames = c("Lipid Component","MW (g/mol)"))
  
  output$modifyComponent <- renderUI({
      if(is.null(input$lipids_rows_selected))  
        return(NULL)
    
    nr = input$lipids_rows_selected
    dt <- values$dtLipids
    fluidRow(column(3,textInput(inputId = "name",label = "Lipid Component",
                                value = dt[nr]$lipidComponent)),
             column(2,textInput(inputId = "mw",label = "MW (g/mol)",
                                value = dt[nr]$MW)),
             column(2,textInput(inputId = "conc",label = "Concentration (g/l)",
                                value = 0)),
             column(2,textInput(inputId = "ratio",label = "Ratio (0-10)",
                                value = 10.0 - ifelse(nrow(values$dtSelected) > 0,sum(values$dtSelected$ratio),0))),   
             column(2,actionButton("addB","Add")))
  })

    observeEvent(input$addB,{
#      validate(
#        need(input$conc == "0", "Concentration must but a number larger than 0")
#      )
      if (input$conc == "0") {
        updateTextInput("conc")
        print("es 0")
        NULL
      }
      else {      
        values$dtSelected <- rbind(values$dtSelected,
                              data.table(
                                   lipidComponent=input$name,
                                   MW=as.numeric(input$mw),
                                   conc=as.integer(input$conc),
                                   ratio=as.numeric(input$ratio)
                               )
                           )
      }
    }) 
  
  output$tableComponent <- renderTable({
    if(nrow(values$dtSelected) == 0)
       return(NULL)
    
    dt <- values$dtSelected
    names(dt) <- c("Lipid Component","MW (g/mol)","Concentration (g/l)","Ratio (0-10)")
    dt
  })

  output$compute <- renderUI({
    if(!sum(values$dtSelected$ratio) == 10)
      return(NULL)
    
    fluidRow(column(2,textInput(inputId = "volume",label = "volume (mL)",
                                value = 0)),
             column(2,textInput(inputId = "concF",label = "C. Final (uM)",
                                value = 0)),
             column(2,actionButton("compute","Compute")))
    
  })
  
  observeEvent(input$compute,{
                volume <- as.numeric(input$volume)
                concF  <- as.numeric(input$concF)
                factor = 0.0001
                print(is.data.table(dt))
                dt <- as.data.table(values$dtSelected)
                dt <- dt[,volumeF := volume * concF * ratio * MW / conc * factor]
                values$dtSolution <- dt[,.(lipidComponent,volumeF)]
               })

    output$tableSolution <- renderTable({
    if(nrow(values$dtSolution) == 0)
      return(NULL)
      
    dt <- values$dtSolution
    names(dt) <- c("Lipid Component","Volume (uL)")
    dt
  })
  
  observeEvent(input$dbLipids,{
    inFile <- input$dbLipids
    if(is.null(inFile))
      return(NULL)
    
    values$dtLipids <- fread(input=inFile$datapath,sep="\t",header = FALSE)   
    names(values$dtLipids) <- c("lipidComponent","MW")
    values$dtLipids
  })  
      

})
