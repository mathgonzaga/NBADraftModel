library(tidyverse)

setwd('draftmodelling')
data <- data.frame()
for(i in (0:10)){
data <- data %>% 
  bind_rows(read_csv(paste0('data/raw/trank_data (', i, ').csv'),
                     col_names = FALSE,
                     col_types = cols(
                       .default = col_double(),
                       X1 = col_character(),
                       X2 = col_character(),
                       X3 = col_character(),
                       X26 = col_character(),
                       X27 = col_character(),
                       X28 = col_character(),
                       X34 = col_character(),
                       X65 = col_character()
                     )))
}

data <- data %>% select(-X66) %>% unique()

cols <- c('player_name','team','conf','GP','Min_per','ORtg','usg','eFG',
          'TS_per','ORB_per','DRB_per','AST_per','TO_per','FTM','FTA','FT_per',
          'twoPM','twoPA','twoP_per','TPM','TPA','TP_per','blk_per','stl_per',
          'ftr','yr','ht','num','porpag','adjoe','pfr','year','pid','type',
          'Rec','ast/tov','rimmade','rimmade+rimmiss','midmade',
          'midmade+midmiss','rimmade/(rimmade+rimmiss)',
          'midmade/(midmade+midmiss)','dunksmade','dunksmiss+dunksmade',
          'dunksmade/(dunksmade+dunksmiss)','pick','drtg','adrtg','dporpag',
          'stops','bpm','obpm','dbpm','gbpm','mp','ogbpm','dgbpm','oreb','dreb',
          'treb','ast','stl','blk','pts','role')

names(data) <- cols
prospects <- c("Cade Cunningham","Jalen Suggs","Evan Mobley",
               "Jalen Green","Jonathan Kuminga", "Keon Johnson",
               "Davion Mitchell","James Bouknight","Scottie Barnes",
               "Tre Mann", "Jaden Springer", "Josh Giddey",
               "Kai Jones","Cameron Thomas","Moses Moody",
               "Franz Wagner", "Chris Duarte","Corey Kispert", 
               "Jared Butler", "Jalen Johnson","Ziaire Williams", 
               "Sharife Cooper","Isaiah Jackson","Alperen Sengun",
               "Nah'Shon Hyland","Ayo Dosunmu","Usman Garuba",
               "Charles Bassey", "Joel Ayayi", "Day'Ron Sharpe",
               "Greg Brown", "Brandon Boston", "Miles McBride",
               "Aaron Henry","Terrence Shannon", "Daishen Nix",
               "Josh Christopher", "Roko Prkacin", "Kessler Edwards", 
               "Jeremiah Robinson-Earl","Matthew Hurt",
"Marcus Bagley","David Duke", "Herb Jones",
"Rokas Jokubaitis", "Isaiah Todd","Max Abmas", 
"Trey Murphy","RaiQuan Gray")

data <- data %>% filter(year >=2010,(!is.na(pick)) | (player_name  %in% prospects)) %>% 
  select(-num, -type, -pick) %>% separate(ht,c('feet','inches'),sep = '-') %>% 
  mutate(feet = as.numeric(feet), inches = as.numeric(inches), ht = 12*feet + inches) %>% 
  select(-feet,-inches) %>% group_by(player_name) %>% filter(year == max(year))

  data <- data %>% mutate_at(c(14,15,17,18,20,21,34,35,36,37,40,41,45),~./(GP*mp))

  write_csv(data,'data/intermediate/clean_college_data.csv')
  