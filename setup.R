# Use this for the development cycle to load all necessary packages

PATH <- "."

suppressPackageStartupMessages({
  required_cran <- c("dplyr", "readr", "stars", "sf", "devtools", "leaflet")
  required_github <- c("xyzt")
  installed <- installed.packages() |>
    dplyr::as_tibble() 
  needed_cran <- !(required_cran %in% installed$Package)
  needed_github <- !(required_github %in% installed$Package)
  if (any(needed_cran)){
    install.packages(required_cran[needed_cran])
  } else if (any(needed_github)){
    remotes::install_github(paste("BigelowLab", required[needed_github], sep="/"))
  }
  ok <- sapply(required_cran, library, character.only = TRUE)
  ok <- sapply(required_github, library, character.only = TRUE)
})

#' Source all of the functions found in `script`
#' @param path the path to the files by default assumes "[current_working_directory]/script"
#' @return invisible NULL
source_files <- function(path = file.path(PATH, "script")){
  ff <- list.files(path, pattern = glob2rx("*.R"), full.names = TRUE)
  for (f in ff) source(f)
  invisible(NULL)
}






