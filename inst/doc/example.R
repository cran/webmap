## -----------------------------------------------------------------------------
map <- webmap::make_map(collapse = FALSE) |>
  leaflet::setView(lng = -98.583, lat = 39.833, zoom = 3)
map

## -----------------------------------------------------------------------------
city <- system.file("extdata/city.geojson", package = "webmap") |>
  sf::st_read(quiet = TRUE)
city

## -----------------------------------------------------------------------------
map <- webmap::make_map("Topo") |>
  leaflet::addMarkers(
    label = ~name,
    popup = ~name,
    clusterOptions = leaflet::markerClusterOptions(
      showCoverageOnHover = FALSE
    ),
    clusterId = "cluster",
    group = "marker",
    data = city
  )
map

## -----------------------------------------------------------------------------
map <- map |>
  webmap::add_fullscreen_button(pseudo_fullscreen = TRUE) |>
  webmap::add_home_button() |>
  webmap::add_cluster_button(cluster_id = "cluster") |>
  webmap::add_search_button(
    group = "marker",
    zoom = 15,
    text_placeholder = "Search city names..."
  )
map

