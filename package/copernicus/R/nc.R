#' Retrieve dimension values by name
#'
#' @export
#' @param x ncdf4 object
#' @param what character, one of \code{time, latitude, longitude, depth, lon, lat}
#' @return vector of numeric or POSIXct time
get_dim <- function(x, what = c("time", "latitude", "longitude",
                                "depth", "lon", "lat")[1]){
  switch(tolower(what[1]),
         "lon" = get_lon(x),
         "longitude" = get_lon(x),
         "lat" = get_lat(x),
         "latitude" = get_lat(x),
         "depth" = get_depth(x),
         "time" =  get_time(x))
}

#' @export
#' @describeIn get_loc retrieve numeric longitudes
#' @return numeric longitude locations
get_lon <- function(x){
  stopifnot(inherits(x, "ncdf4"))
  x$dim$longitude$vals
}
#' @export
#' @describeIn get_loc retrieve numeric latitudes
#' @return numeric latitude locations
get_lat <- function(x){
  stopifnot(inherits(x, "ncdf4"))
  x$dim$latitude$vals
}
#' @export
#' @describeIn get_loc retrieve numeric depths
#' @return numeric depth locations
get_depth <- function(x){
  stopifnot(inherits(x, "ncdf4"))
  x$dim$depth$vals
}

#' Retrieve the time dimension values
#'
#' @export
#' @param x ncdf4 object
#' @return POSIXct vector
get_time <- function(x){
  origin <- as.POSIXct(x$dim$time$units,
                       format = "hours since %Y-%m-%d %H:%M:%S",
                       tz = 'UTC')
  origin + (3600 * x$dim$time$vals)
}


#' Retrieve information about a grads resource
#'
#' @export
#' @param x ncdf4 object
#' @param longnames logical, if TRUE then returve the longnames
#' @return character vector
get_varnames <- function(x, longnames = FALSE){
  stopifnot(inherits(x, "ncdf4"))
  vnames <- names(x$var)
  if (longnames){
    vnames <- sapply(vnames,
                     function(vname){
                       x$var[[vname]]$longname
                     })
  }
  vnames
}
#' @export
#' @describeIn get_varnames Retrieve the names of available dimensions
get_dimnames <- function(x, longnames = FALSE){
  stopifnot(inherits(x, "ncdf4"))
  dnames <- names(x$dim)
  if (longnames){
    dnames <- sapply(dnames,
                     function(dname){
                       x$dim[[dname]]$longname
                     })
  }
  dnames
}
#' @export
#' @describeIn get_varnames Retrieve the dimensions
#' @return named numeric vector of dimension lengths
get_dims <- function(x){
  stopifnot(inherits(x, "ncdf4"))
  dnames <- names(x$dim)
  sapply(dnames,
         function(dname){
           x$dim[[dname]]$len
         })
}

#' @export
#' @describeIn get_varnames Retrieve the dimensions
#' @return named list of character vectors of dimension names per variable
list_dims <- function(x){
  stopifnot(inherits(x, "ncdf4"))
  dids <- sapply(x$dim,
              function(x) x$id)
  dnames <- names(dids)
  vnames <- names(x$var)
  sapply(vnames,
         function(vname){
           dnames[x$var[[vname]]$dimids+1]
         })
}

#' Retrieve geospatial information about a grads resource
#'
#' @export
#' @param x ncdf4 object
#' @param what character, one of 'time', 'lon', 'lat', 'depth' or 'all'
#' @return varies by value of what
#' \itemize{
#'   \item{\code{lon, lat, depth} numeric vectors}
#'   \item{\code{time} POSIXct vector}
#'   \item{\code{all} list of \code{lon, lat, depth, time} vectors}
#' }
get_loc <- function(x, what = 'time'){
  switch(tolower(what[1]),
         "lon" = get_lon(x),
         "lat" = get_lat(x),
         "depth" = get_depth(x),
         'all' = sapply(c("lon", "lat", "depth", "time"),
                        function(w) get_loc(x, w), simplify = FALSE),
         get_time(x))
}



#' Get the native bounds for each dimension
#'
#' @export
#' @param x ncdf4 object
#' @param what character, one of 'time', 'lon', 'lat', 'depth' or 'all'
#' @return varies by value of what
#' \itemize{
#'   \item{\code{lon, lat, depth} numeric vectors}
#'   \item{\code{time} POSIXct vector}
#'   \item{\code{all} list of the above}
#'}
get_range <- function(x, what = 'lon'){
  switch(tolower(what[1]),
         "lon" = range(get_lon(x)),
         "lat" = range(get_lat(x)),
         "depth" = range(get_depth(x)),
         'all' = sapply(get_loc(x, 'all'), range, simplify = FALSE),
         range(get_time(x)))
}

#' Retrieve the native bounding box of the data
#'
#' @export
#' @param x ncdf4 object
#' @return 4 element vector of \code{[xmin, xmax, ymin, ymax]}
get_bounds <- function(x){
  unname(c(get_range(x, 'lon'), get_range(x, 'lat')))
}

#' Find the closest indices into a dimension for a given set of values
#'
#' This is useful to convert real dimensional values to array indices for making
#' data requests. The index assigned is always the dimensional step closest.
#'
#' @export
#' @param x ncdf4 object
#' @param value vector of one of values (numeric for lon, lat, depth and POSIXct for time)
#' @param what character, the name of the dimension
#' @param make_rle logical, if TRUE use the first and last elements of value (which
#'        may also be the first) to construct \code{[start, length]} encodings
#' @return numeric vector if either indices closest to requested locations or
#'        two element \code{[start, length]} vector if \code{rle = TRUE}
loc_index <- function(x, value, what = 'lon', make_rle = FALSE){
  loc <- as.numeric(get_loc(x, what))
  r <- sapply(as.numeric(value),
              function(v){
                which.min(abs(loc - v))
              }, simplify = TRUE)
  if (make_rle){
    len <- length(r)
    if (length(r) == 1){
      r <- c(r,1)
    } else {
      r <- c(r[1], r[length(r)] - r[1] + 1)
    }
  }
  r
}



#' Retrieve the dimension names for a variable
#'
#' @export
#' @param x ncdf4 object
#' @param var character, the name of the variable
#' @return character vector of variable names
get_vardims <- function(x, var = get_varnames(x)[1]){
  sapply(x$var[[var]]$dim, "[[", "name")
}

#' Retrieve an array of data from a ncdf object
#'
#' @export
#' @param x ncdf4 object
#' @param var variable id (name)
#' @param index named list of \code{[start,length]} vectors for each dimension
#' \itemize{
#' \item{lon}{such as c(1,913)}
#' \item{lat}{such as c(1,443)}
#' \item{time}{such as c(5, 7) which starts on the 5th and ends on the 12th}
#' \item{depth}{such as c(8,1) which retrieves just the 8th depth}
#' }
#' @param collapse_degen logical, if FALSE then preserve length 1 dimensions
#'  NAM218 grib files have variables with either \code{[lon, lat, time]} or
#'  \code{[lon, lat, depth, time]} dimensions. If the grib files stored those in
#'  \code{[lon, lat, time, depth]} order we could have dropped degenerate dimensions.
#' @return matrix or array
get_var_array <- function(x, var, index, collapse_degen = FALSE){
  vdims <- get_vardims(x, var)
  start <- sapply(vdims,
                  function(vname) index[[vname]][1])
  count <- sapply(vdims,
                  function(vname) index[[vname]][2])
  ncdf4::ncvar_get(x, varid = var,
                   start = start,
                   count = count,
                   collapse_degen = collapse_degen)
}


#' Retrieve a variable as array or stars object.
#'
#' Data are stored as \code{[lon, lat, time]} or \code{[lon, lat, depth, time]}
#' Degenerate indices (dimension = 1) are discarded, so if a single time is
#' requested for a \code{[lon, lat, time]} variable then a single band object is
#' returned.
#'
#' The requested bounding box coordinates are matched to the closest grid cell
#' centers, thus the output grids may differ in extent form the requested bounding
#' box.
#'
#' Requested times and depths are considered contiguous - we are extracting slabs
#' of data after all. Currently the first and last times or depths requested mark
#' the inclusive bounds of the slab in those dimensions. Requesting a single time or
#' depth works perfectly well.  If you need disjoint bands (not contiguous bands) then
#' you will need to make a separate request for each.
#'
#' @export
#' @param x ncdf4 object
#' @param var character, one or more names of the variables to retrieve
#' @param bb a 4 element bounding box for subsetting ordered as
#'        \code{[xmin, xmax, ymin, ymax]}
#' @param time POSIXct vector of one or more times to retrieve. These are matched the
#'        closest known times in the object. See \code{get_time}  Default
#'        is the first recorded time in the object.
#' @param depth numeric vector of one or more depths. These are matched the
#'        closest known depths in the object. See \code{get_depth} Default
#'        is the first depth in the object.  Ignored if \code{depth} is not
#'        a dimension of the variable.
#' @param banded logical, if TRUE then retrieve mutliple bands (time/depth). If
#'        FALSE then allow only one value for time and depth and degenrate dimensions
#' @param form character, either 'array' of 'stars' (default)
#' \itemize{
#'   \item{array}{an array or list of arrays, possibly degenerate to a matrix}
#'   \item{stars}{a stars object, possibly with band (time) and z (depth)}
#' }
get_var <- function(x,
                    var = get_varnames(x),
                    bb = get_bounds(x),
                    time = get_range(x, 'time'),
                    depth = get_range(x, "depth"),
                    banded = TRUE,
                    form = c("array", "stars")[2]){

  if(FALSE){
    var = "thetao" # get_varnames(x)
    bb = get_bounds(x)
    time = get_range(x, 'time')
    depth = get_range(x, "depth")
    banded = FALSE
    form = c("array", "stars")[2]
  }

  if (length(var) > 1){
    r <- sapply(var,
                function(v){
                  get_var(x, v, bb = bb, time = time, depth = depth,
                          banded = banded, form = form)
                }, simplify = FALSE)
    if (tolower(form[1]) == 'stars'){
      r <- Reduce(c, r) |>
        stats::setNames(var)
    }
    return(r)
  }

  stopifnot(var[1] %in% get_varnames(x))

  if (!banded) {
    depth <- depth[c(1,1)]
    time <- time[c(1,1)]
  }

  ilon <- loc_index(x, bb[1:2], "lon")
  ilat <- loc_index(x, bb[3:4], "lat")
  idepth <- loc_index(x, depth, "depth")
  itime <- loc_index(x, time, 'time')

  lons <- get_lon(x)
  lats <- get_lat(x)
  times <- get_time(x)
  depths <- get_depth(x)

  dx <- lons[2]-lons[1]
  dy <- lats[2]-lats[1]
  xlim <- lons[ilon] + c(-dx, dx)/2
  ylim <- lats[ilat] + c(-dy, dy)/2

  index <- list(
    longitude = loc_index(x, bb[1:2], "lon", make_rle = TRUE),
    latitude = loc_index(x, bb[3:4], "lat", make_rle = TRUE),
    time =  loc_index(x, time, "time", make_rle = TRUE),
    depth = loc_index(x, depth, "depth", make_rle = TRUE))

  m <- get_var_array(x, var[1], index, collapse_degen = !banded)

  if (tolower(form[1]) %in% c('array', "matrix")) return(m)

  stbb <- sf::st_bbox(c(xmin = xlim[1],
                        ymin = ylim[1],
                        xmax = xlim[2],
                        ymax = ylim[2]),
                      crs = 4326)
  d <- dim(m)
  #cat("var=", var[1], "\n")
  #print(d)
  time_index <- index$time[1] + (seq_len(index$time[2]) - 1)
  depth_index <- index$depth[1] + (seq_len(index$depth[2]) - 1)

  if (!banded){
    r <- stars::st_as_stars(stbb,
                            nx = d[1],
                            ny = d[2],
                            values = m) |>
         stars::st_flip(which = 2)
  } else if (length(d) == 4){
    # lon, lat, depth, time
    r <- lapply(seq_len(d[4]),
                function(i){
                  stars::st_as_stars(stbb,
                                     nx = d[1],
                                     ny = d[2],
                                     nz = d[3],
                                     values = m[,,,i]) |>
                    stars::st_flip(which = 2) |>
                    stars::st_set_dimensions(which = 3,
                                             names = 'depth',
                                             values = depths[depth_index])
                })
    if (length(r) > 1){
      r <- Reduce(c, r) |>
        merge(name = 'time') |>
        stars::st_set_dimensions(which = 4,
                                 names = 'time',
                                 values = times[time_index])
    } else {
      r <- r[[1]]
    }

  } else if (length(d) == 3) {
    # lon, lat, time
    r <- stars::st_as_stars(stbb,
                            nx = d[1],
                            ny = d[2],
                            nz = d[3],
                            values = m) |>
      stars::st_flip(which = 2)  |>
      stars::st_set_dimensions(which = 3,
                               values = times[time_index],
                               names = 'time')
  } else {
    # lon lat - we restore time so to speak
    r <- stars::st_as_stars(stbb,
                            nx = d[1],
                            ny = d[2],
                            nz = 1,
                            values = m) |>
      stars::st_flip(which = 2) |>
      stars::st_set_dimensions(which = 3,
                               values = times[time_index],
                               names = 'time')
  }
  stats::setNames(r, var)
}
