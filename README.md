#  Data Science with R - Capstone Project
🚲 Bike Sharing Demand Prediction
This repository contains a comprehensive analysis and machine learning pipeline for predicting hourly bike rental demand using the Bike Sharing Dataset. The goal is to explore, model, and evaluate the key drivers of demand to build robust and interpretable regression models.

📌 Project Objectives
  1. Clean and preprocess the dataset.
  
  2. Explore data patterns through EDA (Exploratory Data Analysis).
  
  3. Build and compare five different regression models:
  
  4. Simple Linear Regression
  
  5. Polynomial Regression
  
  6. Polynomial + Interaction Terms
  
  7. Ridge Regression
  
  8. Elastic Net Regression
  
  9. Evaluate models using RMSE and R².
  
  10. Report the best-performing model and insights.

📊 Dataset Overview
  1. Source: UCI Machine Learning Repository
  
  2. Target Variable: RENTED_BIKE_COUNT
  
  Features Include:
  
    Numerical: TEMPERATURE, HUMIDITY, WIND_SPEED, RAINFALL, etc.
    
    Categorical: SEASONS, HOLIDAY, FUNCTIONING_DAY
    
    Datetime: DATE, HOUR


🛠️ Tools & Technologies
  Language: R
  
  Packages:
  
  tidyverse – data manipulation and visualization
  
  tidymodels – modeling framework
  
  ggplot2 – data visualization
  
  recipes – feature engineering
  
  glmnet – regularized regression (Ridge/Elastic Net)
  
  yardstick – model evaluation

📌 Key Insights
  Temperature and Humidity are the most influential factors.
  
  Polynomial and interaction terms improve model accuracy significantly.
  
  Regularization helps mitigate multicollinearity and overfitting.

  📁 Project Structure
  seoul-bike-sharing/
├── data/                # Cleaned dataset
├── eda/                 # EDA plots and analysis
├── models/              # Model scripts
├── results/             # Evaluation outputs
├── final_report.Rmd     # Complete analysis report
├── presentation.pptx    # Final presentation slides
└── README.md            # Project overview

🙋‍♀️Author
Vanshika Tomar


