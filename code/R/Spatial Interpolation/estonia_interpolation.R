rm(list = ls())

library(ggplot2)
library(gstat)
library(sp)
library(maptools)
library(gpclib)
gpclibPermit() # What is this? Why do I have to do this?: http://stackoverflow.com/questions/30790036/error-istruegpclibpermitstatus-is-not-true

source_wd <- "/Users/roberttenorio/Documents/interpolate"

setwd(source_wd)

estonia_air_temperature <- read.csv("estonia_air_temperature_2.csv", 
                                    stringsAsFactors = FALSE, header = TRUE)

# create two new variables called x and y
estonia_air_temperature_coord <- estonia_air_temperature
estonia_air_temperature_coord$x <- estonia_air_temperature_coord$lon
estonia_air_temperature_coord$y <- estonia_air_temperature_coord$lat

# set spatial coordinates to create a spatial object
coordinates(estonia_air_temperature_coord) = ~x + y
  
plot(estonia_air_temperature_coord)

# set the ranges for x and y using the ranges of lon and lat
x.range <- range(estonia_air_temperature$lon)
y.range <- range(estonia_air_temperature$lat)

# create a data frame from all combinations of the supplied vectors
# expand points to grid
grd <- expand.grid(x = seq(from = x.range[1], to = x.range[2], by = 0.1), y = seq(from = y.range[1], 
                                                                                  to = y.range[2], by = 0.1))  
coordinates(grd) <- ~x + y
gridded(grd) <- TRUE

plot(grd, cex = 1.5, col = "grey")
points(estonia_air_temperature_coord, pch = 1, col = "red", cex = 1)

# apply idw model for the data
idw <- idw(formula = may12 ~ 1, locations = estonia_air_temperature_coord, 
           newdata = grd) 

idw.output = as.data.frame(idw)  # output is defined as a data table
names(idw.output)[1:3] <- c("long", "lat", "var1.pred")  # give names to the modelled variables

# plot the results
ggplot() + geom_tile(data = idw.output, aes(x = long, y = lat, fill = var1.pred)) + 
  geom_point(data = estonia_air_temperature, aes(x = lon, y = lat), shape = 21, 
             colour = "red")

# now add a map of Estonia and change the colors
est_contour <- readShapePoly("population_in_municipalities_2011_wgs84.shp")
est_contour_fort <- fortify(est_contour, region = "name")

ggplot() + geom_tile(data = idw.output, alpha = 0.8, aes(x = long, y = lat,
                                                         fill = round(var1.pred, 0))) + scale_fill_gradient(low = "cyan", high = "orange") + 
  geom_path(data = est_contour_fort, aes(long, lat, group = group), colour = "grey") + 
  geom_point(data = estonia_air_temperature, aes(x = lon, y = lat), shape = 21, 
             colour = "red") + labs(fill = "Air temp.", title = "Air temperature in Estonia, 15/May/2010")

