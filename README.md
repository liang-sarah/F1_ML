# F1_ML
The goal of this project is to build a machine learning model to predict the Formula One World Constructors’ Championship Standings for the upcoming 2023 season.


The following listed files include all my hard code and model building steps. My entire project, including the thorough thought and work process, is explained and presented [here](https://liang-sarah.github.io/F1_ML).

## read_data.R
R script file `read_data.R` includes code used to read in csv files. Variables assigned to the data sets are saved in `read_data.rda` for further use.


## modify_data.R
`modify_data.R` includes code used to manipulate and join the data sets. Cleaning of the data is also executed in this R script file, which can range from converting timestamps into workable numeric variables, to streamlining several related variables into one useful parameter. Variables assigned to the new cleaned and finalized data sets are saved in `modify_data.rda`.



## eda.R
Exploratory data analysis code is included in R script file `eda.R`. This file includes code used to address missing data,
