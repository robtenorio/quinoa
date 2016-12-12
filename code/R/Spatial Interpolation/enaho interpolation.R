rm(list = ls())

libraries <- c("dplyr", "ggplot2", "gstat", "gpclib", "maptools", "reshape", "RMySQL", "raster", "sp")
lapply(libraries, library, character.only = TRUE)

gpclibPermit() # What is this? Why do I have to do this?: http://stackoverflow.com/questions/30790036/error-istruegpclibpermitstatus-is-not-true

poly_data <- getData(name = "GADM", country = "PER", level = 1)

# create a factor variable out of NAME_1 so it can be merged easier with the production data
poly_data@data <- poly_data@data[order(poly_data@data$NAME_1),]
poly_data@data$NAME_1 <- factor(poly_data@data$NAME_1)

# load quinoa data
# load sumaria, modulo01, and modulo22 to MySQL "quinoa" database on Amazon RDS
con <- dbConnect(MySQL(),
                 user = 'rtenorio',
                 password = 'samsung29',
                 host = 'quinoa.cgi8bbclpmlt.us-west-2.rds.amazonaws.com',
                 dbname='quinoa')

modulo01 <- dbReadTable(con, "modulo01")
modulo07 <- dbReadTable(con, "modulo07_agg")

consumption_data <- left_join(modulo01, modulo07, by = c("year" = "year",
                                                         "month" = "mes",
                                                         "conglome" = "conglome",
                                                         "vivienda" = "vivienda",
                                                         "hogar" = "hogar",
                                                         "ubigeo" = "ubigeo",
                                                         "dominio" = "dominio",
                                                         "estrato" = "estrato"))

# do some exploring of the data
boxplot(p601b2 ~ year, data = consumption_data)

# compute summary statistics tabels
tapply(consumption_data$p601b2, consumption_data$year, summary)
var_consumption <- tapply(consumption_data$p601b2, consumption_data$year, var, na.rm = TRUE)
lines(var_consumption)
plot(consumption_data$p601b2[which(consumption_data$year == 2015)])

### break consumption into 4 groups
quant_consumption <- tapply(consumption_data$p601b2, consumption_data$year, quantile, na.rm = TRUE)

# create two new variables called x and y from the consumption data
consumption_data_2015 <- consumption_data[which(!is.na(consumption_data$longitud) & consumption_data$year == 2015 & 
                                                  !is.na(consumption_data$p601b2)),]
consumption_coord <- consumption_data_2015

consumption_coord$x <- consumption_coord$longitud
consumption_coord$y <- consumption_coord$latitud

rm("modulo01", "modulo07")

# set spatial coordinates to create a spatial object
coordinates(consumption_coord) = ~x + y

plot(consumption_coord)

# set the ranges for x and y using the ranges of lon and lat
x.range <- range(consumption_data_2015$longitud[which(!is.na(consumption_data_2015$longitud))])
y.range <- range(consumption_data_2015$latitud[which(!is.na(consumption_data_2015$latitud))])

# create a data frame from all combinations of the supplied vectors
# expand points to grid
grd <- expand.grid(x = seq(from = x.range[1], to = x.range[2], by = 0.1), y = seq(from = y.range[1], 
                                                                                  to = y.range[2], by = 0.1))  
coordinates(grd) <- ~x + y
gridded(grd) <- TRUE

plot(grd, cex = 1.5, col = "grey")

points(consumption_coord, pch = 1, col = "red", cex = 1)

# apply idw model for the data
idw <- idw(formula = p601b2 ~ 1, locations = consumption_coord, 
           newdata = grd) 

idw.output = as.data.frame(idw)  # output is defined as a data table
names(idw.output)[1:3] <- c("long", "lat", "var1.pred")  # give names to the modelled variables

# plot the results
ggplot() + geom_tile(data = idw.output, aes(x = long, y = lat, fill = var1.pred)) + 
  geom_point(data = consumption_data_2015, aes(x = longitud, y = latitud), shape = 21, 
             colour = "red")

# now add a map of Peru and change the colors
peru_contour_fort <- fortify(poly_data, region = "NAME_1")

ggplot() + geom_tile(data = idw.output, alpha = 0.8, aes(x = long, y = lat,
                                                         fill = round(var1.pred, 0))) + scale_fill_gradient(low = "cyan", high = "orange") + 
  geom_path(data = peru_contour_fort, aes(long, lat, group = group), colour = "grey") + 
  geom_point(data = consumption_data_2015, aes(x = longitud, y = latitud), shape = 21, 
             colour = "red") + labs(fill = "p601b2", title = "Quinoa Consumption in Kilos, 2015")

###################################### Remove Outliers #############################
consumption_out <- consumption_data[which(consumption_data$p601b2 < 1000 & consumption_data$p601b2 > 0),]

# do some exploring of the data
boxplot(p601b2 ~ year, data = consumption_out)

# compute summary statistics tabels
tapply(consumption_out$p601b2, consumption_out$year, summary)
var_consumption <- tapply(consumption_out$p601b2, consumption_out$year, var, na.rm = TRUE)
sd_consumption <- sapply(var_consumption, sqrt)
sd_consumption2 <- tapply(consumption_out$p601b2, consumption_out$year, sd, na.rm = TRUE)
plot(consumption_out$p601b2[which(consumption_out$year == 2015)])

quant_consumption <- tapply(consumption_out$p601b2, consumption_out$year, quantile, na.rm = TRUE)


# create two new variables called x and y from the consumption data
consumption_out_2015 <- consumption_out[which(!is.na(consumption_out$longitud) & consumption_out$year == 2015 & 
                                                !is.na(consumption_out$p601b2)),]
consumption_coord <- consumption_out_2015

consumption_coord$x <- consumption_coord$longitud
consumption_coord$y <- consumption_coord$latitud

# set spatial coordinates to create a spatial object
coordinates(consumption_coord) = ~x + y

plot(consumption_coord)

# set the ranges for x and y using the ranges of lon and lat
x.range <- range(consumption_out_2015$longitud[which(!is.na(consumption_out_2015$longitud))])
y.range <- range(consumption_out_2015$latitud[which(!is.na(consumption_out_2015$latitud))])

# create a data frame from all combinations of the supplied vectors
# expand points to grid
grd <- expand.grid(x = seq(from = x.range[1], to = x.range[2], by = 0.1), y = seq(from = y.range[1], 
                                                                                  to = y.range[2], by = 0.1))  
coordinates(grd) <- ~x + y
gridded(grd) <- TRUE

plot(grd, cex = 1.5, col = "grey")

points(consumption_coord, pch = 1, col = "red", cex = 1)

# apply idw model for the data
idw <- idw(formula = p601b2 ~ 1, locations = consumption_coord, 
           newdata = grd) 

idw.output = as.data.frame(idw)  # output is defined as a data table
names(idw.output)[1:3] <- c("long", "lat", "var1.pred")  # give names to the modelled variables

# plot the results
ggplot() + geom_tile(data = idw.output, aes(x = long, y = lat, fill = var1.pred)) + 
  geom_point(data = consumption_out_2015, aes(x = longitud, y = latitud), shape = 21, 
             colour = "red")

# now add a map of Peru and change the colors
#est_contour <- readShapePoly("population_in_municipalities_2011_wgs84.shp")
peru_contour_fort <- fortify(poly_data, region = "NAME_1")

ggplot() + geom_tile(data = idw.output, alpha = 0.8, aes(x = long, y = lat,
                                                         fill = round(var1.pred, 0))) + scale_fill_gradient(low = "cyan", high = "orange") + 
  geom_path(data = peru_contour_fort, aes(long, lat, group = group), colour = "grey") + 
  geom_point(data = consumption_out_2015, aes(x = longitud, y = latitud), shape = 21, 
             colour = "red") + labs(fill = "p601b2", title = "Quinoa Consumption in Kilos, 2015")


##################### maybe use logs of p601b2 to minimize outliers #################
consumption_data_l <- consumption_data[which(consumption_data$p601b2 > 0), c("year", "p601b2", "longitud", "latitud")]
consumption_data_l$p601b2_l <- log(consumption_data_l$p601b2)

# do some exploring of the data
boxplot(p601b2_l ~ year, data = consumption_data_l)

# compute summary statistics tabels
tapply(consumption_data_l$p601b2_l, consumption_data_l$year, summary)
var_consumption_l <- tapply(consumption_data_l$p601b2_l, consumption_data_l$year, var, na.rm = TRUE)
lines(var_consumption_l)
plot(var_consumption_l)

########## Make the Map using Logs #############

# create two new variables called x and y from the consumption data
consumption_data_l_2015 <- consumption_data_l[which(!is.na(consumption_data_l$longitud) & consumption_data_l$year == 2015 & 
                                                      !is.na(consumption_data_l$p601b2)),]
consumption_coord <- consumption_data_l_2015

consumption_coord$x <- consumption_coord$longitud
consumption_coord$y <- consumption_coord$latitud

# set spatial coordinates to create a spatial object
coordinates(consumption_coord) = ~x + y

plot(consumption_coord)

# set the ranges for x and y using the ranges of lon and lat
x.range <- range(consumption_data_l_2015$longitud[which(!is.na(consumption_data_l_2015$longitud))])
y.range <- range(consumption_data_l_2015$latitud[which(!is.na(consumption_data_l_2015$latitud))])

# create a data frame from all combinations of the supplied vectors
# expand points to grid
grd <- expand.grid(x = seq(from = x.range[1], to = x.range[2], by = 0.1), y = seq(from = y.range[1], 
                                                                                  to = y.range[2], by = 0.1))  
coordinates(grd) <- ~x + y
gridded(grd) <- TRUE

plot(grd, cex = 1.5, col = "grey")
points(consumption_coord, pch = 1, col = "red", cex = 1)

# apply idw model for the data
idw <- idw(formula = p601b2_l ~ 1, locations = consumption_coord, 
           newdata = grd) 

idw.output = as.data.frame(idw)  # output is defined as a data table
names(idw.output)[1:3] <- c("long", "lat", "var1.pred")  # give names to the modelled variables

# plot the results
ggplot() + geom_tile(data = idw.output, aes(x = long, y = lat, fill = var1.pred)) + 
  geom_point(data = consumption_data_l_2015, aes(x = longitud, y = latitud), shape = 21, 
             colour = "red")

# now add a map of Peru and change the colors
peru_contour_fort <- fortify(poly_data, region = "NAME_1")

ggplot() + geom_tile(data = idw.output, alpha = 0.8, aes(x = long, y = lat,
                                                         fill = round(var1.pred, 0))) + scale_fill_gradient(low = "cyan", high = "orange") + 
  geom_path(data = peru_contour_fort, aes(long, lat, group = group), colour = "grey") + 
  geom_point(data = consumption_data_l_2015, aes(x = longitud, y = latitud), shape = 21, 
             colour = "red") + labs(fill = "p601b2_l", title = "Quinoa Consumption in Kilos, 2015")


