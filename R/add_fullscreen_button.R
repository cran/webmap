#' Add full-screen button to a web map
#'
#' Add a button to a [Leaflet](https://leafletjs.com/) map that toggles full screen on and off.
#' Functionality provided by the [leaflet-fullscreen](https://github.com/Leaflet/Leaflet.fullscreen)
#' plugin for Leaflet.
#'
#' @inheritParams add_home_button
#' @param pseudo_fullscreen 'logical' flag.
#'   Whether to fullscreen to page width and height.
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
#'   add_fullscreen_button()

add_fullscreen_button <- function(map,
                                  pseudo_fullscreen = FALSE,
                                  position = "topleft") {

  # check arguments
  checkmate::assert_class(map, c("leaflet", "htmlwidget"))
  checkmate::assert_choice(position, c("topleft", "topright", "bottomleft", "bottomright"))
  checkmate::assert_flag(pseudo_fullscreen)

  # attach html dependencies to map widget
  map$dependencies <- c(
    map$dependencies,
    list(
      htmltools::htmlDependency(
        name = "leaflet-fullscreen",
        version = "1.0.2",
        src = "htmlwidgets/plugins/leaflet-fullscreen",
        script = c("Leaflet.fullscreen.min.js"),
        stylesheet = "leaflet.fullscreen.css",
        package = "webmap"
      )
    )
  )

  # account for missing options
  if (is.null(map$x$options)) {
    map$x$options <- list()
  }

  # set control options
  map$x$options["fullscreenControl"] <- list(list(
    position = position,
    pseudoFullscreen = pseudo_fullscreen
  ))

  map
}
