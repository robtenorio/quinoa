

rm(list = ls())


libraries <- c("dplyr", "RMySQL", "raster")
lapply(libraries, library, character.only = TRUE)

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
                                                         "conglome" = "conglomer",
                                                         "vivienda" = "vivienda",
                                                         "hogar" = "hogar",
                                                         "ubigeo" = "ubigeo",
                                                         "dominio" = "dominio",
                                                         "estrato" = "estrato"))

consumption <- dbGetQuery(con, paste("SELECT * FROM modulo01 LEFT JOIN modulo07_agg ON",
                                     "modulo01.year = modulo07_agg.year AND",
                                     "modulo01.month = modulo07_agg.mes AND",
                                     "modulo01.conglome = modulo07_agg.conglome AND",
                                     "modulo01.vivienda = modulo07_agg.vivienda AND",
                                     "modulo01.hogar = modulo07_agg.hogar AND",
                                     "modulo01.ubigeo = modulo07_agg.ubigeo AND",
                                     "modulo01.dominio = modulo07_agg.dominio AND",
                                     "modulo01.estrato = modulo07_agg.estrato;", 
                                     sep = " "))

