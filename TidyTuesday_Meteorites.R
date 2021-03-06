#TidyTuesday
#===============================================================================
#Rainclouds of meteorites.
#@sil_aarts
#===============================================================================
install.packages("magick")
install.packages("grid")
install.packages("gridExtra")

#Load libraries
library(tidyverse)
library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(extrafont)
library(magick)
library(grid)
library(gridExtra)

#Load file
data <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-06-11/meteorites.csv")

#Check levels
data$class <- as.factor(data$class)
levels(data$class)

#Check unique
data$id <- NULL
data2 <- unique(data)

#Only non-missing data
data2$class <- as.character(data2$class)
data3 <- na.omit(data2)

#Select data from 2000 onwards
data4 <- data3 %>% 
  filter(year > 1999)

#Count number of meteorites per class
data5 <- data4 %>%
  group_by(class) %>%
  mutate(count = n())

#Order data on count peer class
data5$count <- as.numeric(data5$count)
data6 <- data5[order(-data5$count),] 

#Select 2 columns to see top 5 class: L6, L5, H5, H6, LL6
data7 <- data6 %>%
  select(3,10)
data8 <- unique(data7)

#Select original dataset with only those 5 top classes that fall on Earth
data_final <- data6 %>%
  filter(class=="L6" | class=="L5" | class=="H5"| class=="H6"| class=="LL6")

#Make some colours
col <- c("darkred","#FC3D21", "cornflowerblue" ,"dodgerblue4","#0B3D91")

#Add Images
#Add image NASA
image2 <- image_read("Desktop/Nasa.jpg")
NASA <- grid::rasterGrob(image2, interpolate = T) 
#Add background image: meteorites
image3 <- image_read("Desktop/meteo.jpg")
meteo <- grid::rasterGrob(image3, interpolate = T) 

#Calculate year of most meteorites:
data_year <- data_final %>%
  group_by(year) %>%
  mutate(count_year = n())
data_year <- data_year[order(-data_year$count_year),] 

#Start using my own theme
theme_sil <- theme_void() + 
  theme(
    legend.position = "none",
    text = element_text(size = 10, family="Courier New"),
    plot.background = element_rect(fill="black"),
    panel.background = element_rect(fill= "transparent"),
    plot.title=element_text(size=20, hjust=0, face='bold', colour="white", lineheight = 1),
    plot.subtitle=element_text(size=16, hjust=0, colour="white"),
    plot.caption=element_text(size=10, hjust=1, colour="white"),
    axis.text = element_text(size = 12, colour="white", face="bold"))

#GGplot
p <- ggplot(data = data_final, aes(x = class, y = year, fill = class)) +
  annotation_custom(rasterGrob(image3, width = unit(1,"npc"), height = unit(1,"npc")),-Inf, Inf, -Inf, Inf)+
  annotation_custom(NASA, xmin=0, xmax=1, ymin=1998.5, ymax=1999.5)+
  geom_point(aes(y = year, color = class), position = position_jitter(width = .15), size = 1.5, alpha = 0.8) +
  geom_boxplot(width = .3, alpha = 0.8, colour = "white", outlier.shape = 1) +
  geom_flat_violin(position = position_nudge(x=0.25, y=0), alpha = .7) +
  labs(title = "TidyTuesday: Meteorites" ,
       subtitle = "The 5 classes of meteorites that have fallen to Earth the most since 2000" ,
       caption="Source: NASA | Plot by @sil_aarts")+
  scale_fill_manual(values=col)+
  scale_color_manual(values=col)+
  scale_y_continuous(breaks=seq(2000, 2013, 2))+
  coord_flip(clip="off")+
  theme_bw() +
  theme_sil

#Run it
p
