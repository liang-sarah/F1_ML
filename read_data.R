library(tidyverse)
library(tidymodels)
library(kknn)
library(ggplot2)
library(corrplot)
library(ggthemes)
library(kableExtra)
library(gridExtra)
library(parsnip)
library(recipes)
library(magrittr)
library(workflows)
library(glmnet)
library(themis)
library(ranger)
library(vip)
library(naniar)
library(visdat)
library(dplyr)
library(ISLR)
set.seed(2536)

circuit <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\circuits.csv")
constructor_results <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\constructor_results.csv")
constructor_standings <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\constructor_standings.csv")
constructors <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\constructors.csv")
driver_standings <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\driver_standings.csv")
drivers <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\drivers.csv")
lap_times <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\lap_times.csv")
pit_stops <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\pit_stops.csv")
qualifying <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\qualifying.csv")
races <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\races.csv")
results <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\results.csv")
seasons <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\seasons.csv")
sprint_results <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\sprint_results.csv")
status <- read.csv("C:\\Users\\waliang\\Documents\\R_data\\pstat131\\f1db_csv\\status.csv")


save(circuit,constructor_results,constructor_standings,constructors,driver_standings,
     drivers,lap_times,pit_stops,qualifying,races,results,seasons,sprint_results,status, file="read_data.rda")