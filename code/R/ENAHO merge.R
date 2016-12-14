rm(list = ls())

libraries <- c("foreign", "stringr", "plyr", "dplyr", "RMySQL")
lapply(libraries, library, character.only = TRUE)

# save ENAHO directory
wd_1 <- ###
setwd(wd_1)
# unzip all the .zip files found in the ENAHO directory
enaho_zips <- list.files(wd_1, pattern = ".zip")
# keep a list of modulo01, modulo22, and modulo34
modulos_keep <- c("(Modulo01)", "(Modulo22)", "(Modulo34)")
enaho_zips_keep <- enaho_zips[unlist(lapply(modulos_keep, grep, enaho_zips))]
enaho_unzips <- unlist(lapply(enaho_zips_keep, unzip))
Encoding(enaho_unzips) <- "latin1"
# keep a list of .dta files
dta_files <- enaho_unzips[which(grepl("(.dta)|(.DTA)", enaho_unzips))]

# now read in each module
dta_data <- lapply(dta_files, read.dta)
# name each module with the file name
names(dta_data) <- tolower(gsub("(./)|(.dta)", "", dta_files))

# encode and lower the names of the dta_data frames
names_encoding <- function(df = NULL){
  names(df) <- lapply(names(df), `Encoding<-`, "latin1")
  names(df) <- tolower(names(df))
  df <- as.data.frame(lapply(df, as.character), stringsAsFactors = FALSE)
  df <- as.data.frame(lapply(df, `Encoding<-`, "latin1"), stringsAsFactors = FALSE)
  return(df)
}

dta_data <- lapply(dta_data, names_encoding)

# relabel all the names for each group of data sets to make them easier to identify
# sumaria
names(dta_data)[which(grepl("(sumaria)", names(dta_data)))] <- paste("sumaria_", str_extract(names(dta_data)[which(grepl("(sumaria)", names(dta_data)))], 
                                                                           paste("(", 2004:2015, ")", sep = "", collapse = "|")), sep = "")
# module 1 (100)
names(dta_data)[which(grepl("(enaho01)", names(dta_data)))] <- paste("modulo01_", str_extract(names(dta_data)[which(grepl("(enaho01)", names(dta_data)))], 
                                                                           paste("(", 2004:2015, ")", sep = "", collapse = "|")), sep = "")
# module 22 (210a and 2000)
names(dta_data)[which(grepl("(210a)|(\\b2000\\b)", names(dta_data)))] <- paste("modulo22_", str_extract(names(dta_data)[which(grepl("(210a)|(\\b2000\\b)", names(dta_data)))], 
                                                                                       paste("(", 2004:2015, ")", sep = "", collapse = "|")), sep = "")
# keep only the modules of interest
dta_data <- dta_data[which(grepl(c("(modulo01)|(modulo22)|(sumaria)"), names(dta_data)))]

## bind all the modulo01 data frames -- HH longitude, latitude, and altitude
dta_data_modulo01 <- do.call(rbind.fill, dta_data[which(grepl(c("(modulo01)"), names(dta_data)))])

### Keep just the columns in which we're interested
keep_modulo01_columns <- c("año", "mes", "conglome", "vivienda", "hogar", "ubigeo", 
                           "dominio", "estrato", "longitud", "latitud", "altitud")

modulo01_data <- dta_data_modulo01[, which(names(dta_data_modulo01) %in% keep_modulo01_columns)]

# there are some crazy stars under latitud -- let's remove these before making it numeric
modulo01_data$latitud <- gsub("[*]", "", modulo01_data$latitud)
'numeric_cols <- as.data.frame(lapply(modulo01_data[, which(!names(modulo01_data) %in% c("dominio", "estrato"))], as.numeric), stringsAsFactors = FALSE)
length(which(is.na(modulo01_data$latitud)))
length(which(is.na(numeric_cols$latitud)))
table(modulo01_data[which(is.na(numeric_cols$latitud)), "latitud"])
'
# change numeric columns class to numeric
modulo01_data[, which(!names(modulo01_data) %in% c("dominio", "estrato"))]  <- lapply(modulo01_data[, which(!names(modulo01_data) %in% c("dominio", "estrato"))], as.numeric)

## bind all the modulo22 data frames -- agriculture producer HH
dta_data_modulo22 <- do.call(rbind.fill, dta_data[which(grepl(c("(modulo22)"), names(dta_data)))])

# keep only the columns of interest
keep_modulo22_columns <- c("año", "mes", "conglome", "vivienda", "hogar", "ubigeo", 
                           "dominio", "estrato", "p20001a")

modulo22_data_sub <- dta_data_modulo22[, which(names(dta_data_modulo22) %in% keep_modulo22_columns)]

# change numeric columns class to numeric
modulo22_data_sub[, which(!names(modulo22_data_sub) %in% c("dominio", "estrato"))]  <- lapply(modulo22_data_sub[, which(!names(modulo22_data_sub) %in% c("dominio", "estrato"))], as.numeric)

## aggregate modulo22 at the household level
modulo22_data <- aggregate(modulo22_data_sub$p20001a, by = list(año = modulo22_data_sub$año, mes = modulo22_data_sub$mes, conglome = modulo22_data_sub$conglome, vivienda = modulo22_data_sub$vivienda, 
                                                                hogar = modulo22_data_sub$hogar, ubigeo = modulo22_data_sub$ubigeo, dominio = modulo22_data_sub$dominio, estrato = modulo22_data_sub$estrato), max)

names(modulo22_data)[which(names(modulo22_data) == "x")] <- "agg_dummy"

# According to the diccionario, there should only be 0 or 1 in agg_dummy, so let's make all non-0,1s NA
modulo22_data$agg_dummy[which(!modulo22_data$agg_dummy %in% c(0,1) & !is.na(modulo22_data$agg_dummy))] <- NA

## bind all the sumaria data frames -- household summary statistics annualized
dta_data_sumaria <- do.call(rbind.fill, dta_data[which(grepl(c("(sumaria)"), names(dta_data)))])

# keep only the columns of interest
keep_sumaria_columns <- c("año", "mes", "conglome", "vivienda", "hogar", "ubigeo", "dominio", "estrato",
                          "percepho", "mieperho", "gru11hd", "gru12hd1", "gru12hd2", "gru13hd1", "gru13hd2",
                          "gru13hd3", "sg23", "gru21hd", "gru31hd", "gru41hd", "gru51hd", "gru61hd", "gru71hd",
                          "gru81hd", "inghog2d", "inghog1d", "ingmo1hd", "ingmo2hd", 
                          "gashog1d", "gashog2d", "linpe", "linea", "pobreza", "factor07")

sumaria_data <- dta_data_sumaria[, which(names(dta_data_sumaria) %in% keep_sumaria_columns)]

# change numeric columns class to numeric
sumaria_data[, which(!names(sumaria_data) %in% c("dominio", "estrato", "pobreza"))]  <- lapply(sumaria_data[, which(!names(sumaria_data) %in% c("dominio", "estrato", "pobreza"))], as.numeric)

# change some column names that won't show up well in MySQL
'modulo01_data <- rename(modulo01_data, c("año"="year", "mes" = "month"))
modulo22_data <- rename(modulo22_data, c("año"="year", "mes" = "month"))
sumaria_data <- rename(sumaria_data, c("año"="year", "mes" = "month"))
'

write.csv(modulo01_data, "Modulo01.csv", row.names = FALSE)
write.csv(modulo22_data, "Modulo22.csv", row.names = FALSE)
write.csv(sumaria_data, "Sumaria.csv", row.names = FALSE)

# load sumaria, modulo01, and modulo22 to MySQL "quinoa" database on Amazon RDS
con <- dbConnect(MySQL(),
                 user = 'rtenorio',
                 password = ###,
                 host = 'quinoa.cgi8bbclpmlt.us-west-2.rds.amazonaws.com',
                 dbname='quinoa')

dbWriteTable(conn = con, name = 'sumaria', value = sumaria_data, overwrite = TRUE, row.names = FALSE)
dbWriteTable(conn = con, name = 'modulo01', value = modulo01_data, overwrite = TRUE, row.names = FALSE)
dbWriteTable(conn = con, name = 'modulo22', value = modulo22_data, overwrite = TRUE, row.names = FALSE)

## Remove some data because they're too big to store in memory
rm(list = c("dta_data", "dta_data_modulo01", "dta_data_modulo22", "dta_data_sumaria",
            "modulo01_data", "modulo22_data", "modulo22_data_sub", "sumaria_data"))

# read in quinoa consumption data
enaho_unzips_07 <- unlist(lapply(enaho_zips[which(grepl("Modulo07", enaho_zips))], unzip))
Encoding(enaho_unzips_07) <- "latin1"
# keep a list of .dta files
dta_files_07 <- enaho_unzips_07[which(grepl("(.dta)|(.DTA)", enaho_unzips_07))]

# now read in each module
read_07 <- function(x = NULL){
  df <- read.dta(x)
  Encoding(names(df)) <- "latin1"
  names(df) <- tolower(names(df))
  names_keep <- c("año", "mes", "conglome", "vivienda", "hogar", "ubigeo", "dominio", 
                       "estrato", "p601a", "p601b", "p601a1", "p601a2", "p601a3", "p601a4", 
                       "p601a5", "p601a6", "p601a7", "p601b1", "p601b2", "p601b3", "p601c", 
                       "p601d1", "p601d2", "p601d3", "i601d2", "d601c", "factor07")
  if(!"año" %in% names(df)){
    names(df)[1] <- "año"
  }
  if(!"d601c" %in% names(df)){
    names(df)[which(names(df) == "d601e")] <- "d601c"
  }
  df <- df[, names_keep]
  df <- df[which(df$p601a %in% c("1700", "1701", "1702")),]
  # encode data
  df <- as.data.frame(lapply(df, as.character), stringsAsFactors = FALSE)
  df <- as.data.frame(lapply(df, `Encoding<-`, "latin1"), stringsAsFactors = FALSE)
  
  return(df)
  
}
# apply the function to all 12 data sets
dta_data_07 <- lapply(dta_files_07, read_07)

# name each module with the file name
names(dta_data_07) <- tolower(gsub("(./)|(.dta)", "", dta_files_07))
names(dta_data_07) <- paste("modulo07_", str_extract(names(dta_data_07), paste("(", 2004:2015, ")", sep = "", collapse = "|")), sep = "")

modulo07_data <- do.call(rbind.fill, dta_data_07)

# change "pase" to NA
modulo07_data[modulo07_data == "pase"] <- NA
# change the consumption provenance variables
modulo07_data$p601a1[which(modulo07_data$p601a1 == "comprado")] <- "1"
modulo07_data$p601a2[which(modulo07_data$p601a2 == "autoconsumo")] <- "1"
modulo07_data$p601a3[which(modulo07_data$p601a3 == "autosuministro")] <- "1"
modulo07_data$p601a4[which(modulo07_data$p601a4 == "como parte de pago a un miembro del hogar")] <- "1"
modulo07_data$p601a5[which(modulo07_data$p601a5 == "regalado o pagado por algún miembro de otro hogar")] <- "1"
modulo07_data$p601a6[which(modulo07_data$p601a6 == "regalado o donado por algún programa social")] <- "1"
modulo07_data$p601a7[which(modulo07_data$p601a7 == "otro")] <- "1"

NAs_07_a <- lapply(modulo07_data, function(x) which(is.na(x)))

# change numeric columns class to numeric
modulo07_data[, which(!names(modulo07_data) %in% c("dominio", "estrato", "p601b", "p601a1", 
                                                   "p601b1", "p601b3", "p601d1", "p601d3"))]  <- lapply(modulo07_data[, which(!names(modulo07_data) %in% c("dominio", "estrato", "p601b", "p601a1", 
                                                                                                                                                         "p601b1", "p601b3", "p601d1", "p601d3"))], as.numeric)

names(modulo07_data)[which(names(modulo07_data) == "año")] <- "year"

### Aggregate Modulo07
modulo07_agg <- modulo07_data[, c("year", "mes", "conglome", "vivienda",
                                  "hogar", "ubigeo", "dominio", "estrato",
                                  "p601b2", "p601b3", "d601c")]

# convert gramos to kilograms
modulo07_agg$p601b2[which(modulo07_agg$p601b3 == "gramos")] <- modulo07_agg$p601b2[which(modulo07_agg$p601b3 == "gramos")]/1000

# remove p601b3 
modulo07_agg <- modulo07_agg[, which(names(modulo07_agg) != "p601b3")]
# change NAs to 0 so they can all be summed
modulo07_agg$p601b2[which(is.na(modulo07_agg$p601b2))] <- 0
modulo07_agg$d601c[which(is.na(modulo07_agg$d601c))] <- 0

# aggregate modulo07 data, taking the sum of amount consumed (p601b2) and amount spent (d601c)
modulo07_agg <- aggregate(modulo07_agg[, c("p601b2", "d601c")], by = list(year = modulo07_agg$year, mes = modulo07_agg$mes, conglome = modulo07_agg$conglome, vivienda = modulo07_agg$vivienda, 
                                                       hogar = modulo07_agg$hogar, ubigeo = modulo07_agg$ubigeo, dominio = modulo07_agg$dominio, estrato = modulo07_agg$estrato), FUN = sum)
write.csv(modulo07_agg, "Modulo07_agg.csv", row.names = FALSE)

dbWriteTable(conn = con, name = 'modulo07_agg', value = modulo07_agg, overwrite = TRUE, row.names = FALSE)
dbWriteTable(conn = con, name = 'modulo07_data', value = modulo07_data, overwrite = TRUE, row.names = FALSE)

rm("modulo07_agg", "modulo07_data")

# ensure that nothing was coerced to NA that shouldn't be
'NAs_07_b <- lapply(modulo07_data_temp, function(x) which(is.na(x)))

setdiff_NAs <- lapply(c(1:27), function(x) which(!NAs_07_b[[x]] %in% NAs_07_a[[x]]))

lapply(setdiff_NAs, length)

lapply(c(1:27), function(x) table(modulo07_data[setdiff_NAs[[x]], x]))'


### join both data frames together
data_joined <- left_join(data, modulo07_data, by = c("año", "mes", "conglome", "vivienda", 
                                                     "hogar", "ubigeo", "dominio", "estrato"))

nrow(data_joined) == nrow(data) + nrow(modulo07_data)
