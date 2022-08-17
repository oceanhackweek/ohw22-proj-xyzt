
#' Plot the points in the msfd
#' 
#' @param x path to the msfd dataset
#' @return a leaflet plot with the points in msfd
plot_msfd <- function(x = read_msfd()){
  
  points <- x |>
    as_POINT()
  
  leaflet(points) |>
    addTiles() |>
    addCircleMarkers()
}