# webmap 1.1.1

* Fixed Rd files with `link{}` targets missing a package anchor by removing link.

# webmap 1.1.0

* Add [OpenStreetMap](https://www.openstreetmap.org/about) (OSM) tiled base map.
* Update Leaflet Control Search plugin from `v3.0.9` to `v4.0.0`.
* Rename base map from "Imagery Only" to "Imagery".
* Toggle visibility of the "Hydrography" base map using an overlay option.
* Update fullscreen icon in leaflet-fullscreen plugin.

# webmap 1.0.7

* Remove vignette fields from DESCRIPTION file.

# webmap 1.0.6

* Remove suggested **sf** package dependency.
* Add `us_cities` dataset, locations of United States major cities.
* Remove caching beacause of installation issues with the **leaflet.extras** package.

# webmap 1.0.5

* Add .renvignore file.

# webmap 1.0.4

* Add `cache` argument to the `make_map` function, used to cache base-map tiles locally in your browser.
* Remove vignette from package.
* Fix image layout in the PDF version of the help documentation for the `make_map` function.
* Add `fig.width` and `fig.height` knitr chunk options in the package vignette.

# webmap 1.0.3

* In the DESCRIPTION file, write package names, software names, and API names in single quotes in
  the Title and Description fields. And remove the optional Copyright field.

# webmap 1.0.2

* Make package have only one license.
* Declare copyright holders as package authors.

# webmap 1.0.1

* Remove invalid USGS OWI-R hyperlink.
* Add Posit Connect package website URL to DESCRIPTION file.

# webmap 1.0.0

* Add package logo.
* Add [leaflet-fullscreen](https://github.com/Leaflet/Leaflet.fullscreen) (`v1.0.2`) plugin for Leaflet.
* Update Leaflet Control Search plugin from `v2.9.6` to `v3.0.9`.
* Refactor interactive web map functionality from the **inlmisc** package.
