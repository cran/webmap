#' US Major Cities
#'
#' @description This dataset contains the locations of cities within the United States
#'   with populations of about 40,000 or greater, all state capitals, and the national capital.
#'
#' @format A data frame with columns:
#'   \describe{
#'     \item{`name`}{City name}
#'     \item{`capital`}{Capital status code indicates whether a city is a capital or not.
#'       A value of 0 indicates that the city is not a capital,
#'       while a value of 1 indicates that the city is a capital.
#'       If the city is a state capital, the value is 2.}
#'     \item{`lng`}{Longitude in decimal degrees.}
#'     \item{`lat`}{Latitude in decimal degrees.}
#'   }
#'
#' @source The census-designated place population as of January 30, 2024,
#'   as enumerated by the 2020 United States census.
#'
#' @keywords datasets
#'
#' @examples
#' str(us_cities)
"us_cities"
