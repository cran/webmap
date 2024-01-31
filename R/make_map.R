#' Create a web map using TNM services
#'
#' Create a [Leaflet](https://leafletjs.com/) map widget with base maps offered through
#' The National Map ([TNM](https://www.usgs.gov/programs/national-geospatial-program/national-map)).
#' Information about the content of these base maps can be found within the
#' [TNM Base Maps](https://apps.nationalmap.gov/help/3.0%20TNM%20Base%20Maps.htm) document.
#' The map widget can be rendered on HTML pages generated from R Markdown, Shiny, or other applications.
#'
#' @param maps 'character' vector.
#'   TNM base maps to include in the web map. Choices include
#'   `"Topo"`, `"Imagery Only"`, `"Imagery Topo"`, `"Hydrography"`, `"Shaded Relief"`, and `"Blank"`.
#'   See 'Details' section for a description of each base map.
#'   By default, all base maps are included.
#'   The one exception is the `"Blank"` map,
#'   which is only accessible using a Web Map Service (WMS),
#'   see `protocol` argument.
#' @param ...
#'   Arguments to be passed to the [`leaflet::leaflet`] function.
#' @param protocol 'character' string.
#'   Standard protocol for serving pre-rendered georeferenced TNM map tiles.
#'   Select `"WMTS"` for the Web Map Tile Service (the default) and `"WMS"` for the Web Map Service.
#' @param collapse 'logical' flag.
#'   Whether the layers control should be rendered as an icon that expands when hovered over.
#'   Default is `FALSE`.
#'
#' @details Map [service endpoints](https://apps.nationalmap.gov/services)
#'   are offered through TNM with no use restrictions.
#'   However, map content is limited to the United States and territories.
#'   This function integrates TNM endpoint services within an interactive web map using
#'   [Leaflet for R](https://rstudio.github.io/leaflet/).
#'
#'   TNM base maps include:
#'   * `Topo` combines the most current TNM data, and other public-domain data, into a multi-scale
#'     topographic reference map. Data includes boundaries, geographic names, transportation,
#'     contours, hydrography, land cover, shaded relief, and bathymetry.<br/>
#'     \if{latex}{\cr} ![](basemap-topo.png)
#'   * `Imagery Only` is the orthoimagery in TNM. Orthoimagery data typically are high resolution aerial images
#'     that combine the visual attributes of an aerial photograph with the spatial accuracy and reliability of a
#'     planimetric map. USGS digital orthoimage resolution may vary from 6 inches to 1 meter.<br/>
#'     \if{latex}{\cr} ![](basemap-imagery-only.png)
#'   * `Imagery Topo` is the orthoimagery in TNM as a backdrop, and a limited selection of topographic data
#'     (boundaries, names, transportation, contours, and hydrography).<br/>
#'     \if{latex}{\cr} ![](basemap-imagery-topo.png)
#'   * `Hydrography` is a cartographic representation of the
#'     [National Hydrography Dataset](https://www.usgs.gov/national-hydrography/national-hydrography-dataset) (NHD).
#'     The NHD is a comprehensive set of digital geospatial data that encodes information about naturally occurring
#'     and constructed bodies of surface water, paths through which water flows, related features such as
#'     stream gages and dams, and additional hydrologic information.<br/>
#'     \if{latex}{\cr} ![](basemap-hydrography.png)
#'   * `Shaded Relief` is a terrain representation in the form of hillshades created from the
#'     [3D Elevation Program](https://www.usgs.gov/3d-elevation-program) (3DEP). 3DEP maintains a seamless dataset
#'     of best available raster elevation data, in the form of digital elevation models (DEMs) for the conterminous
#'     United States, Alaska, Hawaii, and Territorial Islands of the United States.<br/>
#'     \if{latex}{\cr} ![](basemap-shaded-relief.png)
#'   * `Blank` consists of ocean tints to give the outline of land cover as an empty base map.<br/>
#'     \if{latex}{\cr} ![](basemap-blank.png)
#'
#' @return An object of class 'leaflet', a hypertext markup language (HTML) map widget.
#'   See example for instructions on how to add additional graphic layers
#'   (such as points, lines, and polygons) to the map widget.
#'   Graphic layers added to the web map must be in latitude and longitude using WGS 84
#'   (also known as [EPSG:4326](https://epsg.io/4326)).
#'
#' @author J.C. Fisher, U.S. Geological Survey, Idaho Water Science Center
#'
#' @export
#'
#' @examples
#' # define arbitrary coordinate locations in decimal degrees
#' pts <- rbind(
#'   c(-112.049, 43.517),
#'   c(-122.171, 37.456),
#'   c( -77.367, 38.947),
#'   c(-149.803, 61.187),
#'   c( -80.248, 26.080)
#' )
#'
#' # create map widget and add markers at coordinate locations
#' map <- make_map() |>
#'   leaflet::addMarkers(pts[, 1], pts[, 2])
#'
#' # print map widget
#' map
#'
#' # print map of satellite imagery with a rectangle in the vicinity of UCLA
#' make_map(c("Imagery Only", "Topo"), collapse = TRUE) |>
#'   leaflet::addRectangles(
#'     lng1 = -118.456,
#'     lat1 =   34.078,
#'     lng2 = -118.436,
#'     lat2 =   34.062,
#'     fillColor = "transparent"
#'   )

make_map <- function(maps,
                     ...,
                     protocol = c("WMTS", "WMS"),
                     collapse = FALSE) {

  # check arguments
  protocol <- match.arg(protocol)
  checkmate::assert_flag(collapse)

  # set baese maps
  basemaps <- c(
    "Topo" = "USGSTopo",
    "Imagery Only" = "USGSImageryOnly",
    "Imagery Topo" = "USGSImageryTopo",
    "Hydrography" = "USGSHydroCached",
    "Shaded Relief" = "USGSShadedReliefOnly",
    "Blank" = "USGSTNMBlank"
  )
  if (missing(maps)) {
    if (protocol == "WMTS") {
      basemaps <- basemaps[names(basemaps) != "Blank"]
    }
  } else {
    basemaps <- basemaps[match.arg(maps, names(basemaps), several.ok = TRUE)]
  }

  # set attribution
  attribution <- sprintf(
    "<a href='%s' title='%s' target='_blank'>%s</a> | <a href='%s' title='%s' target='_blank'>%s</a>",
    "https://www.usgs.gov/",
    "United States Geological Survey",
    "USGS",
    "https://www.usgs.gov/laws/policies_notices.html",
    "USGS policies and notices",
    "Policies"
  )

  # set domain
  domain <- "https://basemap.nationalmap.gov"

  # set tile options
  tile_options <- list(
    "minZoom" = 3,
    "maxZoom" = 16
  )

  # initialize map widget
  map <- leaflet::leaflet(...)

  # add base map using web map tile service
  if (protocol == "WMTS") {
    url <- sprintf("%s/arcgis/rest/services/%s/MapServer/tile/{z}/{y}/{x}", domain, basemaps)
    for (i in seq_along(basemaps)) {
      map <- leaflet::addTiles(map,
        urlTemplate = url[i],
        attribution = attribution,
        group = names(basemaps)[i],
        options = do.call(leaflet::tileOptions, tile_options)
      )
    }

  # add base map using web map service
  } else if (protocol == "WMS") {
    url <- sprintf("%s/arcgis/services/%s/MapServer/WmsServer?", domain, basemaps)
    tile_options[["format"]] <- "image/jpeg"
    tile_options[["version"]] <- "1.3.0"
    for (i in seq_along(basemaps)) {
      map <- leaflet::addWMSTiles(map,
        baseUrl = url[i],
        group = names(basemaps)[i],
        options = do.call(leaflet::WMSTileOptions, tile_options),
        attribution = attribution,
        layers = "0"
      )
    }
  }

  # add basemap control feature
  if (length(basemaps) > 1) {
    map <- leaflet::addLayersControl(map,
      position = "topright",
      baseGroups = names(basemaps),
      options = leaflet::layersControlOptions(collapsed = collapse)
    )
  }

  # add scale bar
  map <- leaflet::addScaleBar(map, position = "bottomleft")

  # return map widget
  map
}
