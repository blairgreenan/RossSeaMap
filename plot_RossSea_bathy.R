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
#
# NOTE: I seem to have an issue with the map being displayed in the figure
# window. If that happens, just run the basemap command below on its own.

# Set working directory to the location of the bathymetry data
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

# VPR track from tow 8
setwd("C:/Users/greenanb/Documents/Science Projects/Current/Ross Sea/Documents/Papers/Ross Bank/Figures/VPR_Ross_Bank")
# load the tidyverse and lubridate packages
library(tidyverse)
library(lubridate)
# Use readr package to load the Video Plankton Recorder Tow 8
vpr8 <- read_delim("vpr8.txt", delim = " ", col_names = c("timestep", "gmt", "date", "latitude", "longitude", "bottom_depth", "alt", "roll", "pitch", "flow", "fluorescence", "PAR", "turbidity", "salinity", "temperature", "vprdepth"), col_types = "dddddddddddddddd")

# Now have to convert the latitude and longitude columns to a more useable format
tmp1 <- vpr8$latitude
lat_deg <- as.integer(trunc(tmp1/100))
lat_min <- ((tmp1/100) - trunc(tmp1/100))*100
# latitude in decimal degrees
lat_dec_deg <- lat_deg + (lat_min/60)
#if latitude is negative, then need to multiply minutes by -1
lat_deg_neg <- (lat_deg < 0)
lat_min[lat_deg_neg] <- (lat_min[lat_deg_neg] * -1)
rm(tmp1)
rm(lat_deg_neg)

tmp1 <- vpr8$longitude
lon_deg <- as.integer(trunc(tmp1/100))
lon_min <- ((tmp1/100) - trunc(tmp1/100))*100
# longitude in decimal degrees
lon_dec_deg <- lon_deg + (lon_min/60)
# convert negative longitude to positive by subtracting value from 360
lon_dec_deg_neg <- (lon_dec_deg < 0)
lon_dec_deg[lon_dec_deg_neg] = 360 + lon_dec_deg[lon_dec_deg_neg]
#if longitude is negative, then need to multiply minutes by -1
lon_deg_neg <- (lon_deg < 0)
lon_min[lon_deg_neg] <- (lon_min[lon_deg_neg] * -1)
rm(tmp1)
rm(lon_deg_neg)
rm(lon_dec_deg_neg)

# Create a data frame for the VPR Tow 8 track positions
dt2 <- data.frame(lat_dec_deg, lon_dec_deg)

# Create plot using the ggOceanMaps & ggspatial packages
basemap(shapefiles = list(land = bs_land, glacier = bs_ice_shelves, bathy = bs_bathy, 
                          name = "AntarcticStereographic"), bathymetry = TRUE, glaciers = TRUE, 
        limits = c(160, -160, -80, -70), lon.interval = 15, rotate = TRUE, base_size = 8) +  
  geom_spatial_point(data = dt2, aes(x = lon_dec_deg, y = lat_dec_deg), color = "black", size = 0.1) +  
  geom_spatial_point(data = dt, aes(x = lon, y = lat), color = "red", size = 0.5)

# switch the working directory back to the location of the Figures directory for
# the Ross Bank paper
setwd("C:/Users/greenanb/Documents/Science Projects/Current/Ross Sea/Documents/Papers/Ross Bank/Figures/RossSeaMap")
# Use ggsave to save a high resolution png file
ggsave("RossSea_ggsave.png", width = 10, height = 8, units = c("cm"), dpi = 1200, bg = "white")

# dev.off()


