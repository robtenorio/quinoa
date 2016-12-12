rm(list = ls())

library(rgdal)
library(broom)
library(maptools)
library(maps)
library(leaflet)
library(dplyr)
library(raster)

############################ GET MAP DATA ##################################
# data source: http://www.gadm.org/download
'shape1_filename <- "PER_adm2"
shape_dir <- "/Users/rtenorio/Desktop/Quinoa/Map/PER_adm"

poly_data <- readOGR(dsn = shape_dir, layer = shape1_filename, encoding = "UTF-8")'

poly_data <- getData(name = "GADM", country = "PER", level = 1)

poly_data@data <- poly_data@data[order(poly_data@data$NAME_1),]

poly_data@data$NAME_1 <- factor(poly_data@data$NAME_1)

#poly_data_df <- fortify(poly_data, region = "NAME_1")

#poly_data_df <- poly_data_df[order(poly_data_df$order),]

### load quinoa production data
setwd("/Users/rtenorio/Desktop/Quinoa/data/production")
quinoa_production <- read.csv("Quinoa Production.csv", stringsAsFactors = FALSE, header = TRUE)

quinoa_production <- quinoa_production[which(!quinoa_production$depa == "peru"),]
# change the names of Lima and Lima Metropolitana so they match the names in the poly_data
quinoa_production$depa[which(quinoa_production$depa == "Lima")] <- "Lima Province"
quinoa_production$depa[which(quinoa_production$depa == "Lima Metropolitana")] <- "Lima"

quinoa_production <- quinoa_production[order(quinoa_production$depa),]

quinoa_production$depa <- factor(quinoa_production$depa, labels = unique(poly_data@data$NAME_1))

# use just most recent year for quinoa production
quinoa_production_recent <- quinoa_production[which(quinoa_production$year == max(quinoa_production$year)),]

# join the quinoa production with the data attribute of the polydata object
new_poly_data <- left_join(poly_data@data, quinoa_production_recent, by = c("NAME_1" = "depa"))

### Replace the original polygonal data frame with the new joined data frame
poly_data@data <- new_poly_data

################### CREATE THE INTERACTIVE PLOT WITH LEAFLET ##################

# Set a popup that will show country name and production for Year
popup <- paste0(
  poly_data$NAME_1,"<br>","Production:", poly_data$prod
)
# Set continous palette as a function of production
pal <- colorNumeric(
  palette = "Blues",
  domain = poly_data$prod
)

quinoa_regions_map <- leaflet() %>%
  addPolygons(
    data = poly_data,
    fillColor = ~pal(prod),
    fillOpacity = 0.7,
    weight = 1,
    smoothFactor = 0.2,
    popup = popup
  ) %>%
  addLegend(
    pal = pal,
    values = poly_data$prod,
    position = "bottomright",
    title = "Total Production for Years Selected"
  )


quinoa_regions_map

########