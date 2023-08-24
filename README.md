# F1_ML
The goal of this project is to build a machine learning model to predict the Formula One World Constructors’ Championship Standings for the upcoming 2023 season.


The following listed files include all my hard code and model building steps. My entire project, including the thorough thought and work process, is neatly explained and presented [here](https://liang-sarah.github.io/F1_ML).

<br />

#### R packages used:
<table border = "0">
  <tr>
    <td>tidyverse</td> <td>tidymodels</td> <td>parsnip</td> <td>kknn</td> <td>recipes</td> <td>workflows</td> <td>glmnet</td> <td>magrittr</td><td>ranger</td>
  </tr>
  <tr>
    <td>naniar</td> <td>visdat</td> <td>dplyr</td> <td>ggplot2</td> <td>ggthemes</td> <td>corrplot</td>
    <td>vip</td> <td>themis</td> <td>kableExtra</td> <td>ISLR</td>
  </tr>
</table>

Some of these packages are necessary for the model building process, while others are for concise and convenient coding and visual presentation experience. <br />

<br />
<br />
<br />

The following files are a representation of my overall workflow. I put raw code in `.R` script files and saved important arguments or variables for later use in the correspondingly named `.rda` files.

<br />

### `read_data.R`
R script file `read_data.R` includes code used to read in csv files.

<br />

### `modify_data.R`
This `modify_data.R` file includes code used to manipulate and join the data sets. Inital data cleaning is also executed in this R script file, which can range from converting timestamps into workable numeric variables to streamlining several related variables into one useful parameter.

<br />


### `eda.R`
Exploratory data analysis code is included in R script file `eda.R`. This file includes code used to do further cleaning with a focus on missing data. This file also includes some visual exploratory data analysis, mostly looking at possible surface level trends and relationships between variables, which provides some good beginning insight before considering potential models.

<br />

### `model_building2.R`
This file includes steps to set up the machine learning models. This involves training and testing data splits and building a recipe with the desired response variable and predictors. Using the `recipe()` tidymodels function allows us to dummy code categorical predictors and impute missing values in the predictors within the step of creating the recipe. I further set up k-fold cross validation and apply different machine learning models to the recipe. I developed the following models to have a thorough discussion of the truly best fitting model.
<table border = "0">
  <tr>
    <td>linear</td> <td>polynomial regression</td> <td>k nearest neighbors</td> <td>elastic net linear regression</td>
  </tr>
  <tr>
    <td>elastic net with lasso regression</td> <td>elastic net with ridge regression</td> <td>random forest</td>
  </tr>
</table>
<br />

To build the models, we use the following steps:
- set up each model with tuning parameter, the engine, and regression mdoe
- set up a `workflow()` with each model and the recipe
- set up a tuning grid with `grid_regular()` and levels for tuning the parameters
- tune each model with `tune_grid()` using the corresponding workflow, k-fold cross validation, and tuning grid
- collect __root mean squared error (RMSE)__ metric of tuned models and find the lowest RMSE for each model


<br />
