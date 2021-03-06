#Map 
#===============================================================================
#Dogs
#@sil_aarts
#===========================================================================

#Load libraries
library("tidyverse")
library("ggtext")
library("extrafont")
library("ggforce")
library("RColorBrewer")
library(showtext)
library(showtextdb)
library(ggmap)
library(ggthemes)
library(wesanderson)

#Load file
data <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-12-17/dog_travel.csv')

#Change some names
data1 <- data[!(data$found == "Lab Rescue LRCP"), ]
data2 <- data1[!(data1$found == "US"), ]
data3 <- data2[!(data2$found == "the United States"), ]
data3$found[data3$found == "SEATTLE"] <- "Seattle"
data3$found[data3$found == "NC"] <- "North Carolina"

#Number of dogs per country
data4 <- data3 %>%
  group_by(found) %>%
  mutate(country_n= n())

#Select only unique rows
data5 <- data4 %>%
  distinct(found, .keep_all = T) 

#Select top 50
data6 <- data5 %>%
  filter(country_n > 50)

#Change some colnames: if colname has 2 char then choose manual (data is always entered in the same manner)
#data$found <- ifelse(nchar(data3$found) == 2, data3$manual, data3$found)

#Delete rows with found=NA
data7 <- data6 %>%
  drop_na(found)
 
#Get long.lat score
register_google(key = "AIzaSyBPfgXrAPgnR_tFYd4PfXINnpDp4nosAvE") 
geo <- geocode(data7$found) 
data_geo <- merge(data7, geo, by.x = 0, by.y = 0)

#Pixels!
#Low resolution is lot of dots. High is 'dotless'.
resolution <- 1.5
lat <- tibble(lat = seq(-90, 90, by = resolution))
long <- tibble(long = seq(-180, 180, by = resolution))
#Lakes are optional
pixels <- merge(lat, long, all = TRUE) %>%
  mutate(country = maps::map.where("world", long, lat),
         lakes = maps::map.where("lakes", long, lat)) %>% 
  filter(!is.na(country) & is.na(lakes)) %>%
  select(-lakes)

#GGplot: ggmap
pixelsmap <- ggplot() + 
  geom_point(data = pixels, aes(x = long, y = lat), color = "grey", size = 0.7)

#Choose font
font_add_google("Oswald", "O")
showtext_auto()

#Choose font
font_add_google("Abril fatface", "A")
showtext_auto()

#Theme
theme <-  theme_map() +
  theme(
    legend.position= "none",
    text = element_text(family="O"),
    plot.background = element_rect(fill = "black", color = NA),
    panel.background = element_rect(fill = "black", color = NA), 
    plot.title= element_text(size = 28, color="darkturquoise"),
    plot.subtitle= element_text(size = 14, color="white"),
    plot.caption = element_text(size = 6, color="white", hjust=1),
    panel.grid = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank())

#GGplot: ggmap
p <- pixelsmap + 
  geom_point(data =data_geo, aes(x = lon, y = lat, size=4, colour= cut(country_n, c(-Inf, 100, 300, Inf))))+
  scale_color_manual(name = "Number of dogs", 
                     values = c("(-Inf,100]" = "darkturquoise",
                                "(100,300]" = "chocolate4",
                                "(300, Inf]" = "darkorange1"),
                     labels = c("0-100, 100-300, 300+"))+
  labs(title= "WORLD MAP: DOGS", 
       subtitle="Where are the dogs found?")+
  coord_sf(clip = "on",
           ylim = c(-58, 85),
           xlim = c(-170, 170))+
  theme
  

#Run it!
p

#Legend
p2 <- ggplot(data_geo)+
  #Text orange
  geom_point(aes(x= -140, y= -70), size=12, colour="darkorange1", fill="darkorange1")+
  geom_text(aes(x= -110, y = -70), label="Texas & Alabama: +300", 
            color="white", size=5, face="bold", family="O")+
  geom_text(aes(x = -110, y = -80), label="Two places with more than\n300 dogs found", 
            color="dimgrey", size=4, family="A")+
  #Text turquoise
  geom_point(aes(x= 100, y= -70), size=12, colour="darkturquoise", fill="darkturquoise")+
  geom_text(aes(x = 140, y = -70), label="Mexico & South-Korea: 50-100", 
            color="white", size=5, face="bold", family="O")+
  geom_text(aes(x = 140, y = -80), label="Two countries with between 50\nand 100 dogs found", 
            color="dimgrey", size=4, family="A")+
  #Text brown
  geom_point(aes(x= -33, y= -70), size=12, colour="chocolate4", fill="chocolate4")+
  geom_text(aes(x = 0, y = -70), label="Main & Seattle: 100-300", 
            color="white", size=5, face="bold", family="O")+
  geom_text(aes(x = 0, y = -80), label="Two places with between 100\nand 300 dogs found", 
            color="dimgrey", size=4, family="A")+
  coord_sf(clip = "on",
           ylim = c(-80, 85),
           xlim = c(-170, 170))+
  labs(
       caption="Source: Petfinder / the Pudding | Plot by: @sil_aarts")+
  theme

#Run quartz
quartz()

#Arrange plot
p3 <- p2 + annotation_custom(ggplotGrob(p), xmin = -170, xmax = 170, ymin = -62, ymax = 85)

#Run it!
p3
