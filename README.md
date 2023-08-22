# F1_ML
The goal of this project is to build a machine learning model to predict the Formula One World Constructors’ Championship Standings for the upcoming 2023 season.


The following listed files include all my hard code and model building steps. My entire project, including the thorough thought and work process, is neatly explained and presented [here](https://liang-sarah.github.io/F1_ML).


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

Some of these packages are necessary for the model building process, while others are for concise and convenient coding and visual presentation experience.


### read_data.R
R script file `read_data.R` includes code used to read in csv files. Variables assigned to the data sets are saved in `read_data.rda` for further use.


### modify_data.R
`modify_data.R` includes code used to manipulate and join the data sets. Inital data cleaning is also executed in this R script file, which can range from converting timestamps into workable numeric variables to streamlining several related variables into one useful parameter. Variables assigned to the new cleaned and finalized data sets are saved in `modify_data.rda`.



### eda.R
Exploratory data analysis code is included in R script file `eda.R`. This file includes code used to do further cleaning with a focus on missing data. This file also includes some visual exploratory data analysis, mostly looking at possible surface level trends and relationships between variables, which provides some good beginning insight before considering potential models. The plots 
