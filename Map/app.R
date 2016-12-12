
library(dplyr)
library(leaflet)
library(shiny)
library(shinyapps)
library(raster)

year_choices <- c(2004:2012)

ui <- fluidPage(
  titlePanel("Peruvian Quinoa Production by Region in '000kg/hectare (2004 - 2012)"),
  selectInput(inputId = "year", label = "Select a Year",
              choices = year_choices, multiple = FALSE),
  leafletOutput("quinoa_regions_map")
             )

server <- function(input, output, session) {
  
  # create a reactive value for year input
  year_react <- eventReactive(input$year, {
    input$year
  })
  
  output$quinoa_regions_map <- renderLeaflet({
    
    poly_data <- getData(name = "GADM", country = "PER", level = 1)
    # create a factor variable out of NAME_1 so it can be merged easier with the production data
    poly_data@data <- poly_data@data[order(poly_data@data$NAME_1),]
    poly_data@data$NAME_1 <- factor(poly_data@data$NAME_1)
    
    ### load quinoa production data
    quinoa_production <- readRDS("quinoa_production.rds")
    # remove peru rows
    quinoa_production <- quinoa_production[which(!quinoa_production$depa == "peru"),]
    # change the names of Lima and Lima Metropolitana so they match the names in the poly_data
    quinoa_production$depa[which(quinoa_production$depa == "Lima")] <- "Lima Province"
    quinoa_production$depa[which(quinoa_production$depa == "Lima Metropolitana")] <- "Lima"
    # create a factor variable of the department variable to better match the factor variable in the poly data
    quinoa_production <- quinoa_production[order(quinoa_production$depa),]
    quinoa_production$depa <- factor(quinoa_production$depa, labels = unique(poly_data@data$NAME_1))
    
    # use just most recent year for quinoa production
    quinoa_production_recent <- quinoa_production[which(quinoa_production$year %in% year_react()),]
    
    # join the quinoa production with the data attribute of the polydata object
    new_poly_data <- left_join(poly_data@data, quinoa_production_recent, by = c("NAME_1" = "depa"))
    
    ### Replace the original polygonal data frame with the new joined data frame
    poly_data@data <- new_poly_data
    
    # Set a popup that will show country name and production for Year
    popup <- paste0(
      poly_data$NAME_1,"<br>","Production: ", poly_data$prod
    )
    # Set continous palette as a function of production
    pal <- colorNumeric(
      palette = "Blues",
      domain = poly_data$prod
    )
    
    map1 <- leaflet() %>%
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
        title = "'000kg/hectare for Selected Year"
      )
    
    map1

  })
  
}

shinyApp(server = server, ui = ui)