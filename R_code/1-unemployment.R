### preprocess unemployment rate data
library(dplyr)
library(foreign)
library(haven)
library(zoo)
library(maps)
library(ggmap)
library(ggplot2)
library(readr)
library(readxl)
library(tidyr)
library(stringr)
library(splines)


### read in unemployment rate data of MD
unemp_md=read_csv("./data/raw_data/unemployment/unemployment_md.csv")
unemp_state=tidyr::gather(unemp_md[1,],"date","unemp_rate",2:(ncol(unemp_md))) %>%
            mutate(ym=as.Date(date,"%m/%d/%Y"),year=as.numeric(format(ym,"%Y")),month=as.numeric(format(ym,"%m"))) %>%
            select(ym,year,month,unemp_rate)

unemp_md=unemp_md[-1,]
name=c("date",gsub("\\.","",gsub("'s","s",gsub(" county","",gsub(", md","",tolower(unemp_md$`Series title`))))))


### match county FIPS code in MD
md_fips=county.fips[grepl("^24[0-9][0-9][0-9]",county.fips$fips),]
md_fips$polyname=gsub("maryland,","",md_fips$polyname)
md_fips_id=match(name[-1],md_fips$polyname)

### add geo_id variable for merging
unemp_md$geo_id=md_fips$fips[md_fips_id]


unemp_md=tidyr::gather(unemp_md,"date","unemp_rate",2:(ncol(unemp_md)-1)) %>%
         dplyr::mutate(ym=as.Date(date,"%m/%d/%Y"),year=as.numeric(format(ym,"%Y")),month=as.numeric(format(ym,"%m")),county=`Series title`) %>%
         dplyr::select(-c(date,`Series title`))


unemp_2016=unemp_md[unemp_md$year==2016,]
saveRDS(unemp_2016,"./data/proc_data/unemp_2016.rds")


