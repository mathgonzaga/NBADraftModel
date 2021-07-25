library(tidyverse)
library(NBAr)
setwd('draftmodelling')

###############_------------- DRIVES------------------------------#################
drives <- tibble()
for(yr in 2013:2020){
temp <-  get_tracking(yr,'Player','Drives', 'Totals') %>% 
  transmute(player_name, drive = (drive_fga +0.44*drive_fta + drive_tov),
            drive_pts)
drives <- bind_rows(drives,temp)
}

drives <- drives %>% group_by(player_name) %>% summarize_all(sum) %>% filter(drive>300) %>% 
  transmute(player_name, drive_ppp = drive_pts/drive)



###############_------------- CATCHSHOOT------------------------------#################
catchshoot <- tibble()
for(yr in 2013:2020){
  temp <-  get_tracking(yr,'Player','CatchShoot', 'Totals') %>% 
    transmute(player_name, catch_shoot_fg3a,
              catch_shoot_fg3m)
  catchshoot <- bind_rows(catchshoot,temp)
}

catchshoot <- catchshoot %>% group_by(player_name) %>% summarize_all(sum) %>%
  filter(catch_shoot_fg3a>300) %>% 
  transmute(player_name, catchshoot_pct = catch_shoot_fg3m/catch_shoot_fg3a)


###############_------------- PULL UP------------------------------#################
pullup <- tibble()
for(yr in 2013:2020){
  temp <-  get_tracking(yr,'Player','PullUpShot', 'Totals') %>% 
    transmute(player_name, pull_up_fg3a,
              pull_up_fg3m)
  pullup <- bind_rows(pullup,temp)
}

pullup <- pullup %>% group_by(player_name) %>% summarize_all(sum) %>%
  filter(pull_up_fg3a>200) %>% 
  transmute(player_name, pull_up_pct = pull_up_fg3m/pull_up_fg3a)



###############_------------- AREA SHOOTING------------------------------#################
area <- tibble()
for(yr in 2010:2020){
  temp <-  get_shooting(yr, 'Player', 'By Zone','Base','Totals')
  area <- bind_rows(area,temp)
}

area <- area %>% group_by(player_name) %>% summarize_if(is.numeric,sum)

ra <- area %>% filter(fga_restricted_area>300) %>% 
  transmute(player_name,ra_pct = fgm_restricted_area/fga_restricted_area)

ftr <- area %>% filter(fga_in_the_paint>300) %>% 
  transmute(player_name,flt_pct = fgm_in_the_paint/fga_in_the_paint)


mid <- area %>% filter(fga_mid_range>300) %>% 
  transmute(player_name,mid_pct = fgm_mid_range/fga_mid_range)

##############------------- RIM PROTECTION -------------------------#########

rimprot <- tibble()
for(yr in 2013:2020){
  temp <-  get_defense(yr, 'Player', 'Less+Than+6Ft','Totals')
  rimprot <- bind_rows(rimprot,temp)
}

rimprot <- rimprot %>%
  select(player_name, fgm_lt_06, fga_lt_06) %>% 
         group_by(player_name) %>% summarize_all(sum) %>% filter(fga_lt_06>300) %>% 
  transmute(player_name, rim_pct = fgm_lt_06/fga_lt_06)

##############-------------- ADVANCED --------------------------------########

adv <- tibble()
for(yr in 2013:2020){
  temp <-  get_general(yr, 'Player', 'Advanced','Totals')
  adv <- bind_rows(adv,temp)
}

adv <- adv %>%
  select(player_name,ast_pct, oreb_pct, dreb_pct, poss) %>% 
  group_by(player_name) %>% summarize_all(mean) %>% filter(poss>1000) %>% 
  select(-poss)


##############-------------- LEBRON
valid <- adv$player_name
lebron <- read_csv('data/raw/lebron.csv') %>% 
  transmute(player_name = Player, 
            olebron = `Career O-LEBRON`/`Seasons`,
            dlebron = `Career D-LEBRON`/`Seasons`#,
            #wa = `WA / Season`
            ) %>% filter(player_name %in% valid)

##############-------------- JOINING

data <- adv %>% full_join(catchshoot) %>% full_join(pullup) %>% 
  full_join(rimprot) %>% 
  full_join(drives) %>% full_join(ra) %>% full_join(ftr) %>% 
full_join(mid) %>% left_join(lebron)


write_csv(data, 'data/intermediate/clean_nba_data.csv')
