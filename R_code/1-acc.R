library(dplyr)
library(foreign)
library(haven)
library(zoo)
library(maps)
library(ggplot2)
library(readr)
library(tidyr)
library(devtools) 
library(splines)

data_path=paste0(getwd(),"/data/raw_data/")
source(file.path("R_code","1-function.R"))

### read all accident files

for(i in 2005:2015){
    assign(paste0("acc",i),filter_dat_md(file.path(paste0(data_path,i),"accident.sas7bdat")))
}



### extract common colnames from accident files in maryland state
common_col=Reduce(intersect, list(colnames(acc2005),colnames(acc2006),colnames(acc2007),
                             colnames(acc2008),colnames(acc2009),colnames(acc2010),
                             colnames(acc2011),colnames(acc2012),colnames(acc2013),
                             colnames(acc2014),colnames(acc2015)))

extract_commoncol <- function(x){
    x=x %>%
        select(one_of(common_col))
    return(x)
}

acc_md=Reduce(rbind,list(extract_commoncol(acc2005),extract_commoncol(acc2006),extract_commoncol(acc2007),
                         extract_commoncol(acc2008),extract_commoncol(acc2009),extract_commoncol(acc2010),
                         extract_commoncol(acc2011),extract_commoncol(acc2012),extract_commoncol(acc2013),
                         extract_commoncol(acc2014),extract_commoncol(acc2015)))


rm(list=ls(pattern = "acc20[0-9][0-9]"))



### recategorize variables: light conditions, weather
#ligth conditions: 0-night,nolight;1-obscure(night light,dawn,dusk);2-daylight

acc_md$lgt_cond=ifelse(acc_md$lgt_cond>=8,NA,ifelse(acc_md$lgt_cond==2,0,
                                                    ifelse(acc_md$lgt_cond %in% 3:7,1,2)))
#weather: 0-clear;1-adverse weather

acc_md$weather=ifelse(acc_md$weather %in% c(98,99),NA,ifelse(acc_md$weather==1,0,1))

acc_state= acc_md %>% 
    mutate(ym=as.Date(as.yearmon(paste(year,month,sep="/"),"%Y/%m"))) %>%
    group_by(ym,year,month) %>%
    dplyr::summarize(fatals=sum(fatals),weather=mean(weather,na.rm=T),lgt_cond=round(mean(lgt_cond,na.rm=T)))


acc_md = acc_md %>% 
         mutate(ym=as.Date(as.yearmon(paste(year,month,sep="/"),"%Y/%m"))) %>%
         group_by(geo_id,ym,year,month) %>%
         dplyr::summarize(fatals=sum(fatals),weather=mean(weather,na.rm=T),lgt_cond=round(mean(lgt_cond,na.rm=T)))

