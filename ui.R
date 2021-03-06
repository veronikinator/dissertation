#CSS code for the console box ui
css<- "div.box {
      width: 250px;
      border: 2px solid rgb(191, 0, 55);
padding: 2px;
margin: 2px;
}"




# Define UI for application that draws a histogram
shinyUI(

  navbarPage("Time Series Analysis App", id = "tabs",
    
    tags$head(
      tags$style(type="text/css", css)
      ),
    
#     headerPanel("Time Series Analysis App"),
    
    tabPanel("Data",
        sidebarPanel(
          fileInput('data', 'Choose file to upload', accept = c('text/csv',
                                                              'text/comma-separated-values',
                                                              'text/tab-separated-values',
                                                              'text/plain',
                                                              '.csv',
                                                              '.tsv')
                    ),
          uiOutput("DataParams")
          #checkboxGroupInput("paramsData", "Choose columns", choices = NULL)
        ),
      mainPanel(
        DT::dataTableOutput('contents'),
        dygraphOutput("dataPlot")
      )
    ),
    tabPanel("Arima",
               sidebarPanel(
                 numericInput("arimaPeriod", "Choose a number of periods to forecast:", 10),
                 selectInput( "arimaModel", "Choose model:", choices = c("Auto Arima", "Manual")
                              ),
                 conditionalPanel("input.arimaModel=='Auto Arima'",
                                  selectInput('paramsAutoArima', 'Parameters:', choices = NULL),
                                  checkboxGroupInput("xregParamsAutoArimax", "Choose explanatory variables:", choices = NULL)),
                 conditionalPanel("input.arimaModel=='Manual'",
                                  textInput("arimaOrder", "Choose the order of the model:", "0,0,0"),
                                  selectInput('paramsArima', 'Parameters:', choices = NULL),
                                  checkboxGroupInput("xregParamsArimax", "Choose explanatory variables:", choices = NULL)),
                 actionButton("analyseArima", label = "Analyse"),
                 conditionalPanel("input.analyseArima > 0",
                                  tags$br(),
                                  tags$div(class="box", textOutput("console")))
                 ),
             mainPanel(
               plotOutput("arimaPlot"),
               tags$h4("Forecast Table"),
               DT::dataTableOutput('arimaForecast'),
               plotOutput("arimaForecastPlot")
               )
      ),
    tabPanel("State-Space",
               sidebarPanel(
                 selectInput("StateModel", "Choose model:", choices=c("Structural", "dlm", "Autoregressive")),
                 numericInput("statePeriod", "Choose a number of periods to forecast:", 10),
                 conditionalPanel("input.StateModel=='Structural'",
                                  selectInput("paramsState", "Choose columns", choices = NULL),
                         
                                  selectInput("StateType", "Choose type:", choices=c("level", "trend", "BSM"), selected="level")
                         ),
                 conditionalPanel("input.StateModel=='Autoregressive'",
                                  checkboxGroupInput("paramsMARSS", "Choose columns", choices = NULL)
                                  ),
                 conditionalPanel("input.StateModel=='dlm'",
                                  #selectInput("typeDlm", "Model type:", choices = c("Polynomial", "Regression")),
                                  selectInput("typeDlm", "Model type:", choices = c("Manual", "Constant Coefficients", "Time-varying coefficients")),
                                  selectInput("paramsDlm", "Choose columns", choices = NULL),
                                  conditionalPanel("input.typeDlm!='Manual'",
                                                   selectInput("explainDlm", "Choose explanatory variable", choices = NULL)),
                                  textInput("dlmParamsDv", "Choose variance of the observation noise, dV:", "0"),
                                  textInput("dlmParamsDw", "Choose variance of the observation noise, dW:", "0"),
                                  textInput("dlmParamsM0", "Choose expected value of the pre-sample state vector, m0:", "0"),
                                  textInput("dlmParamsC0", "Choose variancce of the pre-sample state vector, c0:", "0"),
                                  conditionalPanel("input.typeDlm=='Manual'",
                                                   #numericInput("dlmM0", "M0:", 0),
                                                   numericInput("dlmPolyOrder", "Polynomial order:", 1),
                                                   radioButtons("seasType", label = "Type of seasonal model",
                                                                choices = c("Seasonal", "Fourier form", "No seasonality"), 
                                                                selected = "No seasonality"),
                                                   conditionalPanel("input.seasType=='Fourier form'",
                                                                    numericInput("trigHarmonics", "Number of harmonics:", 1),
                                                                    numericInput("trigPeriod", "Period:", 1),
                                                                    numericInput("trigVarNoise", "Variance of observation noise:", 1),
                                                                    numericInput("trigVarSys", "Variance of system noise:", 0)
                                                                    ),
                                                   conditionalPanel("input.seasType=='Seasonal'",
                                                                    numericInput("seasFreq", "Frequency:", 2),
                                                                    numericInput("seasVarNoise", "Variance of observation noise:", 1),
                                                                    numericInput("seasVarSys", "Variance of system noise:", 0)
                                                   )
                                                   )
                                
                 ),
                 actionButton("analyseState", label = "Analyse"),
                 conditionalPanel("input.analyseState > 0",
                                  tags$br(),
                                  tags$div(class="box", textOutput("consoleState")))
                 ),
             mainPanel(
               conditionalPanel("input.StateModel=='Autoregressive'",
                                uiOutput("MARSSplotData")),
               conditionalPanel("input.StateModel!='Autoregressive'",
                                plotOutput("stateFittedPlot")),
               DT::dataTableOutput('stateForecast'),
               conditionalPanel("input.StateModel=='Autoregressive'",
                                uiOutput("MARSSForecastPlot")),
               conditionalPanel("input.StateModel!='Autoregressive'",
                                plotOutput("stateForecastPlot"),
                                plotOutput("stateDiag")
                                ))
    )
))
