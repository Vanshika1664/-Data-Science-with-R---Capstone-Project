require(tidyverse)
require(httr)

# 1. Load city forecast weather data
get_weather_forecast_by_cities <- function(city_names){
  city <- c(); temperature <- c(); visibility <- c(); humidity <- c(); wind_speed <- c()
  weather <- c(); seasons <- c(); hours <- c(); forecast_date <- c()
  weather_labels <- c(); weather_details_labels <- c()
  
  for (city_name in city_names){
    url <- 'https://api.openweathermap.org/data/2.5/forecast'
    api_key <- "eeadb0857cce348954f4217a0e6fd15c"  # Use your own API key
    query <- list(q = city_name, appid = api_key, units = "metric")
    response <- GET(url, query = query)
    json <- content(response, as = "parsed")
    
    if (!is.null(json$list)) {
      for (result in json$list) {
        forecast_datetime <- result$dt_txt
        hour <- as.numeric(strftime(forecast_datetime, "%H"))
        month <- as.numeric(strftime(forecast_datetime, "%m"))
        season <- case_when(
          month %in% 3:5 ~ "SPRING",
          month %in% 6:8 ~ "SUMMER",
          month %in% 9:11 ~ "AUTUMN",
          TRUE ~ "WINTER"
        )
        city <- c(city, city_name)
        weather <- c(weather, result$weather[[1]]$main)
        temperature <- c(temperature, result$main$temp)
        visibility <- c(visibility, result$visibility)
        humidity <- c(humidity, result$main$humidity)
        wind_speed <- c(wind_speed, result$wind$speed)
        forecast_date <- c(forecast_date, forecast_datetime)
        seasons <- c(seasons, season)
        hours <- c(hours, hour)
        
        # Labels
        weather_labels <- c(weather_labels,
                            paste0("<b><a href=''>", city_name, "</a></b><br><b>", result$weather[[1]]$main, "</b><br>")
        )
        weather_details_labels <- c(weather_details_labels,
                                    paste0("<b><a href=''>", city_name, "</a></b><br><b>", result$weather[[1]]$main, "</b><br>",
                                           "Temperature: ", result$main$temp, " C<br>",
                                           "Visibility: ", result$visibility, " m<br>",
                                           "Humidity: ", result$main$humidity, " %<br>",
                                           "Wind Speed: ", result$wind$speed, " m/s<br>",
                                           "Datetime: ", forecast_datetime, "<br>")
        )
      }
    }
  }
  
  return(tibble(CITY_ASCII = city, WEATHER = weather, TEMPERATURE = temperature,
                VISIBILITY = visibility, HUMIDITY = humidity, WIND_SPEED = wind_speed,
                SEASONS = seasons, HOURS = hours, FORECASTDATETIME = forecast_date,
                LABEL = weather_labels, DETAILED_LABEL = weather_details_labels))
}

# 2. Load model from CSV
load_saved_model <- function(model_name) {
  model <- read_csv(model_name) %>%
    mutate(Variable = gsub('"', '', Variable))
  setNames(model$Coef, model$Variable)
}

# 3. Predict using model
predict_bike_demand <- function(TEMPERATURE, HUMIDITY, WIND_SPEED, VISIBILITY, SEASONS, HOURS){
  model <- load_saved_model("model.csv")
  
  weather_terms <- model['Intercept'] +
    TEMPERATURE * model['TEMPERATURE'] +
    HUMIDITY * model['HUMIDITY'] +
    WIND_SPEED * model['WIND_SPEED'] +
    VISIBILITY * model['VISIBILITY']
  
  season_terms <- sapply(SEASONS, function(season) model[[season]])
  hour_terms <- sapply(as.character(HOURS), function(h) model[[h]])
  
  prediction <- as.integer(weather_terms + season_terms + hour_terms)
  prediction[prediction < 0] <- 0
  return(prediction)
}

# 4. Categorize levels
calculate_bike_prediction_level <- function(predictions){
  case_when(
    predictions <= 1000 ~ "small",
    predictions < 3000 ~ "medium",
    TRUE ~ "large"
  )
}

# 5. Final wrapper
generate_city_weather_bike_data <- function(){
  cities_df <- read_csv("selected_cities.csv")
  weather_df <- get_weather_forecast_by_cities(cities_df$CITY_ASCII)
  
  results <- weather_df %>%
    mutate(
      BIKE_PREDICTION = predict_bike_demand(TEMPERATURE, HUMIDITY, WIND_SPEED, VISIBILITY, SEASONS, HOURS),
      BIKE_PREDICTION_LEVEL = calculate_bike_prediction_level(BIKE_PREDICTION)
    )
  
  cities_df %>%
    left_join(results, by = c("CITY_ASCII")) %>%
    select(CITY_ASCII, LNG, LAT, TEMPERATURE, HUMIDITY, BIKE_PREDICTION,
           BIKE_PREDICTION_LEVEL, LABEL, DETAILED_LABEL, FORECASTDATETIME)
}
