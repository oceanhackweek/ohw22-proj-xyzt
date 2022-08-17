#' Read the example msfd dataset
#' 
#' @param path character string with path to dataset
#' @return a tibble with the dataset
read_msfd <- function(path = "data/msfd_2017_meta.csv") {
  readr::read_csv(path,
                  col_types = readr::cols(station_code_repl = readr::col_character(),
                                          date = readr::col_date(format = ""),
                                          lat = readr::col_double(),
                                          lon = readr::col_double(),
                                          depth_m = readr::col_double()))
}
