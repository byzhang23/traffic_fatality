### population files
library(readr)
library(readxl)
library(dplyr)

### read in population data: pre2010 and extract MD state

pop_pre=read_excel("./data/raw_data/population/population_md_pre2010.xls",skip=3)
pop_pre = pop_pre[-1,-c(2:7,ncol(pop_pre))]
pop_pre=pop_pre[complete.cases(pop_pre),]
colnames(pop_pre)=c("county",2005:2009)
pop_pre$county=gsub("^ ","",gsub("\\.","",gsub("'s","s",gsub(" county","",tolower(pop_pre$county)))))


region_id=grep("region",pop_pre$county,ignore.case = T)
pop_pre=pop_pre[-region_id,] 

### match all county FIPS code in maryland and add variable geo_id

md_fips=county.fips[grepl("^24[0-9][0-9][0-9]",county.fips$fips),]
md_fips$polyname=gsub("maryland,","",md_fips$polyname)
md_fips_id=match(pop_pre$county,md_fips$polyname)

pop_pre$geo_id=md_fips$fips[md_fips_id]
pop_pre=pop_pre[,c(1,7,2:6)]

### read in population data: pre2010 and extract MD statepost2010

pop_post=read_csv("./data/raw_data/population/population_md_post2010.csv")
pop_post=pop_post[,-c(1,3)]
colnames(pop_post)=c("geo_id","2010","2011","2012","2013","2014","2015")


### final population data for each year

pop=dplyr::inner_join(pop_pre,pop_post) %>%
    tidyr::gather("year","population",3:13) %>%
    mutate(year=as.numeric(year),geo_id=as.integer(geo_id))
