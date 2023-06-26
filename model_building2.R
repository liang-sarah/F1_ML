load("C://Users//waliang//Documents//UCSB//third year//pstat 131//eda.rda")


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

# omit the small amount of missing values left
merge_con3 <- merge_con3 %>%
  na.omit()


merge_con3$constructorRef <- factor(merge_con3$constructorRef, exclude=NA)
merge_con3$con_nation <- factor(merge_con3$con_nation, exclude=NA)
merge_con3$circuitRef <- factor(merge_con3$circuitRef, exclude=NA)
merge_con3$circ_country <- factor(merge_con3$circ_country, exclude=NA)

# split into training and testing, strata on response variables
con_split <- initial_split(merge_con3, prop = 0.7, strata = con_pos)
con_train <- training(con_split)
con_test <- testing(con_split)

# driv_split <- initial_split(merge_driv4, prop = 0.7, strata =driv_pnts)
# driv_train <- training(driv_split)
# driv_test <- testing(driv_split)





# RECIPES AND K-FOLD CROSS VALIDATION SET
con_folds <- vfold_cv(con_train, v = 10)


con_rec <-
  recipe(con_pos ~ constructorRef+con_pnts+con_wins+con_nation+season+
           round+circuitRef+circ_country, data = con_train) %>%
  
  # omit the small amount of missing values left
  step_naomit(all_predictors())%>%
  
  # there are a hundreds of different constructors and circuits, so we need to collapse the less common ones into an other category
  step_other(constructorRef, threshold=.1) %>%
  step_other(con_nation, threshold=.1) %>%
  step_other(circuitRef, threshold=.1) %>%
  step_other(circ_country, threshold=.1) %>%
  step_naomit()%>%
  
  
  # dummy code categorical variables
  step_dummy(all_nominal_predictors()) %>%
  
  # remove variables (likely the dummy coded ones) that only contain a single value
  step_zv(all_predictors())%>%
  # step_novel(all_nominal_predictors())%>%
  # step_unknown(all_nominal_predictors())%>%
  
  # normalizing
  step_center(all_predictors()) %>%
  step_scale(all_predictors())

# prep and bake
prep(con_rec) %>%
  bake(new_data = con_train)


boost_model <- boost_tree(trees=tune(),
                          learn_rate=tune(),
                          min_n=tune(),
                          engine="xgboost", mode="regression")


con_boostwflow <- workflow() %>%
  add_model(boost_model) %>%
  add_recipe(con_rec)


boost_grid <- grid_regular(trees(range = c(5, 200)), learn_rate(range = c(0.01,0.1), trans = identity_trans()), min_n(range = c(40, 60)), levels = 5)

install.packages("xgboost")


con_boosttune <- tune_grid(
  con_boostwflow,
  resamples = con_folds,
  grid = boost_grid,control = control_grid(verbose = TRUE))





lm_model<- linear_reg(engine="lm")


# POLYNOMIAL REGRESSION
# tune degree on the numerical variables (degree on these variables will amplify their effect)
# ex. a change in points and wins will affect constructor position more than normal
con_polyrec <- con_rec %>%
  step_poly(con_pnts,con_wins,season,round,degree=tune())

# driv_polyrec <- driv_rec %>%
#   step_poly(driv_positionOrder, laps,fastestLapTime_rank,fastestLapSpeed,driv_start_pos, avg_lap_time, avg_lap_pos, driv_standing ,driv_wins, season, round,dob, degree=tune())

poly_model <- linear_reg(mode="regression",
                         engine="lm")


# K NEAREST NEIGHBORS 
# tune neighbors
knn_model <- nearest_neighbor(neighbors = tune(),
                              mode="regression",
                              engine="kknn")


# ELASTIC NET LINEAR REGRESSION
# tune penalty and mixture
en_model <- linear_reg(mixture=tune(),
                       penalty=tune(),
                       mode="regression",
                       engine="glmnet")


# ELASTIC NET W/ LASSO
# tune penalty, set mixture to 1 for lasso penalty
en_lasso <- linear_reg(penalty=tune(),
                       mixture=1,
                       mode="regression",
                       engine="glmnet")


# ELASTIC NET W/ RIDGE
# tune penalty, set mixture to 0 for ridge penalty
en_ridge <- linear_reg(penalty=tune(),
                       mixture=0,
                       mode="regression",
                       engine="glmnet")



con_lmwflow <- workflow() %>%
  add_model(lm_model) %>%
  add_recipe(con_rec)

# driv_lmwflow <- workflow()%>%
#   add_model(lm_model)%>%
#   add_recipe(driv_rec)



# POLYNOMIAL REGRESSION
con_polywflow <- workflow() %>%
  add_model(poly_model) %>%
  add_recipe(con_polyrec)

# driv_polywflow <- workflow()%>%
#   add_model(poly_model)%>%
#   add_recipe(driv_polyrec)


# K NEAREST NEIGHBORS 
con_knnwflow <- workflow() %>%
  add_model(knn_model) %>%
  add_recipe(con_rec)

# driv_knnwflow <- workflow()%>%
#   add_model(knn_model)%>%
#   add_recipe(driv_rec)


# ELASTIC NET LINEAR REGRESSION
con_enwflow <- workflow() %>%
  add_model(en_model) %>%
  add_recipe(con_rec)

# driv_enwflow <- workflow() %>%
#   add_model(en_model) %>%
#   add_recipe(driv_rec)


# ELASTIC NET W/ LASSO
con_lassowflow <- workflow() %>%
  add_model(en_lasso) %>%
  add_recipe(con_rec)

# driv_lassowflow <- workflow() %>%
#   add_model(en_lasso) %>%
#   add_recipe(driv_rec)


# ELASTIC NET W/ RIDGE
con_ridgewflow <- workflow() %>%
  add_model(en_ridge) %>%
  add_recipe(con_rec)




poly_grid <- grid_regular(degree(range=c(1,5)),
                          levels=5)

# K NEAREST NEIGHBORS 
# range neighbors from 1 to 15
knn_grid <- grid_regular(neighbors(range=c(1,15)),
                         levels=5)


# ELASTIC NET LINEAR REGRESSION
en_grid <- grid_regular(penalty(range=c(0.01,3), trans=identity_trans()),
                        mixture(range=c(0,1)),
                        levels=10)


# ELASTIC NET W/ LASSO and
# ELASTIC NET W/ RIDGE
lasso_ridge_grid <- grid_regular(penalty(range=c(0.01,3),
                                         trans=identity_trans()), levels=10)




con_polytune <- tune_grid(
  con_polywflow,
  resamples = con_folds,
  grid = poly_grid, control = control_grid(verbose = TRUE))

# driv_polytune <- tune_grid(
#   driv_polywflow,
#   resamples = driv_folds,
#   grid = poly_grid,control = control_grid(verbose = TRUE))



# K NEAREST NEIGHBORS
con_knntune <- tune_grid(
  con_knnwflow,
  resamples = con_folds,
  grid = knn_grid,control = control_grid(verbose = TRUE))

# driv_knntune <- tune_grid(
#   driv_knnwflow,
#   resamples = driv_folds,
#   grid = knn_grid,control = control_grid(verbose = TRUE))



# ELASTIC NET
con_entune <- tune_grid(
  con_enwflow,
  resamples = con_folds,
  grid = en_grid,control = control_grid(verbose = TRUE))

# driv_entune <- tune_grid(
#   driv_enwflow,
#   resamples = driv_folds,
#   grid = en_grid,control = control_grid(verbose = TRUE))



# RIDGE REGRESSION
con_ridgetune <- tune_grid(
  con_ridgewflow,
  resamples = con_folds,
  grid = lasso_ridge_grid,control = control_grid(verbose = TRUE))

# driv_ridgetune <- tune_grid(
#   driv_ridgewflow,
#   resamples = driv_folds,
#   grid = lasso_ridge_grid,control = control_grid(verbose = TRUE))
# 
# 

# LASSO REGRESSION
con_lassotune <- tune_grid(
  con_lassowflow,
  resamples = con_folds,
  grid = lasso_ridge_grid,control = control_grid(verbose = TRUE))




con_lmfit <- fit_resamples(con_lmwflow, resamples=con_folds)




save(con_split, con_train, con_test, con_folds, con_rec, lm_model, con_polyrec,
     poly_model, knn_model, en_model, en_lasso, en_ridge, rf_model, boost_model,
     con_lmwflow, con_polywflow, con_knnwflow, con_enwflow, con_lassowflow,
     con_ridgewflow, con_rfwflow, con_boostwflow, poly_grid, knn_grid, en_grid, lasso_ridge_grid,
     con_rfgrid, boost_grid, con_polytune, con_knntune, con_entune, con_ridgetune, 
     con_lassotune, con_boosttune, con_lmfit,
     file="model_building.rda")









