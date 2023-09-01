#' Add search button to a web map
#'
#' Add a button to a [Leaflet](https://leafletjs.com/) map to search markers/features location by property.
#' Functionality provided by the [leaflet-search](https://github.com/stefanocudini/leaflet-search)
#' plugin for Leaflet.
#'
#' @inheritParams add_home_button
#' @param group 'character' string.
#'   Name of the group whose features will be searched.
#' @param open_popup 'logical' flag.
#'   Whether to open the marker popup associated with the searched for marker.
#' @param property_name 'character' string.
#'   Property name used to describe markers, such as, `"label"` and `"popup"`.
#' @param text_placeholder 'character' string.
#'   Message to show in search element.
#' @param zoom 'integer' count.
#'   Zoom level for move to location after marker found in search.
#'
#' @inherit add_home_button return
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @seealso [`make_map`] function for creating a map widget.
#'
#' @export
#'
#' @examples
#' # read city point locations from GeoJSON file
#' city <- system.file("extdata/city.geojson", package = "webmap") |>
#'   sf::st_read()
#'
#' # create web map and add button to search city names
#' map <- make_map("Topo") |>
#'   leaflet::addMarkers(
#'     label = ~name,
#'     popup = ~name,
#'     group = "marker",
#'     data = city
#'   ) |>
#'   add_search_button(
#'     group = "marker",
#'     zoom = 15,
#'     text_placeholder = "Search city names..."
#'   )
#'
#' # print web map
#' map

add_search_button <- function(map,
                              group,
                              property_name = "label",
                              zoom = NULL,
                              text_placeholder = "Search...",
                              open_popup = FALSE,
                              position = "topleft") {

  # check arguments
  checkmate::assert_class(map, c("leaflet", "htmlwidget"))
  checkmate::assert_string(group, min.chars = 1)
  checkmate::assert_string(property_name, min.chars = 1)
  checkmate::assert_int(zoom, lower = 0, null.ok = TRUE)
  checkmate::assert_string(text_placeholder, null.ok = TRUE)
  checkmate::assert_flag(open_popup)
  checkmate::assert_choice(position, c("topleft", "topright", "bottomleft", "bottomright"))

  # check group is in map widget
  grp <- lapply(lapply(map$x$calls, function(x) x[[2]]), function(x) x[5][[1]]) |>
    unlist()
  if (!(group %in% grp)) {
    stop("Group with name '", group, "' missing from map widget.")
  }

  # attach html dependencies to map widget
  map$dependencies <- c(
    map$dependencies,
    list(
      htmltools::htmlDependency(
        name = "leaflet-search",
        version = "2.9.6",
        src = "htmlwidgets/plugins/leaflet-search",
        script = c("leaflet-search.min.js", "leaflet-search-binding.js"),
        stylesheet = "leaflet-search.min.css",
        package = "webmap"
      )
    )
  )

  # define arguments to be passed to the javascript method
  marker <- list(
    "icon" = FALSE,
    "animate" = TRUE,
    "circle" = list(
      "radius" = 20,
      "weight" = 3,
      "opacity" = 0.7,
      "color" = "#FF4040",
      "stroke" = TRUE,
      "fill" = FALSE
    )
  )
  option <- list(
    "propertyName" = property_name,
    "zoom" = zoom,
    "textPlaceholder" = text_placeholder,
    "openPopup" = open_popup,
    "position" = position,
    "initial" = FALSE,
    "hideMarkerOnCollapse" = TRUE,
    "marker" = marker
  )

  # add leaflet-search element to map
  leaflet::invokeMethod(map,
    data = leaflet::getMapData(map),
    method = "addSearchControl",
    group,
    leaflet::filterNULL(option)
  )
}
