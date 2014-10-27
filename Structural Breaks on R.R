# We erase whatever is on the "environment"
rm(list=ls())
# We clear the "Console" screen
cat("\014")
# Set working directory
setwd("C:/Users/Luis Miguel/Documents/Bases de Datos/md4stata/WDI")
# what packages are loaded?
search()

####################################################################################
# Select country
ctry <- "PER"
####################################################################################

# Open database (but only some variables)
library(foreign)  # I need to load this package to be able to read .dta
wdi <- read.dta("wdi2013.dta")

####################################################################################
# Select country
wdi_gdp <- subset(wdi,
                  subset = wbcode==ctry,
                  select = c("wbcode", "country", "year", "NY_GDP_PCAP_KD",
                             "SP_POP_TOTL"))
####################################################################################

# Creating and naming variables in log
loggdppc <- log10(wdi_gdp$NY_GDP_PCAP_KD)
year <- wdi_gdp$year

# Store data as time series
y <- ts(na.omit(loggdppc), start =1960)
y.range <- attributes(y)$tsp
year.t <- year[year %in% y.range[1]:y.range[2]]
plot.ts(y)

# Structural Breaks in series
library(strucchange)  # I need to load this package to be able to rename
  # Empirical Fluctuation Processes: OLS-CUSUM
  #ocus.y <- efp(y ~ year.t, type = "OLS-CUSUM")
  #attr(x = ocus.y$process, "tsp") <- attributes(y)$tsp
  #plot(ocus.y)
  # Empirical Fluctuation Processes: RECURSIVE ESTIMATES
  #re.gdp <- efp(y ~ year.t, type = "RE")
  #plot(re.gdp)
  # F Statistics
  #fs.gdp <- Fstats(y ~ year.t,,from = 0.1)
  #plot(fs.gdp)
  # Breaking points
  bp.gdp <- breakpoints(y ~ year.t) # bp = maximal # allowed by h = 0.15 (default)
  plot(bp.gdp)
  # Extracting breaking points
  summary(bp.gdp)
  year.t[bp.gdp$breakpoints]

# Saving
year.t[bp.gdp$breakpoints]
wdi_gdp$milestone <- ifelse(wdi_gdp$year == year.t[bp.gdp$breakpoints][1] | 
                        wdi_gdp$year == year.t[bp.gdp$breakpoints][2] |
                      wdi_gdp$year == year.t[bp.gdp$breakpoints][3],1,0)
write.dta(dataframe = wdi_gdp, "C:/Users/Luis Miguel/Documents/Bases de Datos/md4stata/wdi_ctry.dta")
