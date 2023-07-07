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
library(rgdal)
library(sp)
library(sf)
library(plotly)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Rideshare Map"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectizeInput('dayInput', 'Select days of week:',
                           choices = unique(rideshare$day),
                           multiple = T,
                           selected = unique(rideshare$day)),
            
            sliderInput('monthInput', 'Select months:',
                        min = 1,
                        max = 12,
                        value = c(1, 12)),
            
            sliderInput('hourInput', 'Select hours of day:',
                        min = 0,
                        max = 23,
                        value = c(0, 23)),
            
            selectInput('coordLocation', 'Select coordinates:', 
                        choices = c('Pick-Up', 'Drop-Off')),
            
            downloadButton('downLoad', 'Download Filtered Dataset')
        ),

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(type = 'tabs',
                        tabPanel('Heatmap', leafletOutput('dataMap', height = '80vh')),
                        tabPanel('Daily', plotlyOutput('dayBar'), height = '80vh'))
            )
        )
    )


# Define server logic required to draw a histogram
server <- function(input, output) {
    
    filtered_data <- reactive({
        
        rideshare %>%
            filter(day %in% input$dayInput) %>%
            filter(hour %in% input$hourInput) %>%
            filter(month %in% input$monthInput)
    })
    
    data_by_day <- reactive({
        
        filtered_data() %>%
            group_by(day) %>%
            summarise(total = n())
    })
    
    coordinates <- reactive({
        # Decide which set of coordinates to use based on user input
        if (input$coordLocation == "Pick Up") {
            return(list(lng = filtered_data()$start_location_long, 
                        lat = filtered_data()$start_location_lat))
        } else {
            return(list(lng = filtered_data()$end_location_long,
                        lat = filtered_data()$end_location_lat))
        }
    })
    
    output$dataMap <- renderLeaflet({
        
        leaflet(data = filtered_data()) %>%
            addTiles() %>%
            # addMarkers(data = bus_stops,
            #            lng = bus_stops$LONGITUDE,
            #            lat = bus_stops$LATITUDE) %>%
            addHeatmap(lng = coordinates()$lng, 
                       lat = coordinates()$lat,
                       blur = 25,
                       max = nrow(filtered_data()) / (nrow(filtered_data()) * .01),
                       radius = 30) 
    })
    
    output$dayBar <- renderPlotly({
        ggplot(data = data_by_day(), aes(x = day, y = total, group = day)) +
            geom_bar(stat = 'identity') +
            ggtitle('Daily Ride Totals')
    })
    
    output$downLoad <- downloadHandler(
        filename = 'filtered_dataset.csv',
        content = function(file) {
            write.csv(filtered_data(), file)
        }
    )
}

# Run the application 
shinyApp(ui = ui, server = server)

