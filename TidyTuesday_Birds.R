#TidyTuesday
#===============================================================================
#TidyTuesday
# Birds of feather...collide together?!
#ChordDiagram
#@sil_aarts
#===============================================================================

bird_collisions <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-04-30/bird_collisions.csv")

#Load libraries
library(tidyverse)
library(viridis)
library(patchwork)
library(hrbrthemes)
library(circlize)
library(dplyr)
library(RColorBrewer)
library(chorddiag)  
library(wesanderson)

#Read file
birds <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-04-30/bird_collisions.csv")

#Check what is in the data!
unique(birds$family)
unique(birds$species)
unique(birds$genus)

#Which birds ten to hurt themselves the most?
birds2 <- birds %>% group_by(species, family) %>% mutate(count = n())

#Just check if aggregation worked
birds_check <- birds %>%
  count(species)

#Select unique rows (first delete date)
birds2$date <- NULL
birds3 <- unique(birds2)
#Only select MP
birds4 <- birds3 %>%
  filter(locality=="MP")

#Select ony those colums we need for our ChordDiagram
birds5 <- birds4 %>%
   select(2,4,8)

#Select birds who hurt themselves the most: top 10
birds6 <- birds5[order(-birds5$count),] 
birds7 <- birds6 %>%
 filter(count > 2300)

#Divide by 1000 for ease of use
birds7$count <- birds7$count/1000

#Change colnames
colnames(birds7) <- c("names", "key", "value")

#Make some colours (n=14 for # of sectors )
pal <- wes_palette("IsleofDogs1", 14, type = "continuous")

#Set some parameters
circos.clear()
circos.par(start.degree = 90, gap.degree = 5, track.margin = c(-0.1, 0.1), points.overflow.warning = FALSE)
par(mar = rep(0, 5))

#ChordDiargram plot
chordDiagram(
  x = birds7, 
  grid.col = pal,
  transparency = 0.25,
  directional = 1,
  direction.type = c("arrows", "diffHeight"), 
  diffHeight  = -0.03,
  annotationTrack = "grid", 
  annotationTrackHeight = c(0.05, 0.8),
  link.arr.type = "big.arrow", 
  link.sort = TRUE, 
  link.largest.ontop = TRUE)

#Add axis all around and text using the labels
circos.trackPlotRegion(track.index = 1, bg.border = NA, 
#Set sector.index
panel.fun = function(x, y) {
    xlim = get.cell.meta.data("xlim")
    sector.index = get.cell.meta.data("sector.index")
    
#Add names to the sector, make it facing inside, size letters=cex
circos.text(x = mean(xlim), y = 3, labels = sector.index, facing = "inside", cex = 0.8)
    
#Add ticks on axis
circos.axis(h = "top", minor.ticks = 1, major.tick.percentage=1, labels.niceFacing = FALSE) }
)


