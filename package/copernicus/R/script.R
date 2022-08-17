#' Read shell script into a characater array
#'
#' @export
#' @param name character, the name of the script file
#' @param path character, the path to the script
#' @return named character vector with 'app' and 'param'
read_script <- function(name = "global-analysis-forecast-phy-001-024",
                        path = system.file("scripts", package = "copernicus")){
  filename <- file.path(path[1], name[1])
  x <- readLines(filename)
  ix <- regexpr("\\s", x)
  c("app" = substring(x, 1, ix-1),
    "param" = substring(x, ix+1, nchar(x)))
}

#' Populate a script
#'
#' @export
#' @param template the name of the script template
#' @param bb 4 element bounding box [west, east, south, north]
#' @param dates 2 element Date or Date-castable, [start, stop]
#' @param times 2 element character vector, times (default is 12:00:00)
#' @param depths 2 element numeric,  depth [min, max]
#' @param variables character vector, variable names
#' @param out_dir character, output directory
#' @param out_name character, output filename
#' @param username character or NULL, (if NULL get from options)
#' @param password character or NULL, (if NULL get from options)
#' @param ... ignored
#' @return 2 element character vector of 'app' and 'param'
populate_script <- function(template = read_script(),
                            bb = c(-77, -42.5, 36.5, 56.7),
                            dates = Sys.Date() + c(-2, -1),
                            times = c("01:00:00", "23:00:00"),
                            depths = c(0.493, 0.4942),
                            variables = c("bottomT", "mlotst", "siconc", "sithick",
                                         "so", "thetao", "uo",
                                         "usi", "vo", "vsi", "zos"),
                            out_dir = ".",
                            out_name = sprintf("copernicus_%s.nc",
                                               format(Sys.Date(), "%Y-%m-%d")),
                            username = NULL,
                            password = NULL,
                            ...){

# python -m motuclient --motu http://nrt.cmems-du.eu/motu-web/Motu --service-id GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS --product-id global-analysis-forecast-phy-001-024 --longitude-min -77 --longitude-max -42.5 --latitude-min 36.5 --latitude-max 56.7 --date-min "2021-03-27 12:00:00" --date-max "2021-03-27 12:00:00" --depth-min 0.493 --depth-max 0.4942 --variable bottomT --variable mlotst --variable siconc --variable sithick --variable so --variable thetao --variable uo --variable usi --variable vo --variable vsi --variable zos --out-dir <OUTPUT_DIRECTORY> --out-name <OUTPUT_FILENAME> --user <USERNAME> --pwd <PASSWORD>
  if (FALSE){
    bb = c(-77, -42.5, 36.5, 56.7)
    dates = Sys.Date() + c(-2, -1)
    times = c("12:00:00", "12:00:00")
    depths = c(0.493, 0.4942)
    variables = c("bottomT", "mlotst", "siconc", "sithick",
                  "so", "thetao", "uo",
                  "usi", "vo", "vsi", "zos")
    out_dir = "."
    out_name = sprintf("copernicus_%s.nc",
                       format(Sys.Date(), "%Y-%m-%d"))
    username = NULL
    password = NULL
  }
  if (is.null(username)) username <- options("copernicus")[[1]][['username']]
  if (is.null(password)) password <- options("copernicus")[[1]][['password']]
  if (!inherits(dates, "Date")) dates <- as.Date(dates)
  dates <- format(dates, '%Y-%m-%d')
  dates <- paste(dates, times)
  variables <- paste(paste("--variable", variables), collapse = " ")
  r <- c(
    LON_MIN = bb[1],
    LON_MAX = bb[2],
    LAT_MIN = bb[3],
    LAT_MAX = bb[4],
    DATE_MIN = dates[1],
    DATE_MAX = dates[2],
    DEPTH_MIN = as.character(depths[1]),
    DEPTH_MAX = as.character(depths[2]),
    VARIABLES = variables,
    OUT_DIR = out_dir[1],
    OUT_NAME = out_name[1],
    USERNAME = username[1],
    PASSWORD = password[1])

  for (n in names(r)){
    flag <- paste0("$", n)
    template[['param']] <- gsub(flag, r[[n]], template[['param']], fixed = TRUE)
  }
  template
}


#' Fetch (download) copernicus data
#'
#' @export
#' @param x charcater, a two element script vector comprised of
#' \itemize{
#' \item{app the name of the application to call, either python or python3}
#' \item{param the parameter (argument) vector fully populated}
#' }
#' @return integer with 0 for success
download_copernicus <- function(x = populate_script()){
  system2(x[['app']], x[['param']])
}
