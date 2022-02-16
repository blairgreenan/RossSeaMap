# create_RossSea_bathy.R
# Blair Greenan
# Fisheries and Oceans Canada
# 11 Feb 2022
#
# R script to create a custom bathymetry data set from ETOPO1 and Natural Earth data
# https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/ice_surface/grid_registered/netcdf/
# http://www.naturalearthdata.com/downloads/10m-physical-vectors/ 
# The intent is to be able to create maps for plotting various figures
# related to data collected in the Ross Sea in 2011-12 at part of the PRISM
# field program

setwd("C:/Users/greenanb/Documents/Science Projects/Current/Ross Sea/Data/Ross Sea Bathymetry")

library(ggplot2)
library(sf)
library(ggOceanMaps)
library(ggOceanMapsData)
library(ggspatial)

dev.new()

# Need to increase memory limit for the R session which seems to default to the amount of RAM
memory.limit(size = 50000) 

# Set the longitude and latitude limits for the map
# The limits will be reduced when the actual map is plotted, but seem to need
# the full range of longitudes in order for this to work.
lims <- c(-180, 180, -90, -60)

# Path to the ETOPO1 grid file for bathymetry
etopoPath <- "./ETOPO1"

# Set projection to Antarctic polar stereographic
projection <- "EPSG:3031"
# Simple plot to ensure that the projection and limits are correct
basemap(limits = lims)

# Use ggOceanMaps to create a raster of the bathymetry with specified depth intevals
# https://mikkovihtakari.github.io/ggOceanMaps/articles/ggOceanMaps.html#advanced-use
rb <- raster_bathymetry(bathy = paste(etopoPath, "ETOPO1_Ice_g_gmt4.grd", sep = "/"),
depths = c(100, 200, 300, 400, 500, 1000, 2000, 4000, 6000),
proj.out = projection,
boundary = lims
)
class(rb)
names(rb)
raster::plot(rb$raster)

# Now we have the bathyRaster object which can be vectorized
bs_bathy <- vector_bathymetry(rb)
sp::plot(bs_bathy)

# path to Natural Earth data shapefiles
NEDPath <- "./"
# path to shapefile for land, bathymetry and ice shelves
outPath <- "./Shapefiles"

# Use the Natural Earth land and minor islands shapefiles to create a shapefile 
# that is clipped to the limits specifiec above in "lims"
world <- rgdal::readOGR(paste(NEDPath, "ne_10m_land/ne_10m_land.shp", sep = "/"))
islands <- rgdal::readOGR(paste(NEDPath, "ne_10m_minor_islands/ne_10m_minor_islands.shp", sep = "/"))
world <- rbind(world, islands)
bs_land <- clip_shapefile(world, lims)
bs_land <- sp::spTransform(bs_land, CRSobj = sp::CRS(projection))
rgeos::gIsValid(bs_land) # Has to return TRUE, if not use rgeos::gBuffer
bs_land <- rgeos::gBuffer(bs_land, byid = TRUE, width = 0)
sp::plot(bs_land)

# Use the Natural Earth Antarctic ice shelf shapefiles to create a shapefile 
# that is clipped to the limits specifiec above in "lims"
ice_shelves <- rgdal::readOGR(paste(NEDPath, "ne_10m_antarctic_ice_shelves_polys/ne_10m_antarctic_ice_shelves_polys.shp", sep = "/"))
rgeos::gIsValid(ice_shelves) # Needs buffering
ice_shelves <- rgeos::gBuffer(ice_shelves, byid = TRUE, width = 0)
bs_ice_shelves <- clip_shapefile(ice_shelves, lims)
bs_ice_shelves <- sp::spTransform(bs_ice_shelves, CRSobj = sp::CRS(projection))
rgeos::gIsValid(bs_ice_shelves)
sp::plot(bs_ice_shelves)

# Save the custom land, bathymetry and ice shelves shapefiles in one rda file
save(bs_bathy, bs_land, bs_ice_shelves, file = paste(outPath, "bs_shapes.rda", sep = "/"), compress = "xz")

# dev.off()

# Plot the map for the Ross Sea region
basemap(shapefiles = list(land = bs_land, glacier = bs_ice_shelves, bathy = bs_bathy, name = "AntarcticStereographic"), bathymetry = TRUE, glaciers = TRUE, limits = c(160, -160, -80, -70), lon.interval = 15, rotate = TRUE)


