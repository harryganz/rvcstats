rvcstats
========

# Reef Visual Census statistical package in R

## Description
The rvcstats package is designed to compute summary statistics, such as: fish density, frequency of occurrence, and length frequencies for Reef Visual Census data, which can then be output to csv files or turned into graphs.

## Installation
### The Easy Way
1. In R, type the following:
```
install.packages('devtools')
devtools::install_github('jeremiaheb/rvcstats/rvcstats')
```
You can skip the first line if you already have devtools installed.

The disadvantage of this is that it makes you download R devtools first.

### The Hard Way
1. Download the compressed source folder named "rvcstats_[version].tar.gz" from the root directory of this project
2. Type the following in R  
```
install.packages("[path_to_file]/rvcstats_[version].tar.gz", repos = NULL, type="source")
library(rvcstats)
``` 
* Where [path_to_file] is the path to the directory containing the downloaded source folder and [version] is the version       number

## How to use this package
First, read the data off the server using the rvcData function. Best practice is to pull off
all the data you will need first then break it in to smaller chunks, if necessary,
for analysis.
* Note: only one region can be pulled off at a time

```
library(rvcstats)
## Pull data for red (Epinephelus morio) and black grouper (Mycteroperca bonaci)
## off of the server for 2010-2012 in the florida keys
grouper <- rvcData(species = c('Epinephelus morio', 'MYC BONA'), year = 2010:2012,
region = 'FLA KEYS')
```
The rvcData and select functions output RVC objects which are basically lists of the 'analysis ready' sample data and stratum data, but the output is fairly raw and not useful without knowledge of how the Reef Visual Census is conducted.

If you would like to do statistics on only one species you can use the select function.

```
## Select red grouper from grouper
red_grouper <- select(grouper, species = "EPI MORI")
```

The select function can also be used to select specific years, strata, and protected statuses. Complete function
descriptions for rvcData and select can be found in the R help files for each function (type ?function\_name into the interactive console, where function\_name is the name of the function you need help with).

Once you have subset the data, you can calculate summary statistics using the getStat function.

```
## Density for red grouper, with protected and unprotected areas
## merged together
red_grouper_dens <- getStat(red_grouper, level = "domain", stat = "density",
merge_protected = TRUE)

## Utilizing the when_present argument, you can calculate density when present
## Here the statistic is being calculated at the stratum level
red_grouper_dens_when_pres <- getStat(red_grouper, level = "stratum",
stat = "density", when_present = TRUE,
merge_protected = FALSE)

## Options from select can also be passed to the getStat function
## Here we pass the species argument to select
## Only black grouper
black_grouper_occ <- getStat(grouper, species = "MYC BONA", level = "domain",
stat = "occurrence", merge_protected = FALSE)
```

There are three required arguments for getStat:
* x: the RVC object produced by either the rvcData function or the select function. It should contain all the species, years, and strata for which you wish to calculate summary statistics
* level: a keyword of either "domain" or "stratum" indicating the level at which you wish to calculate the summary statistic
* stat: a keyword indicating the summary statistic you wish to calculate, the available statistics are:
	* "density": The average number of individuals counted per sampling station (177m^2)
	* "occurrence": The estimated probability of encountering an individual in a sampling station.
	* "abundance": The estimated total count extrapolated over the sampling domain
	* "length_frequency": The estimated frequency of a set of lengths generated from observed data
		* the length frequency data is generated from the minimum median and maximum length at each station fit to a probability distribution.
	* "biomass": The estimated total biomass extrapolated over the sampling domain
		* Requires allometric growth parameters to be input, see the growth_parameters argument description below.

**NOTE**: All of the above statistics are indices, not model-based estimates. They indicate the synoptic count data, and any conclusions drawn from them are subject to the relationship between counts and actual abundance.  

Optional arguments are:
* when_present: a boolean indicating whether or not to calculate the statistic only for stations where the species was present (default = FALSE)
* merge_protected: a boolean indicating whether the statistic should be calculated for both protected and unprotected areas together (TRUE) or separately (FALSE), the default is TRUE.
* growth_parameters: 
  * If x contains a signle species: a list of the allometric growth parameters, including one named, 'a', the linear coefficient, and, 'b', the exponential  coefficient. If stat is set to 'biomass' and growth\_parameters is NULL, getStat will attempt to get the allometric growth parameters from the server. If they are not available, getStat will raise an error.
  * If x contains multiple species:  A list of lists, with each key a species code with underscores instead of spaces and each value a list of growth parameters in the same format as for a single species. e.g. growth\_parameters = list(EPI\_MORI = list(a=1e-6, b=3), MYC\_BONA = list(a=1.12e-5,b=2.88)). 
* length_class: 
  * If x contains a single species: a number or keyword indicating a break point between two length classes. Available keywords are "LM" for median length-at-maturity and "LC" for minimum length-at-capture (usually the legal minimum size). If a keyword is used, getStat will attempt to retrieve the values from the server. If a number is used, getStat will use that number as the length, in centimeters, at which to set the breakpoint. Break is non-inclusive for the lower interval and inclusive for the upper (i.e. lower > break >= upper).
  * If x contains multiple species: a list with each key a species code with underscores instead of spaces and each value a number or keyword in the the same format as for a single species. e.g. length\_class = list(EPI\_MORI = "LC", MYC\_BONA = 62). If a species is left out, function will return statistic for all length classes combined. 

## A short list of functions and their descriptions
1. rvcData(species, year, stratum, server): Pulls data off the server by the provided arguments and produces an RVC object.
2. select(x, species, year, stratum, protected): subsets an RVC object x to produce a new RVC object.
3. getStat(x, level, stat, growth\_parameters, merge\_protected, when\_present, length\_class): produces a data.frame of summary statistics, 'stat', from an RVC object, 'x', at the level, 'level', with the other options provided.
4. getLhp(species, server): retrieves life history parameter data for provided species from server
5. getSampleData(species, year, region, stratum, protected, when_present, server): a lower-level function which retrieves the sample data from the server
6. getStratumData(year, region, stratum, protected, server): a lower-level
function which retrieves the stratum data from the server
