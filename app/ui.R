library(shiny)
library(data.table)
library(DT)

library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Lipideando"),
  dashboardSidebar(),
  dashboardBody(
    box(title = "Selection",width = 4,
        DT::dataTableOutput("lipids"),
        fileInput('dbLipids', 'Choose file with lipids',accept = c('.csv'))
    ),
    box(title = "Products",width=8,
        uiOutput("modifyComponent"),
        tableOutput("tableComponent")
    ),
    box(title = "Calculation",width=8,
        uiOutput("compute"),
        tableOutput("tableSolution")
    )
  )
)

