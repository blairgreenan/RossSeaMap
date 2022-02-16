# plot_RossSea_bathy.R
# Blair Greenan
# Fisheries and Oceans Canada
# 11 Feb 2022
#
# R script to plot a map of the Ross Sea using ETOPO1 and Natural Earth data
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

# path to shapefile for land, bathymetry and ice shelves
outPath <- "./Shapefiles"

# Set projection to Antarctic polar stereographic
projection <- "EPSG:3031"

dev.new()

# load the shapefile for the Ross Sea area based on extraction from the Natural Earth shapefiles
load(file = paste(outPath, "bs_shapes.rda", sep = "/"))

#dt <- data.frame(lon = c(160, 160, -160, -160), lat = c(60, 80, 80, 60))
# SeaHorse mooring position
dt <- data.frame(lon = 179.2532, lat = -76.6601)

# create plot using the ggOceanMaps & ggspatial packages
basemap(shapefiles = list(land = bs_land, glacier = bs_ice_shelves, bathy = bs_bathy, name = "AntarcticStereographic"), bathymetry = TRUE, glaciers = TRUE, limits = c(160, -160, -80, -70), lon.interval = 15, rotate = TRUE) +  geom_spatial_point(data = dt, aes(x = lon, y = lat), color = "red")

# dev.off()


