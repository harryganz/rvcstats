#' Get RVC data from server
#' @export
#' @description Creates an RVC data object from Reef Visual Census
#' data located on a remote server
#' @name rvcData
#' @param species
#' A character vector of scientific names or species codes,
#' e.g. 'Lutjanus griseus' or 'LUT GRIS' (not case-sensitive).
#' @param year
#' A numeric vector of the years to select from data. 
#' @param region
#' A string of the region code to select from 
#' data. Only one region allowed at a time. 
#' @param server
#' A string indicating the location of the server. Can
#' be an IP address or URL
#' @seealso \code{\link{select}} \code{\link{getStat}}
#' @return Returns an RVC object with three elements:
#' \item{sample_data}{A data frame containing the analysis ready sample data}
#' \item{stratum_data}{A data frame containing data about the stratum, including the number of 
#' possible primary sample units per stratum (NTOT)}
#' \item{lhp_data}{A data frame containing life history parameter data, including 
#' minimum length-at-capture (LC), median length-at-maturity (LM), and the allometric growth
#' parameters (WLEN_A, WLEN_B).
#'  NULL if no life history data available for selected species}
#' @examples
#' ## Names not case-sensitive
#' rvcData(species = 'Epinephelus morio', year = 2012, region = 'FLA KEYS')
#' ## Can pass multiple species and years
#' rvcData(c('LUT GRIS', 'LUT ANAL'), year = c(2010, 2012), region = 'FLA KEYS',
#' server = '127.0.0.1:3000')
#' @note
#' Best practice it to pull off the maximum amount of data you
#' plan on working with first using \code{\link{rvcData}},
#' and then to use the \code{\link{select}}
#' function to break it into smaller manageable bits. This reduces the 
#' time spent downloading it from the server. 
rvcData = function(species, year, region,
                   server = 'http://localhost:3000'){  
  ## Parse full scientific names are trucated to SPECIES_CD
  species <- toSpcCd(species);
  ## Make region codes upper case if not already
  region  <- toupper(region);
  ## If more than one region raise error
  if (length(region)>1){
    stop('only one region can be selected at a time')
  }
  message("starting to retrieve data from server, this could
          take a few minutes ... ")
  ## Get Data from server
  sample_data  <- suppressMessages(getSampleData(species, year, region, server=server));
  stratum_data  <- getStratumData(year, region, server=server);
  # Get life history parameter data from server,
  # warn and return NULL if none found
  lhp_data  <- tryCatch(
    {getLhp(species, server=server)},
    error = function(cond){
      warning(cond)
      return(NULL)
    });
  message("... completed retrieving data")
  ## Create output, set class to RVC, and return
  out  <- structure(list(sample_data = sample_data, stratum_data = stratum_data,
                         lhp_data = lhp_data),
                    class="RVC");
  return(out)
}