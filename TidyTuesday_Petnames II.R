TidyTuesday
#Pet names II

require(devtools)
devtools::install_github("dkahle/ggmap", ref = "tidyup")

#Load libraries
library(tidyverse)
library(ggplot2)
library(dplyr)
library(ggmap)
library(zipcode)

#Read file
seattle_pets <- read.csv2("Desktop/R/TidyTuesday/26 maart Petnames/Seattle_Pet.csv", stringsAsFactors=F, header=T)

#Change colname zipcode
colnames(seattle_pets) [c(3,7)] <- c("name", "zip")

#Data zipcode
Data(zipcode)

#Merge files
zipcode2 <- zipcode %>%
  filter(city=="Seattle")
seattle_pets2 <- merge(seattle_pets, zipcode2, by.x='zip', by.y='zip')

#Filter: where is Wall-E?
seattle_pets3 <- seattle_pets2 %>%
  filter(name== "Wall-E")
  
  
#API key google
register_google(key = "YOUR KEY HERE")

#GGmap > Seattle
p <- ggmap(get_googlemap(center = c(lon = -122.335167, lat = 47.608013),
                         zoom = 11, scale = 2,
                         maptype ='terrain',
                        color="color"))+
geom_point(aes(x = longitude, y = latitude, colour=name), data=seattle_pets3, size=3)+
scale_color_manual(values="yellow")+
    theme(legend.position="none",
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    axis.title.x=element_blank(),
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_blank(),
    axis.title.y=element_blank())

#Run it
p



