rm(list = ls())

libraries <- c("stringr", "plyr", "dplyr")
lapply(libraries, library, character.only = TRUE)

options(header = TRUE, stringsAsFactors = FALSE)

wd_1 <- "/Users/rtenorio/Documents/Quinoa/ENAHO Data"
setwd(wd_1)

modules <- c("Summaria.csv", "Modulo07_agg.csv")

modules_list <- lapply(modules, read.csv)

names(modules_list) <- gsub(".csv", "", modules)
list2env(modules_list, envir = environment())

# aggregate Modulo07 data at the district level, taking the mean of amount consumed (p601b2) and amount spent (d601c)
Modulo07_dist <- aggregate(Modulo07_agg[, c("p601b2", "d601c")], by = list(year = Modulo07_agg$year, ubigeo = Modulo07_agg$ubigeo), FUN = mean)

# aggregate Modulo22 data at the district level, taking mean of agg dummy
Modulo22_dist <- aggregate(list(prop_agg = Modulo22$agg_dummy), by = list(year = Modulo22$año, ubigeo = Modulo22$ubigeo), FUN = mean)





