#install.packages("RSelenium")
library("RSelenium")

unlink(file.path(find.package("RSelenium"), "bin"), recursive = TRUE, force = TRUE)
RSelenium::checkForServer()

selServ <- RSelenium::startServer(args = c("-port 5556"))
remDr <- RSelenium::remoteDriver(browserName = "chrome", 
                                 extraCapabilities = list(marionette = TRUE),
                                 port=5556)

# open the browser and navigate to the INEI page
# remember to open the selenium server 
remDr$open()
remDr$navigate("http://iinei.inei.gob.pe/microdatos/")

# Select "Consulta por Encuestas" to navigate to the encuestas form
webElem1 <- remDr$findElement(using = "xpath", value= "//*[@id=\"jsmenu\"]/li[1]/a")
webElem1$clickElement()

# take a break
Sys.sleep(5)

# Select "ENAHO Metodologia ACTUALIZADA"
webElem2 <- remDr$findElement(using = "xpath", value = "//option[contains(@value, '2')]")
webElem2$clickElement()

# take a break
Sys.sleep(5)

# Select "Condiciones de Vida y Pobreza - ENAHO"
webElem3 <- remDr$findElement(using = "xpath", value = "//*[@id=\"ENAHON\"]/select/option[2]")
webElem3$clickElement()

# another break
Sys.sleep(5)

scrap_yearly_stata <- function(year = NA) {
  # Select the years from the Ano menu - I can use lapply to create a list and loop through the list elements to do multiple years quickly
  webElem4 <- remDr$findElement(using = "xpath", value = paste("//*[@id=\"divAnio\"]/select/option[contains(@value,'",year,"')]", sep=""))
  webElem4$clickElement()
  
  # and another break
  Sys.sleep(5)
  
  # Select "Anual - (Ene-Dic)" from the Periodo menu
  webElem5 <- remDr$findElement(using = "xpath", value = "//option[contains(@value, '55')]")
  webElem5$clickElement()
  
  # one more break
  Sys.sleep(5)
  
  # Download all of the Stata files for each year, placing them in the downloads folder,
  # because I can't figure out how to make new folders each time
  webElem_links <- remDr$findElements(using = "xpath", "//a[contains(@href,'STATA')]")
  lapply(webElem_links, function(x) x$clickElement())
  
  Sys.sleep(5)
}

lapply(2004:2015, function(x) scrap_yearly_stata(x))

remDr$close()

