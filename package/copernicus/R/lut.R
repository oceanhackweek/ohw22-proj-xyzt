#' Read a look-up-table (LUT)
#'
#' @export
#' @param name character, the name of the LUT
#' @return tibble of LUT
read_lut <- function(name = "global-analysis-forecast-phy-001-024"){
  filename <- system.file(file.path("lut", name), package = 'copernicus')
  suppressMessages( readr::read_csv(filename) )
}
