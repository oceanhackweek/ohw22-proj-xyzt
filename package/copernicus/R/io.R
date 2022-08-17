#' Unpack a copernicus ncdf4 file
#'
#' @export
#' @param filename character, the full path specification
#' @param banded logical, see \code{\link{get_var}}.  Setting to FALSE
#'        returns single band objects (depth and time dropped)
#' @return list of \code{stars} objects
unpack_copernicus <- function(filename, banded = FALSE){
  x <- ncdf4::nc_open(filename[1])
  ss <- sapply(get_varnames(x),
               function(vname){
                 get_var(x, var = vname, banded = banded)
               },
               simplify = FALSE)
  ncdf4::nc_close(x)
  ss
}


#' Fetch Copernicus data as a list of \code{stars} objects
#'
#' This is a wrapper around \code{\link{download_copernicus}} that
#' hides the details and returns a list of \code{stars} objects.  The downloaded
#' file is deleted.
#'
#' @export
#' @param script character, the name of the script to use
#' @param date Date class or castable as Date
#' @param out_path character, the temporary path to store the downloaded file
#' @param cleanup logical, if TRUE clean up files
#' @param ... further arguments for \code{\link{populate_script}}
#' @return named list of stars objects (organized by variable)
fetch_copernicus <- function(script = "global-analysis-forecast-phy-001-024",
                             date = Sys.Date(),
                             out_path = tempfile(pattern= 'copernicus',
                                                 tmpdir = "/dev/shm",
                                                 fileext = ".nc"),
                             cleanup = TRUE,
                             ...){

  ok <- read_script(name = script) |>
    populate_script(dates = date,
                    out_dir = dirname(out_path[1]),
                    out_name = basename(out_path[1]),
                    ...) |>
    download_copernicus()

  if (ok != 0){
    warning("unable to download copernicus data to", out_path[1])
    return(NULL)
  }
  ss <- unpack_copernicus(out_path[1])
  if (cleanup){
    ok <- file.remove(out_path)
    if (!ok) warning("unable to remove file:", out_path[1])
  }
  ss
}
