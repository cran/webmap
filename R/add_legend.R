#' Add legend to a web map
#'
#' Add a legend to a [Leaflet](https://leafletjs.com/) map.
#'
#' @inheritParams add_home_button
#' @param labels 'character' vector.
#'   Labels in the legend.
#' @param colors 'character' vector.
#'   HTML colors corresponding to `labels`.
#' @param radius 'numeric' number.
#'   Border radius of symbols in the legend, in pixels.
#' @param opacity 'numeric' number.
#'   Opacity of symbols in the legend, from 0 to 1.
#' @param symbol 'character' string.
#'   Symbol type in the legend, either `"square"` or `"circle"`.
#' @param title 'character' string.
#'   Legend title
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
#' # define marker colors based on whether a city serves as a capital
#' color <- c(
#'   "Non-capital" = "green",
#'   "Capital" = "red"
#' )
#'
#' # print web map with city circle markers and legend
#' make_map("Topo") |>
#'   leaflet::addCircleMarkers(
#'     radius = 6,
#'     color = "white",
#'     weight = 1,
#'     opacity = 1,
#'     fillColor = as.character(color[(city$capital > 0) + 1]),
#'     fillOpacity = 1,
#'     fill = TRUE,
#'     data = city
#'   ) |>
#'   add_legend(
#'     labels = names(color),
#'     colors = color,
#'     radius = 5,
#'     opacity = 1,
#'     symbol = "circle"
#'   )

add_legend <- function(map,
                       labels,
                       colors,
                       radius,
                       opacity = 0.5,
                       symbol = c("square", "circle"),
                       title = "EXPLANATION",
                       position = "topright") {

  # check arguments
  checkmate::assert_class(map, c("leaflet", "htmlwidget"))
  checkmate::assert_character(labels, any.missing = FALSE, min.len = 1)
  checkmate::assert_character(colors, any.missing = FALSE, len = length(labels))
  checkmate::assert_numeric(radius, lower = 0, any.missing = FALSE, min.len = 1)
  checkmate::assert_number(opacity, lower = 0, upper = 1, finite = TRUE)
  symbol <- match.arg(symbol)
  checkmate::assert_string(title, null.ok = TRUE)
  checkmate::assert_choice(position, c("topleft", "topright", "bottomleft", "bottomright"))

  sizes <- rep(radius, length.out = length(colors)) * 2

  col <- sprintf(
    switch(symbol,
      "square" = "%s; width:%fpx; height:%fpx; margin-top:4px;",
      "circle" = "%s; border-radius:50%%; width:%fpx; height:%fpx; margin-top:4px;"
    ), colors, sizes, sizes
  )

  lab <- sprintf(
    "<div style='display:inline-block; height:%fpx; line-height:%fpx; margin-top:4px;'>%s</div>",
    sizes, sizes, labels
  )
  if (is.character(title)) {
    title <- sprintf("<div style='text-align:center;'>%s</div>", title)
  }

  leaflet::addLegend(map,
    position = position,
    colors = col,
    labels = lab,
    labFormat = as.character(),
    opacity = opacity,
    title = title
  )
}
