# Initialize reactive values and configuration parameters

init_reactive_values <- function(.twl, .stapath, .twl_calib) {
  list(
    # Configuration parameters
    thr_likelihood = 0.95, # Threshold for likelihood map display

    # Color palette for stationary periods
    col = rep(RColorBrewer::brewer.pal(8, "Dark2"), times = 20),

    # Toggle states for buttons
    drawing = reactiveVal(NULL),
    is_modifying = reactiveVal(FALSE),
    is_edit = reactiveVal(FALSE),
    zoom_state = reactiveVal(NULL),
    map_style = reactiveVal("raster"),

    # Data reactive values
    twl = reactiveVal(.twl),
    stapath = reactiveVal(.stapath),
    twl_calib = reactiveVal(.twl_calib)
  )
}

# Extract known positions from stapath
get_known_positions <- function(.stapath) {
  if ("known_lat" %in% names(.stapath) && "known_lon" %in% names(.stapath)) {
    .stapath |>
      dplyr::filter(!is.na(known_lat), !is.na(known_lon)) |>
      dplyr::select(stap_id, known_lat, known_lon, duration)
  } else {
    NULL
  }
}
