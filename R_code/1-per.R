library(dplyr)
library(foreign)
library(haven)

data_path="./data/raw_data/"
source(file.path("R_code","1-function.R"))



### read in all person files and extract only maryland state
for(i in 2005:2015){
    assign(paste0("per",i),filter_dat_md(file.path(paste0(data_path,i),"person.sas7bdat")) %>% mutate(year=i))
}




### extract common colnames from all person files
per_col=Reduce(intersect, list(colnames(per2005),colnames(per2006),colnames(per2007),
                                  colnames(per2008),colnames(per2009),colnames(per2010),
                                  colnames(per2011),colnames(per2012),colnames(per2013),
                                  colnames(per2014),colnames(per2015)))

extract_commoncol <- function(x){
    x=x %>%
        select(one_of(per_col))
    return(x)
}

per_md=Reduce(rbind,list(extract_commoncol(per2005),extract_commoncol(per2006),extract_commoncol(per2007),
                         extract_commoncol(per2008),extract_commoncol(per2009),extract_commoncol(per2010),
                         extract_commoncol(per2011),extract_commoncol(per2012),extract_commoncol(per2013),
                         extract_commoncol(per2014),extract_commoncol(per2015)))
rm(list=ls(pattern = "per20[0-9][0-9]"))




### get information about drivers (per_typ==1) and add ym variable
per_md = per_md %>% filter(per_typ==1) %>%
    dplyr::mutate(ym=as.Date(as.yearmon(paste(year,month,sep="/"),"%Y/%m")))



### handle missingness
per_md$age=with(per_md,ifelse(age %in% c(998,999),NA,age))
per_md$alc_res[per_md$year<2015]=ifelse(per_md$alc_res[per_md$year<2015] %in% c(95:99),NA, per_md$alc_res[per_md$year<2015]*10)
per_md$alc_res=ifelse(per_md$alc_res %in% c(995,996,999),NA,per_md$alc_res)



### define drunk drivers in MD (BAC>0.08)
per_md$drunk=ifelse(per_md$drinking %in% c(8,9),ifelse(per_md$alc_res<800,0,1),per_md$drinking)

### final info of person-level on MD state
per_state_age = per_md %>%
    group_by(ym) %>%
    dplyr::summarize(age=mean(age,na.rm=T),drunk_prop=mean(drunk,na.rm=T)) 

### final information of person-level data: average age of drivers involved in accidents; drunk drivers percentage in one day
per_md_age = per_md %>%
             group_by(geo_id,ym) %>%
             dplyr::summarize(age=mean(age,na.rm=T),drunk=sum(drunk,na.rm=T),drivers=n()) %>%
             mutate(drunk_prop=drunk/drivers)

