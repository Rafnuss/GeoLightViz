#' @import shiny
server <- function(input, output, session) {
  # Initialize reactive values and configuration
  rv <- init_reactive_values(.twl, .stapath, .twl_calib, .pgz)
  list2env(rv, environment())

  # Get known positions
  known_positions <- get_known_positions(.stapath)

  # Initialize map-related reactives
  llp_param <- reactiveVal(1.0)
  map_data <- init_map_reactives(.g, .pgz, pgz, twl, stapath, input, thr_likelihood, llp_param)
  list2env(map_data, environment())

  # Initialize calibration modal module
  show_calibration <- modal_calibration_server(
    "calibration_modal",
    twl = twl,
    stapath = stapath,
    twl_calib = twl_calib,
    pgz = pgz,
    col = col,
    extent = extent,
    tag = .tag,
    llp_param = llp_param
  )

  # Setup navigation and return update_stapath function
  nav_helpers <- setup_navigation_observers(
    input,
    output,
    session,
    stapath,
    show_calibration
  )
  update_stapath <- nav_helpers$update_stapath

  # Render outputs
  render_plotly_output(
    input,
    output,
    twl,
    stapath,
    drawing,
    is_modifying,
    zoom_state,
    .light_trace
  )
  render_map_output(
    output,
    observe,
    has_map,
    map_data$extent,
    map_display,
    contour_display,
    stapath,
    known_positions,
    col,
    input
  )

  # Setup observers
  setup_drawing_observers(
    input,
    drawing,
    stapath,
    twl,
    map_likelihood_fx,
    update_stapath,
    session
  )
  setup_labeling_observers(input, is_modifying, twl, zoom_state, session)

  if (has_map) {
    setup_position_observers(input, stapath, is_edit, map_likelihood, session)
  }

  # Setup export handlers
  setup_export_handlers(output, twl, stapath, .tag)
}
