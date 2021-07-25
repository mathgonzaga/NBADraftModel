library(tidyverse)
library(tidymodels)
library(xgboost)
setwd('draftmodelling')

college <- read_csv('data/intermediate/clean_college_data.csv')
nba <- read_csv('data/intermediate/clean_nba_data.csv')

names(nba)[2:13] <- paste0('nba_',names(nba)[2:13])
data <- college %>% inner_join(nba)


data <- data %>% filter(year<2018)
draft_model <- function(data, label, features, xgb_params){
  eval <- tibble()

  for(y in 2014:2017){
    print(y)
    data2 <- data %>% rename(outcome = sym(label)) %>% drop_na_(vars(outcome))
    train <- data2  %>% filter(year<y) %>% select(-player_name,-year, -team, -starts_with('nba'))
    train <- train %>% select(one_of(features),outcome)
    test_r <- data2 %>% filter(year>=y) 
    test <- test_r %>% select(-player_name,-year, -team, -starts_with('nba')) 
    test <- test %>% select(one_of(features), outcome)
    train_label <- train %>% pull(outcome)
    test_label <- test_r %>% pull(outcome)
    recipe <- recipe(outcome~., data= train) %>% 
      step_center(all_numeric(), -all_outcomes()) %>% 
      step_scale(all_numeric(), -all_outcomes()) %>% 
      step_dummy(all_nominal()) %>% step_meanimpute(all_numeric()) %>% 
      prep()
    train <- juice(recipe)
    test <- bake(recipe,test)
    train <- train %>% select(-outcome)
    test <- test %>% select(-outcome)
    mod <- xgboost(data = as.matrix(train), label = train_label,nrounds = 200,
                   params = xgb_params)
    imp <-  xgb.importance(model = mod)
    pred <- predict(mod,as.matrix(test))
    df <- data.frame(player_name= test_r$player_name, truth = test_r$outcome,
                     pred = pred, year= y)
    eval <- bind_rows(eval,df)
    meanerror <- eval %>% group_by(year) %>%
      summarize(mae = median(abs(truth - pred)), mape = mae/median(truth))
    
  }
  return(list(eval, meanerror, mod, imp,recipe))
  
}


ast <- draft_model(data, 'nba_ast_pct', c('ast', 'yr',
                                            'ORtg', 'usg', 'Rec',
                                            'ast/tov','obpm', 'ogbpm', 'role'),
                    list(max_depth = 12, min_child_weight = 0.05, subsample = 1,
                         colsample_bytree = 1, eta = 0.15))


metrics <- bind_cols(ast[[2]],var = 'Assist %')

oreb <- draft_model(data, 'nba_oreb_pct', c('oreb', 'yr', 'conf', 'ht',
                                            'dreb', 'blk', 'role',
                                            'drtg', 'adrtg', 'dbpm', 'dporpag'),
                    list(max_depth = 10, min_child_weight = 0.04, subsample = 1,
                         colsample_bytree = 1, eta = 0.11))

metrics <- bind_rows(metrics, bind_cols(oreb[[2]],var = 'Off Rebound %'))

dreb <- draft_model(data, 'nba_dreb_pct', c('oreb', 'yr', 'conf', 'ht',
                                            'dreb', 'blk', 'role',
                                            'drtg', 'adrtg', 'dbpm', 'dporpag'),
                    list(max_depth = 10, min_child_weight = 0.01, subsample = 1,
                         colsample_bytree = 1, eta = 0.13))

metrics <- bind_rows(metrics, bind_cols(dreb[[2]],var = 'Def Rebound %'))

catchshoot <- draft_model(data, 'nba_catchshoot_pct', c('yr', 'conf', 'ht',
                                            'FT_per', 'mimade/(midmade+midmiss)', 'role',
                                            'midmade+midmiss', 'TPMA', 'TP_per'),
                    list(max_depth = 8, min_child_weight = 0.01, subsample = 1,
                         colsample_bytree = 1, eta = 0.13))

metrics <- bind_rows(metrics, bind_cols(catchshoot[[2]],var = 'Catch and Shoot 3PT%'))

pullup <- draft_model(data, 'nba_pull_up_pct', c('yr', 'conf', 'ht',
                                                        'FT_per', 'mimade/(midmade+midmiss)', 'role',
                                                        'midmade+midmiss', 'TPMA', 'TP_per'),
                          list(max_depth = 7, min_child_weight = 0.01, subsample = 1,
                               colsample_bytree = 1, eta = 0.13))
metrics <- bind_rows(metrics, bind_cols(pullup[[2]],var = 'Pull Up 3PT%'))


rimprot <- draft_model(data, 'nba_rim_pct', c('yr', 'conf', 'ht',
                                                 'blk', 'drtg', 'role',
                                                 'adrtg','dporpag', 'stops', 'dbpm',
                                              'dgbpm'),
                      list(max_depth = 7, min_child_weight = 0.01, subsample = 1,
                           colsample_bytree = 1, eta = 0.5))

metrics <- bind_rows(metrics, bind_cols(rimprot[[2]],var = 'Opponent Rim FG%'))


rimfin <- draft_model(data, 'nba_ra_pct', c('yr', 'conf', 'ht',
                                              'rimmade+rimmiss', 'rimmade/(rimmade+rimmiss)', 
                                              'dunksmade','dunksmade/(dunksmade+dunksmiss)',
                                              'pts','role'),
                       list(max_depth = 7, min_child_weight = 0.05, subsample = 1,
                            colsample_bytree = 1, eta = 0.7))
rimfin[[2]]

metrics <- bind_rows(metrics, bind_cols(rimfin[[2]],var = 'Restricted Area FG%'))


fltfin <- draft_model(data, 'nba_flt_pct', c('yr', 'conf', 'ht',
                                            'rimmade+rimmiss', 'rimmade/(rimmade+rimmiss)', 
                                            'midmade+midmiss','midmade/(midmade+midmiss)',
                                            'pts','role'),
                      list(max_depth = 7, min_child_weight = 0.05, subsample = 1,
                           colsample_bytree = 1, eta = 0.7))
metrics <- bind_rows(metrics, bind_cols(fltfin[[2]],var = 'Floater Range FG%'))



mid <- draft_model(data, 'nba_mid_pct', c('yr', 'conf', 'ht',
                                              'FT_per', 'midmade/(midmade+midmiss)', 'role',
                                              'midmade+midmiss', 'TPA', 'TP_per'),
                   list(max_depth = 7, min_child_weight = 0.01, subsample = 1,
                        colsample_bytree = 1, eta = 0.15))

metrics <- bind_rows(metrics, bind_cols(mid[[2]],var = 'Mid Range FG%'))



drive <- draft_model(data, 'nba_drive_ppp', c('yr', 'conf', 'ht',
                                          'FT_per', 'midmade/(midmade+midmiss)', 'role',
                                          'rimmade', 'rimmade/(rimmade+rimmiss)', 
                                          'FTA','dunksmade','ftr'),
                   list(max_depth = 7, min_child_weight = 0.01, subsample = 1,
                        colsample_bytree = 1, eta = 0.15))


metrics <- bind_rows(metrics, bind_cols(drive[[2]],var = 'Drive PPP'))

predict_draft_class <- function(new_players,college_data, mod_list ,variables){
  new <- college %>% filter(year==2021) %>%
    filter(player_name!='Jalen Johnson' | yr== 'Fr')
  new_players <- new %>% select(player_name, yr, ht, role)
  print(new)
  for(i in 1:length(mod_list)){
  mod <- mod_list[[i]]
  v <- (variables[i])
  pred_data <- bake(mod[[5]],new)
  new_players <- new_players %>% 
  mutate("{v}" := predict(mod[[3]], as.matrix(pred_data)))
  }
  new_players
}
projections <- predict_draft_class(new_players, college, 
                    list(ast,oreb,dreb,drive,catchshoot,pullup,rimfin,
                         fltfin, mid, rimprot) , c('ast_pct','oreb_pct','dreb_pct',
                                                   'drive_ppp','catchshoot_fg3_pct',
                                                   'pullup_fg3_pct', 'ra_fg_pct', 
                                                   'flt_fg_pct', 'midrange_fg_pct',
                                                   'rim_fg_pct_allowed'))

 write_csv(metrics, 'model_metrics.csv' )
write_csv(projections, '2021draft_projections.csv')  
