library(ggplot2)
library(lmtest)
library(splines)
library(lme4)
library(lattice)
library(xtable)
library(maps)
library(dplyr)
library(knitr)
library(foreign)
library(haven)
library(zoo)

### download accident files (2005-2015)
url = "ftp://ftp.nhtsa.dot.gov/fars"
if(!dir.exists("./data")) dir.create("./data")
if(!dir.exists("./data/raw_data")) dir.create("./data/raw_data")
if(!dir.exists("./data/proc_data")) dir.create("./data/proc_data")
if(!dir.exists("./R_code")) dir.create("./R_code")

##2005-2015
for(i in 2005:2015){
    
    if(i<=2011) download.file(paste(url,i,"SAS",paste0("FSAS",i,".zip"),sep="/"),paste("./data/raw_data",paste0(i,".zip"),sep="/"))
    if(i==2012) download.file(paste(url,"2012","National","SAS",paste0("FSAS","2012",".zip"),sep="/"),paste("./data/raw_data",paste0("2012",".zip"),sep="/"))
    if(i>=2013) download.file(paste(url,i,"National",paste0("FARS",i,"NationalSAS.zip"),sep="/"),paste("./data/raw_data",paste0(i,".zip"),sep="/"))
    
    if(!dir.exists(paste0("./data/raw_data/",i))) dir.create(paste0("./data/raw_data/",i))
    unzip(paste("./data/raw_data",paste0(i,".zip"),sep="/"),exdir=paste0("./data/raw_data/",i))
    file.remove(paste("./data/raw_data",paste0(i,".zip"),sep="/"))
}

'%!in%' <- function(x,y)!('%in%'(x,y))

remain_file=c(list.files("./data/raw_data",pattern="accident.sas7bdat",recursive = T),
          list.files("./data/raw_data/",pattern = "person.sas7bdat",recursive = T))
all_file=list.files("./data/raw_data/",recursive = T)
remain_id=match(remain_file,all_file)
file.remove(paste0("./data/raw_data/",all_file[-remain_id]))

## download unemployment data

unemp_url="https://www.datazoa.com/publish/export.asp?hash=1C83C718DC&glname=&dzuuid=97&alttitle=&altextsrc=&a=exportcsv&startdate=1/1/2005&enddate=8/1/2016&transpose=yes"
if(!dir.exists("./data/raw_data/unemployment")) dir.create("./data/raw_data/unemployment")
download.file(unemp_url,"./data/raw_data/unemployment/unemployment_md.csv")

## download median household income data(2006-2014)
income_url="http://www.mdp.state.md.us/msdc/HH_Income/SAIPE_2006_2014_Household_Median_Income_Data.xlsx"
if(!dir.exists("./data/raw_data/income")) dir.create("./data/raw_data/income")
download.file(income_url,"./data/raw_data/income/income_md_to2014.xlsx")

## download population data
pop_url1="http://planning.maryland.gov/msdc/IntercensalEst00_10/IntercensalPopEstimates_MD_Jur_2000_2010.xls"
if(!dir.exists("./data/raw_data/population")) dir.create("./data/raw_data/population")
download.file(pop_url1,"./data/raw_data/population/population_md_pre2010.xls")

library(rvest)
pop_url2 = "http://factfinder.census.gov/faces/tableservices/jsf/pages/productview.xhtml?src=bkmk"
# htmlfile = read_html(pop_url2)
# nds = html_nodes(htmlfile,                
#                  xpath='//*[@id="inner_table_container"]')
# dat = html_table(nds)
# dat = as.data.frame(dat)
# head(dat)

