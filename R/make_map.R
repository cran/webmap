#' Create a web map using TNM services
#'
#' Create a [Leaflet](https://leafletjs.com/) map widget that includes base maps offered through
#' [The National Map](https://www.usgs.gov/programs/national-geospatial-program/national-map) (TNM)
#' cached [service endpoints](https://apps.nationalmap.gov/services).
#' Information about the content of these base maps can be found within the
#' [TNM Base Maps](https://apps.nationalmap.gov/help/3.0%20TNM%20Base%20Maps.htm) document.
#' TNM content is limited to the United States and territories.
#' The map widget can be rendered on HTML pages generated from R Markdown, Shiny, or other applications.
#'
#' @param maps 'character' vector.
#'   TNM base maps to include in the web map. Choices include
#'   "Topo", "Imagery", "Imagery Topo", "Hydrography", "Shaded Relief", and "Blank".
#'   See 'Details' section for a description of each base map.
#'   By default, all base maps are included.
#'   The one exception is the "Blank" map,
#'   which is only accessible using a Web Map Service (WMS),
#'   see `protocol` argument.
#' @param ...
#'   Arguments to be passed to the [`leaflet`][leaflet::leaflet] function.
#' @param protocol 'character' string.
#'   Standard protocol for serving pre-rendered georeferenced TNM map tiles.
#'   Select "WMTS" for the Web Map Tile Service (the default) and "WMS" for the Web Map Service.
#' @param hydro 'logical' flag.
#'   Whether to show or hide (the default) the "Hydrography" overlay base map.
#' @param collapse 'logical' flag.
#'   Whether the layers control should be rendered as an icon that expands when hovered over.
#'   Default is `FALSE`.
#'
#' @details Composite base maps include:
#'   * "Topo" a tile base map that combines the most current TNM data,
#'     and other public-domain data, into a multi-scale topographic reference map.
#'     Data includes boundaries, geographic names, transportation,
#'     contours, hydrography, land cover, shaded relief, and bathymetry.<br/>
#'     \if{latex}{\cr} ![](basemap-topo.png)
#'   * "Imagery" is a tile base map of orthoimagery in TNM.
#'     Orthoimagery data typically are high resolution aerial images that combine the
#'     visual attributes of an aerial photograph with the spatial accuracy and reliability of a planimetric map.
#'     USGS digital orthoimage resolution may vary from 6 inches to 1 meter.<br/>
#'     \if{latex}{\cr} ![](basemap-imagery.png)
#'   * "Imagery Topo" is a tile base map of orthoimagery in TNM as a backdrop,
#'     and a limited selection of topographic data
#'     (boundaries, names, transportation, contours, and hydrography).<br/>
#'     \if{latex}{\cr} ![](basemap-imagery-topo.png)
#'   * "Hydrography" is a overlay of cartographic representation of the
#'     [National Hydrography Dataset](https://www.usgs.gov/national-hydrography/national-hydrography-dataset) (NHD).
#'     The NHD is a comprehensive set of digital geospatial data that encodes information about naturally occurring
#'     and constructed bodies of surface water, paths through which water flows, related features such as
#'     stream gages and dams, and additional hydrologic information.<br/>
#'     \if{latex}{\cr} ![](basemap-hydrography.png)
#'   * "Shaded Relief" is a tile base map of terrain representation in the form of hillshades created from the
#'     [3D Elevation Program](https://www.usgs.gov/3d-elevation-program) (3DEP). 3DEP maintains a seamless dataset
#'     of best available raster elevation data, in the form of digital elevation models (DEMs) for the conterminous
#'     United States, Alaska, Hawaii, and Territorial Islands of the United States.<br/>
#'     \if{latex}{\cr} ![](basemap-shaded-relief.png)
#'   * "OSM" is the [OpenStreetMap](https://www.openstreetmap.org/about) tile base map.<br/>
#'     \if{latex}{\cr} ![](basemap-osm.png)
#'   * "Blank" consists of ocean tints to give the outline of land cover as an empty base map.<br/>
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
#' # Create map widget
#' map <- make_map()
#'
#' # Print map widget
#' map
#'
#' # Print map with markers
#' pts <- rbind(
#'   c(-112.049, 43.517),
#'   c(-122.171, 37.456),
#'   c( -77.367, 38.947),
#'   c(-149.803, 61.187),
#'   c( -80.248, 26.080)
#' )
#' leaflet::addMarkers(map,
#'   lng = pts[, 1],
#'   lat = pts[, 2]
#' )
#'
#' # Print map of satellite imagery with a rectangle in the vicinity of UCLA
#' make_map(
#'   maps = "Imagery",
#'   collapse = TRUE
#' ) |>
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
                     hydro = FALSE,
                     collapse = FALSE) {

  # check arguments
  protocol <- match.arg(protocol)
  checkmate::assert_flag(hydro)
  checkmate::assert_flag(collapse)

  # set baese maps
  basemaps <- c(
    "Topo" = "USGSTopo",
    "Imagery" = "USGSImageryOnly",
    "Imagery Topo" = "USGSImageryTopo",
    "Hydrography" = "USGSHydroCached",
    "Shaded Relief" = "USGSShadedReliefOnly",
    "OSM" = "OpenStreetMap",
    "Blank" = "USGSTNMBlank"
  )
  if (missing(maps)) {
    maps <- names(basemaps)
    if (protocol == "WMTS") {
      maps <- maps[maps != "Blank"]
    }
  }
  checkmate::assert_character(maps, any.missing = FALSE, min.len = 1)
  maps <- match.arg(maps, choices = names(basemaps), several.ok = TRUE)
  basemaps <- basemaps[maps]

  # subset TNM base maps
  tnm_basemaps <- basemaps[maps != "OSM"]

  # set attribution
  hyperlinks <- c(
    "USGS" = format(
      htmltools::tags$a(
        "USGS",
        href = "https://www.usgs.gov/laws/policies_notices.html",
        title = "Policies and Notices",
        target = "_blank"
      )
    ),
    "TNM" = format(
      htmltools::tags$a(
        "TNM",
        href = "https://www.usgs.gov/programs/national-geospatial-program/national-map",
        title = "The National Map",
        target = "_blank"
      )
    ),
    "OSM" = paste(
      "\U00A9",
      htmltools::tags$a(
        "OpenStreetMap",
        href = "https://www.openstreetmap.org/copyright",
        title = "Copyright and License",
        target = "_blank"
      )
    )
  )
  if (length(tnm_basemaps) == 0) {
    hyperlinks <- hyperlinks["OSM"]
  } else if (!"OSM" %in% maps) {
    hyperlinks <- hyperlinks[c("USGS", "TNM")]
  }
  attr <- paste(hyperlinks, collapse = " | ")

  # initialize tile options
  opt <- leaflet::tileOptions(minZoom = 3)

  # initialize map widget
  map <- leaflet::leaflet(...)

  # add OpenStreetMap layer
  if ("OSM" %in% maps) {
    map <- leaflet::addTiles(map,
      group = "OSM",
      attribution = attr,
      options = opt
    )
  }

  # set domain
  domain <- "https://basemap.nationalmap.gov"

  # set maximum zoom
  opt[["maxZoom"]] <- 16

  # add base map using web map tile service
  if (protocol == "WMTS") {
    url <- sprintf("%s/arcgis/rest/services/%s/MapServer/tile/{z}/{y}/{x}", domain, tnm_basemaps)
    for (i in seq_along(tnm_basemaps)) {
      map <- leaflet::addTiles(map,
        urlTemplate = url[i],
        attribution = attr,
        group = names(tnm_basemaps)[i],
        options = opt
      )
    }

  # add base map using web map service
  } else if (protocol == "WMS") {
    url <- sprintf("%s/arcgis/services/%s/MapServer/WmsServer?", domain, tnm_basemaps)
    opt[["format"]] <- "image/jpeg"
    opt[["version"]] <- "1.3.0"
    for (i in seq_along(tnm_basemaps)) {
      map <- leaflet::addWMSTiles(map,
        baseUrl = url[i],
        group = names(tnm_basemaps)[i],
        options = opt,
        attribution = attr,
        layers = "0"
      )
    }
  }

  # add layer control
  if (length(maps) > 1) {

    # set groups
    is <- maps == "Hydrography"
    overlay_groups <- maps[is]
    base_groups <- maps[!is]

    # add widget
    map <- leaflet::addLayersControl(map,
      position = "topright",
      baseGroups = base_groups,
      overlayGroups = overlay_groups,
      options = leaflet::layersControlOptions(collapsed = collapse)
    )

    # hide hydrography layer
    if (!hydro) {
      map <- leaflet::hideGroup(map, group = "Hydrography")
    }
  }

  # add scale bar
  map <- leaflet::addScaleBar(map, position = "bottomleft")

  # return map widget
  map
}
