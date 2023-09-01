#' Add home button to a web map
#'
#' Add a button to a [Leaflet](https://leafletjs.com/) map that zooms to the provided map extent.
#'
#' @param map '[leaflet]'.
#'   Map widget object
#' @param position 'character' string.
#'   Position of the button on the web map.
#'   Possible values are `"topleft"`, `"topright"`, `"bottomleft"`, and `"bottomright"`.
#' @param extent 'bbox', or 'numeric' vector of length four, with `xmin`, `xmax`, `ymin` and `ymax` values.
#'   Extent object representing a rectangular geographical area on the map.
#'   The extent must be specified in the coordinate reference system (CRS) of the web map,
#'   usually in latitude and longitude using WGS 84 (also known as [EPSG:4326](https://epsg.io/4326)).
#'   By default, the extent will be automatically determined from
#'   latitudes and longitudes of the map elements.
#'
#' @return A new HTML web `map` with added element, an object of class 'leaflet'.
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @seealso [`make_map`] function for creating a map widget.
#'
#' @export
#'
#' @examples
#' make_map("Topo") |>
#'   add_home_button(
#'     extent = c(-124.409591, -114.131211, 32.534156, 42.009518) # California
#'   )

add_home_button <- function(map,
                            extent = NULL,
                            position = "topleft") {

  # check arguments
  checkmate::assert_class(map, c("leaflet", "htmlwidget"))
  checkmate::assert_choice(position, c("topleft", "topright", "bottomleft", "bottomright"))
  checkmate::assert_numeric(extent, len = 4, null.ok = TRUE)

  # extract/create extent object
  if (is.null(extent)) {
    if (is.null(map$x$limits)) {
      stop("Extent can not be determined from map elements", call. = FALSE)
    } else {
      extent <- c(map$x$limits$lng, map$x$limits$lat)
    }
  }

  # create button
  js <- sprintf(
    "function(btn, map) {
      map.fitBounds([[%f, %f],[%f, %f]]);
    }",
    extent[3], extent[1], extent[4], extent[2]
  )
  button <- leaflet::easyButton(
    icon = "fa-home fa-lg",
    title = "Zoom to initial map extent",
    onClick = htmlwidgets::JS(js),
    position = position
  )

  # place button on map
  leaflet::addEasyButton(map, button)
}
