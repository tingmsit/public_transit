#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet) 
library(tidyverse)
library(leaflet.extras) 
library(shinydashboard)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Rideshare Map"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           leafletOutput("dataMap", height = '80vh')
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    ride_austin <- reactive({
        
        df 
    })
    
    output$dataMap <- renderLeaflet({
        
        # Use leaflet to make map using data filtered with filt_chem variable above
        leaflet(data = ride_austin()) %>%
            # Use generic basemap 'tiles'
            addTiles() %>%
            addHeatmap(lng = ~end_location_long, lat = ~end_location_lat,
                       blur = 25,
                       max = 200,
                       radius = 50)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

