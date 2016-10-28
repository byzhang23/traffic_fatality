#extract data of MD(24) and add geo_id

filter_dat_md <- function(file_path){
    tmp=read_sas(file_path)
    colnames(tmp)=tolower(colnames(tmp))
    tmp=tmp %>% filter(state == 24) 
    tmp$geo_id=with(tmp,as.integer(paste0(state,formatC(county, width=3, flag="0"))))
    return (tmp)
}

filter_dat <- function(file_path){
    
    tmp=read_sas(file_path)
    colnames(tmp)=tolower(colnames(tmp))
    tmp=tmp %>% filter(state!=2) #omit alaska state
    tmp$geo_id=with(tmp,as.integer(paste0(state,formatC(county, width=3, flag="0"))))
    return (tmp)
}

change_pop <- function(file_path){
    pop=read_csv(file_path)
    pop=pop[,-1]
    colnames(pop)=c("geo_id","county","2011","2012","2013","2014","2015")
    pop=tidyr::gather(pop,"year","population",3:length(pop))
    pop$year=as.numeric(pop$year)
    pop$geo_id=as.integer(pop$geo_id)
    return (pop)
}

read_income <- function(file_path){
    inc=read_excel(file_path,skip = 2)
    if(sum(colnames(inc)=="")>0) inc=read_excel(file_path,skip = 3)
    colnames(inc)=gsub(" ","",colnames(inc))
    colnames(inc)[1:2]=c("state","county")
    
    inc$geo_id=paste0(inc$state,formatC(inc$county,width = 3,flag=0))
    inc=subset(inc,select= c("state","county","geo_id","MedianHouseholdIncome"))
    colnames(inc)=c("state","county","geo_id","median_income")
    year=paste0("20",unlist(str_extract_all(file_path,"[0-9][0-9]")))
    inc$year=as.integer(rep(year,nrow(inc)))
    inc$geo_id=as.integer(inc$geo_id)
    inc=inc %>% filter(county>0)   #remove state total
    return (inc)
}

income_md <- function(x){
    sub_inc=x %>% filter(state %in% c("24"))
    return(sub_inc)
}

fata_plot <- function(name,acc_file,year){
    #data
    usa = map_data("state")
    counties = map_data("county")
    state = subset(usa,region %in% name)
    state_county = subset(counties, region %in% name )
    state_name= aggregate(cbind(long, lat) ~ subregion+group, data=state_county, 
                          FUN=function(x) mean(range(x)))
    
    #ggplot base
    state_base = ggplot(data = state, mapping = aes(x = long, y = lat, group = group)) + 
        coord_fixed(1.3) + 
        geom_polygon(color = "black", fill = "gray")
    
    state_county = state_county %>% 
        mutate(polyname=paste(region,subregion,sep=",")) %>%
        inner_join(county.fips, by="polyname") 
    colnames(state_county)[8]="geo_id"
    
    state_summary = inner_join(acc_file,state_county)
    
    ditch_the_axes <- theme(
        axis.text = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        panel.border = element_blank(),
        panel.grid = element_blank(),
        axis.title = element_blank()
    )
    
    #fatality rate
    state_fata_rate<- state_base + 
        geom_polygon(data = state_summary, aes(fill = fata_rate), color = "white") + 
        scale_fill_gradient(low = "lightgreen", high = "red",breaks=seq(0,max(state_summary$fata_rate),by=0.5))+
        geom_polygon(color = "black", fill = NA) +
        theme_bw() +
        ditch_the_axes +
        #geom_text(data=state_name,hjust=0.5, vjust=-0.5,aes(long,lat,label=subregion),size=2,colour="blue")+
        ggtitle(paste("County level fatality rate per 1000 of",year,sep=" "))
    state_fata_rate
}

inc_plot <- function(name,acc_file,year){
    usa = map_data("state")
    counties = map_data("county")
    state = subset(usa,region %in% name)
    state_county = subset(counties, region %in% name )
    state_name= aggregate(cbind(long, lat) ~ subregion+group, data=state_county, 
                          FUN=function(x) mean(range(x)))
    
    #ggplot base
    state_base = ggplot(data = state, mapping = aes(x = long, y = lat, group = group)) + 
        coord_fixed(1.3) + 
        geom_polygon(color = "black", fill = "gray")
    
    state_county = state_county %>% 
        mutate(polyname=paste(region,subregion,sep=",")) %>%
        inner_join(county.fips, by="polyname") 
    colnames(state_county)[8]="geo_id"
    
    state_summary = inner_join(acc_file,state_county)
    
    ditch_the_axes <- theme(
        axis.text = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        panel.border = element_blank(),
        panel.grid = element_blank(),
        axis.title = element_blank()
    )

    #median household income
    state_inc <- state_base +
        geom_polygon(data = state_summary, aes(fill = median_income), color = "white") +
        geom_polygon(color = "black", fill = NA) +
        scale_fill_gradient(low = "orange", high = "yellow")+
        theme_bw() +
        ditch_the_axes +
        #geom_text(data=state_name,hjust=0.5, vjust=-0.5,aes(long,lat,label=subregion),size=2,colour="green")+
        ggtitle(paste("County level population of",year,sep=" "))
 state_inc
}


