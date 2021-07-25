# NBADraftModel 

College Prospects NBA stats prediction using Machine Learning in R.
Developed by Matheus Gonzaga

## Introduction

This repository contains code and data relative to a set of XGBoost models for predicting the NBA Stats of current draft prospects.
There are four R Scripts which do the entire process of getting the NBA data for current players, importing the college dataset (scrapped from barttorvik.com), cleaning the data,
modelling, validation and prediction of the 2021 Draft Class Players. 

## Packages Used
- Tidyverse
- Tidymodels
- XGBoost
- NBAr
- gt

## Structure

- The four main scripts are:
  - 1_clean_college_data: consists of the college data cleaning and consolidation;
  - 2_get_nba_data: consists of the scrapping of NBA data (using the NBAr package by PatrickChodowski) from nba.com/stats, and its cleaning and consolidation
  - 3_modelling: consists of the modelling itself, the model validation and the prediction of the 2021 Draft Class (generating the files 'model_metrics.csv' and 
  '2021draft_projections.csv'
  - 4_visualization: generation of tables with the model metrics and the draft class prediction (the files metrics_table.png and projections.png are this script's outputs)
- The data folder contains two folders:
  - raw: contains all BartTovik college players data from 2010 to 2020, a dataset with Career LEBRON (metric by bball-index.com) from current players and a file from where
  the names of 2021 draft college prospects were get.
  - intermediate: contains the cleaned and consolidated college and NBA data.


## Modelling

For the modelling, I used eXtreme Gradient Boosting for using college stats from his last college season to predict to predict a player's skill in 10 different variables
associated with its quality of play in the NBA. I've tried to be the less context biased as possible, so stats highly dependent on usage, 
like point per game were not modelled. The 10 final NBA variables predicted were:
  - Assist %
  - Offensive Rebound %
  - Defensive Rebound % 
  - Drive Points Per Possession
  - Catch and Shoot 3PT%
  - Pull Up 3PT%
  - Restricted Area FG%
  - Floater Range FG%
  - Mid Range FG%
  - Opponent Rim FG%

Each of the 10 models fitted use a different set of college stats related to the skill in question. E.g. for predicting a players Catch and Shoot 3PT%, his number of attempts 
from three point range in college, his efficiency at them, his FT% and Mid Range% were valuable inputs, alongside his role in college Basketball, Number of years in college
and height. 
For the model validation, the strategy was a time split cross validation. First, the models were training using data from players drafted from 2010 to 2013, and tested on 2014 draft 
class data. In sequence, the training set got from 2010 to 2014, and the test set was the 2015 class, etc. The data used for the final models used players from the 2010 to
2017 drafts. The metrics calculated were MAE and MAPE for each time split. For the variables associated with scoring efficiency, the MAPE values were lower than 9%, whereas the
error was larger for the AST% , OREB% and DREB% models (from 15% to 30% MAPE).

## Points for future improvement

- For now the model is restricted to College Players;
- The only defensive metric present is relative to Rim Protection - there's no Perimeter Defense stat;
- The model can't identify superstar potential, because they are the outlier, and naturally a regression model predicts the mean;
- Adding a impact metric (like LEBRON) would help to identify a player possible impact on court outside of these variables;
- Even though the model was relatively accurate, FG% stats in the NBA have a small variance, thus, little errors relative to the median might be significant in the 
basketball context
- The validation strategy has an issue - even though it does use only players drafted in the past to predict a future draft class, the train set players stats are relative
to their carreer up to the 2020-21 season, so the validation isn't 100% realistic.



## 
