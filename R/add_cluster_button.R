#' Add cluster control button to a web map
#'
#' Add a button to a [Leaflet](https://leafletjs.com/) map to toggle marker clusters on and off.
#'
#' @inheritParams add_home_button
#' @param cluster_id 'character' string.
#'   Identification for the marker cluster layer.
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
#' make_map(maps = "Topo") |>
#'   leaflet::addMarkers(
#'     lng = ~lng,
#'     lat = ~lat,
#'     label = ~name,
#'     popup = ~name,
#'     clusterOptions = leaflet::markerClusterOptions(
#'       showCoverageOnHover = FALSE
#'     ),
#'     clusterId = "cluster",
#'     group = "marker",
#'     data = us_cities
#'   ) |>
#'   add_cluster_button(cluster_id = "cluster")

add_cluster_button <- function(map,
                               cluster_id,
                               position = "topleft") {

  # check arguments
  checkmate::assert_class(map, c("leaflet", "htmlwidget"))
  checkmate::assert_string(cluster_id, min.chars = 1)
  checkmate::assert_choice(position, c("topleft", "topright", "bottomleft", "bottomright"))

  # Javascript derived from https://rstudio.github.io/leaflet/morefeatures.html and accessed on 2017-11-06.

  # disable clusters
  js <- sprintf(
    "function(btn, map) {
      var clusterManager = map.layerManager.getLayer('cluster', '%s');
      clusterManager.disableClustering();
      btn.state('disable-cluster');
    }",
    cluster_id
  )
  s0 <- leaflet::easyButtonState(
    stateName = "enable-cluster",
    icon = "fa-circle",
    title = "Disable clustering",
    onClick = htmlwidgets::JS(js)
  )

  # enable clusters
  js <- sprintf(
    "function(btn, map) {
      var clusterManager = map.layerManager.getLayer('cluster', '%s');
      clusterManager.enableClustering();
      btn.state('enable-cluster');
    }",
    cluster_id
  )
  s1 <- leaflet::easyButtonState(
    stateName = "disable-cluster",
    icon = "fa-circle-o",
    title = "Enable clustering",
    onClick = htmlwidgets::JS(js)
  )

  # create button
  button <- leaflet::easyButton(
    position = position,
    states = list(s0, s1)
  )

  # place button on map
  leaflet::addEasyButton(map, button)
}
