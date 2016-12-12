rm(list = ls())

library(rgdal)
library(ggplot2)
library(broom)
library(maptools)
library(maps)
library(leaflet)
library(dplyr)

############################ GET MAP DATA ##################################
# data source: http://www.gadm.org/download
shape1_filename <- "PER_adm2"
shape_dir <- "/Users/rtenorio/Desktop/Quinoa/Map/PER_adm"

poly_data <- readOGR(dsn = shape_dir, layer = shape1_filename, encoding = "UTF-8")

poly_data_df <- fortify(poly_data, region = "NAME_1")

poly_data_df <- poly_data_df[order(poly_data_df$order),]

### load quinoa production data
setwd("/Users/rtenorio/Desktop/Quinoa/data/production")
quinoa_production <- read.csv("Quinoa Production.csv", stringsAsFactors = FALSE, header = TRUE)

# use just most recent year for quinoa production
quinoa_production_recent <- quinoa_production[which(quinoa_production$year == max(quinoa_production$year)),]

### join quinoa data and poly data
poly_quinoa_data <- left_join(poly_data_df, quinoa_production_recent, by = c("id" = "depa"))

# this creates a plot object called "map"
map <- ggplot()
# this fills in the "map" plot with our data
map <- map + geom_polygon(data=poly_quinoa_data, aes(x = long, y = lat, group = group, 
                                                     fill = poly_quinoa_data$prod), color = alpha("white", 1/2))

# this gives our data the colors we want according to investment size
#map <- map + scale_fill_manual(guide = guide_legend(reverse=TRUE),name = NULL, values = alpha(c("#9ec3af", "#32b057", "#027541", "#00431e")))

# this removes the axis labels
map <- map + theme(axis.line=element_blank(),axis.text.x=element_blank(),
                   axis.text.y=element_blank(),axis.ticks=element_blank(),
                   axis.title.x=element_blank(),
                   axis.title.y=element_blank(),legend.position=c(.2,.2),
                   legend.text=element_text(size=15),
                   panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(),
                   panel.grid.minor=element_blank(),plot.background=element_blank())

# This saves the map
#ggsave("Africa Map", plot = map, device = "png", scale=1)

