# Load required libraries
require(shiny)
require(ggplot2)
require(leaflet)
require(tidyverse)
require(httr)
require(scales)

# Import prediction functions
source("model_prediction.R")

shinyServer(function(input, output){
  
  # Load city metadata
  cities <- read_csv("selected_cities.csv")
  
  # Generate weather and prediction data
  city_weather_bike_df <- generate_city_weather_bike_data()
  
  # Create summary of each city with max bike prediction
  cities_max_bike <- city_weather_bike_df %>%
    group_by(CITY_ASCII) %>%
    summarise(
      LAT = first(LAT),
      LNG = first(LNG),
      LABEL = first(LABEL),
      DETAILED_LABEL = first(DETAILED_LABEL),
      max_bike = max(BIKE_PREDICTION)
    ) %>%
    mutate(size = case_when(
      max_bike < 2000 ~ "small",
      max_bike < 4000 ~ "medium",
      TRUE ~ "large"
    ))
  
  # Color legend
  color_levels <- colorFactor(c("green", "yellow", "red"),
                              levels = c("small", "medium", "large"))
  
  # Render the leaflet map
  output$city_bike_map <- renderLeaflet({
    if (input$selected_city == "All") {
      leaflet(data = cities_max_bike) %>%
        addTiles() %>%
        addCircleMarkers(
          lat = ~LAT, lng = ~LNG,
          color = ~color_levels(size),
          radius = 10,
          popup = ~LABEL
        )
    } else {
      city_data <- cities_max_bike %>% filter(CITY_ASCII == input$selected_city)
      leaflet(data = city_data) %>%
        addTiles() %>%
        addCircleMarkers(
          lat = ~LAT, lng = ~LNG,
          color = ~color_levels(size),
          radius = 10,
          popup = ~DETAILED_LABEL
        )
    }
  })
  
  # Render weather plot
  output$weather_plot <- renderPlot({
    if (input$selected_city != "All") {
      df <- city_weather_bike_df %>% filter(CITY_ASCII == input$selected_city)
      ggplot(df, aes(x = as.numeric(format(as.POSIXct(FORECASTDATETIME), "%H")), y = TEMPERATURE)) +
        geom_line(color = "steelblue", size = 1) +
        labs(title = paste("Temperature in", input$selected_city),
             x = "Hour", y = "Temperature (°C)") +
        theme_minimal()
    }
  })
  
  # Render bike prediction plot
  output$bike_plot <- renderPlot({
    if (input$selected_city != "All") {
      df <- city_weather_bike_df %>% filter(CITY_ASCII == input$selected_city)
      ggplot(df, aes(x = as.numeric(format(as.POSIXct(FORECASTDATETIME), "%H")), y = BIKE_PREDICTION)) +
        geom_line(color = "darkred", size = 1) +
        labs(title = paste("Predicted Bike Demand in", input$selected_city),
             x = "Hour", y = "Predicted Bike Count") +
        theme_minimal()
    }
  })
})
