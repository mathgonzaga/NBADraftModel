setwd('draftmodelling')

library(tidyverse)
library(gt)

metrics <- read_csv('model_metrics.csv')

metrics %>% group_by(var) %>% summarize(MAE= mean(mae), MAPE= mean(mape)) %>% 
  transmute(Variable = var, MAE, MAPE) %>% 
  arrange(Variable) %>% gt() %>% 
  fmt_number(c('MAE', 'MAPE'),decimals = 4) %>% 
  tab_header('Draft Model Metrics','Average of all validation sets') %>%
  gtsave('metrics_table.png')

projections <- read_csv('2021draft_projections.csv') %>% 
  transmute(Player = player_name, Year = yr, `Height (Inches)` = ht,
            Role = role, `Assist %` = ast_pct,
            `Off Rebound %` = oreb_pct,
            `Def Rebound %` = dreb_pct,
            `Drive PPP` = drive_ppp,
            `Catch and Shoot 3PT%` = catchshoot_fg3_pct,
            `Pull Up 3PT%` = pullup_fg3_pct,
            `Restricted Area FG%` = ra_fg_pct,
            `Floater Range FG%` = flt_fg_pct,
            `Mid Range FG%` = midrange_fg_pct,
            `Opponent Rim FG%` = rim_fg_pct_allowed)

projections %>% mutate(Role = fct_reorder(factor(Role), `Height (Inches)`)) %>% 
  arrange(Role, Player) %>%  
gt() %>% fmt_percent(c('Assist %',
                                'Off Rebound %',
                                'Def Rebound %',
                                'Catch and Shoot 3PT%',
                                'Pull Up 3PT%',
                                "Restricted Area FG%",
                                "Floater Range FG%",
                                'Mid Range FG%',
                                'Opponent Rim FG%')) %>%
  fmt_number('Drive PPP') %>% 
  tab_header('2021 Draft Player Projections') %>% gtsave('projections.png')
  

