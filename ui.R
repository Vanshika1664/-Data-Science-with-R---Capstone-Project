# Load required libraries
require(shiny)
require(leaflet)

# Create a RShiny UI
shinyUI(
  fluidPage(padding = 5,
            titlePanel("Bike-sharing demand prediction app"),
            sidebarLayout(
              mainPanel(
                leafletOutput("city_bike_map", height = 1000)
              ),
              sidebarPanel(
                selectInput("selected_city", "Select City",
                            choices = c("All", "Seoul", "New York", "Paris", "London", "Suzhou")),
                plotOutput("weather_plot"),
                plotOutput("bike_plot")
              )
            )
  )
)

