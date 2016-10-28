### concatenate all files
library(dplyr)
library(foreign)
library(haven)
library(zoo)
library(maps)
library(ggmap)
library(ggplot2)
library(readr)
library(tidyr)
library(readxl)
library(stringr)
library(splines)
library(lmtest)

### source preprocessing codes
source("http://peterhaschke.com/Code/multiplot.R")
# source("./R_code/0-download.R")   #population post 2010 data need to be downloaded by hand
source("./R_code/1-function.R")
source("./R_code/1-acc.R")
source("./R_code/1-unemployment.R")
source("./R_code/1-per.R")
source("./R_code/1-population.R")
#source("./R_code/1-income.R")

if(!dir.exists("./data/proc_data")) dir.create("./data/proc_data")


### combine state-level (discard geo_id)
acc_state=dplyr::inner_join(acc_state,unique(pop %>% group_by(year) %>% 
                         mutate(population=mean(population)) %>%
                         dplyr::select(year,population,county)))
crash_state=dplyr::inner_join(acc_state,per_state_age) %>%
    dplyr::inner_join(unemp_state)
crash_state$lgt_cond=as.factor(ifelse(is.nan(crash_state$lgt_cond),NA,crash_state$lgt_cond))

saveRDS(crash_state,"./data/proc_data/crash_state.rds")


### combine acc/per-age/unemp/pop (2005-2015)
acc_md=dplyr::inner_join(acc_md,pop %>% select(geo_id,year,population,county))
crash=dplyr::inner_join(acc_md,per_md_age) %>%
      dplyr::inner_join(unemp_md %>% select(geo_id,ym,unemp_rate)) 
crash$geo_id=as.factor(crash$geo_id)
crash$lgt_cond=as.factor(ifelse(is.nan(crash$lgt_cond),NA,crash$lgt_cond))

saveRDS(crash,"./data/proc_data/crash_county.rds")

rm(list=ls(pattern = "pop"))
rm(list=ls(pattern = "per"))
rm(list=ls(pattern = "date"))

