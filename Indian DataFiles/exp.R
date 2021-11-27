#! /usr/bin/env Rscript
library(rgdal)

## STEPS
## 1. GET ALL HOUSEHOLD FILES that have "Synth_Households_(number).txt" format.
## 2. Make that File does not have the  lats and Longs filled.
## 3. Generate Sample households based on the Number of households.
##### 4. Test if any Households is within the roads file, dont have them in there. (Use Lee's code as referenced.)
## 4. Save the newly created Files.
# Key Function
# new_poly <- rgeos::gDifference(hyderabad, lakes, drop_lower_td = TRUE) // Param1: Bounding box shape file, lakes/roads/lakes
## Sample Coordinates based on Village Bounds Min and Max Lat and Longs and total Number of Households.
sample_locations <- function (minLat, maxLat, minLng, maxLng, total_households) {
  
  coords = matrix(c(minLng, minLat, minLng, maxLat, maxLng, maxLat, maxLng, minLat, minLng, minLat),  ncol = 2, byrow = TRUE)
  P1 = Polygon(coords)
  Ps1 = SpatialPolygons(list(Polygons(list(P1), ID = "a")), proj4string=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
  # plot(Ps1)
  if (total_households < 100000) {
    locs <- sp::spsample(Ps1, n = total_households, offset = c(0, 0), type = "random", iter = 50)
  } else {
    locs <- sp::spsample(Ps1, n = 100000, offset = c(0, 0), type = "random", iter = 50)
    sample_inds <- sample(x = 1:100000, size = total_households, replace = TRUE)
    locs@coords <- locs@coords[sample_inds, ]
    locs@coords[, 1] <- locs@coords[, 1] + rnorm(total_households, 0, noise)
    locs@coords[, 2] <- locs@coords[, 2] + rnorm(total_households, 0, noise)
  }
  plot(Ps1)
  #points(locs, col = "blue")
  return(locs)
  
}

generate_households_with_coordinates <- function (region_code) {
  
  filename = sprintf("/users/raheelsayeed/desktop/Synth_Households_%s_.txt", region_code)
  hhs <- read.csv(filename, sep = ",", stringsAsFactors = FALSE)
  nrow(hhs)
  lng1 <- 78.39029
  lat1 <- 17.30885
  lng2 <- 78.54092
  lat2 <- 17.51318
  locations = sample_locations (lat1, lat2, lng1, lng2, nrow(hhs))
  hhs$lat = locations@coords[,2]
  hhs$lng = locations@coords[,1]
  write.csv(hhs, file=sprintf("synth_households_%s.txt", region_code), quote = FALSE, row.names = FALSE)
  coords <- cbind(hhs$lng, hhs$lat)
  spoints  <- SpatialPoints(coords)
  return (spoints) 
  
}

sp = generate_households_with_coordinates("802925")
points(sp, col="red")







  