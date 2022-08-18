#' Read the example msfd dataset
#' 
#' Set your working directory to the top level of the project
#' > source("setup.R")
#' > x <- read_msfd()
#' > x
#' # A tibble: 171 × 5
#'    station_code_repl date         lat   lon depth
#'    <chr>             <date>     <dbl> <dbl> <dbl>
#'  1 ZB1_1             2017-10-21  43.7  28.6  35  
#'  2 ZB1_2             2017-10-21  43.7  28.6  35  
#'  3 ZB3_1             2017-10-21  43.7  28.9  56  
#'  4 ZB3_2             2017-10-21  43.7  28.9  56  
#'  5 ZB5_1             2017-10-20  43.7  29.3  66  
#'  6 ZB5_2             2017-10-20  43.7  29.3  66  
#'  7 ZB11_1            2017-10-21  43.6  28.6  26.5
#'  8 ZB11_2            2017-10-21  43.6  28.6  26.5
#'  9 ZB14_1            2017-10-20  43.6  29.0  63  
#' 10 ZB14_2            2017-10-20  43.6  29.0  63  
#' # … with 161 more rows
#' # ℹ Use `print(n = ...)` to see more rows
#'
#' @param path character string with path to dataset
#' @return a tibble with the dataset
read_msfd <- function(path = file.path(PATH, "data", "msfd_2017_meta.csv")) {
  readr::read_csv(path,
                  col_types = readr::cols(station_code_repl = readr::col_character(),
                                          date = readr::col_date(format = ""),
                                          lat = readr::col_double(),
                                          lon = readr::col_double(),
                                          depth_m = readr::col_double())) |>
    dplyr::rename(depth = depth_m)
}
