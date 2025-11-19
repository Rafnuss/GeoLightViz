list_of_packages <- c("shiny", "shinyjs")
new_packages <- list_of_packages[
  !(list_of_packages %in% installed.packages()[, "Package"])
]
if (length(new_packages) > 0) {
  install.packages(new_packages)
}

suppressMessages({
  library(GeoPressureR)
  library(shinyjs)
  library(shiny)
  library(GeoLightViz)
})

# Source module files
source("modules/utils.R", local = TRUE)
source("modules/modal_calibration.R", local = TRUE)
source("modules/map_module.R", local = TRUE)

# Source server files
source("server/reactive_values.R", local = TRUE)
source("server/map_functions.R", local = TRUE)
source("server/plotly_output.R", local = TRUE)
source("server/map_output.R", local = TRUE)
source("server/navigation_observers.R", local = TRUE)
source("server/drawing_observers.R", local = TRUE)
source("server/labeling_observers.R", local = TRUE)
source("server/position_observers.R", local = TRUE)
source("server/export_handlers.R", local = TRUE)

# Get data from shiny options instead of global variables
.tag <- shiny::getShinyOption("tag")
.twl <- shiny::getShinyOption("twl")
.light_trace <- shiny::getShinyOption("light_trace")
.twl_calib <- shiny::getShinyOption("twl_calib")
.pgz <- shiny::getShinyOption("pgz")
.stapath <- shiny::getShinyOption("stapath")
.g <- shiny::getShinyOption("g")


if (is.null(.tag) || is.null(.twl)) {
  cli::cli_abort(
    "Required data not found in shiny options. Please restart the app with correct options."
  )
}
