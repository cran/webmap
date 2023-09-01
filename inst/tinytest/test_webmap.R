# setup tinytest for checkmate functionality
library("tinytest")
library("checkmate")
using("checkmate")

# test access to TNM web map tile service
map <- make_map(protocol = "WMTS")
checkmate::expect_class(map, classes = c("leaflet", "htmlwidget"))

# test access to TNM web map services
map <- make_map(protocol = "WMS")
checkmate::expect_class(map, classes = c("leaflet", "htmlwidget"))
