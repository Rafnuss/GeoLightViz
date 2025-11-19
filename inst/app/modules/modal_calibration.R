# Modal for twilight calibration display
modal_calibration_ui <- function(id) {
  ns <- NS(id)
  plotly::plotlyOutput(ns("calibration_plot"), width = "100%", height = "500px")
}

modal_calibration_server <- function(id, twl, stapath, twl_calib, col) {
  moduleServer(id, function(input, output, session) {
    show_calibration_modal <- function(idx) {
      twl_ <- twl()
      stapath_ <- stapath()

      # Check if position is set for calibration
      if (is.na(stapath_$lat[idx]) || is.na(stapath_$lon[idx])) {
        showModal(modalDialog(
          title = "No Position Set",
          "Please select a location on the map for this stationary period to compute the calibration.",
          easyClose = TRUE,
          footer = modalButton("Close")
        ))
        return()
      }

      # Filter twilight data for the selected stap
      twl_stap <- twl_ |>
        dplyr::filter(
          twilight > stapath_$start[idx],
          twilight < stapath_$end[idx],
          label != "discard"
        )
      twl_stap$stap_id <- idx

      if (nrow(twl_stap) == 0) {
        showModal(modalDialog(
          title = "No Data",
          "No valid twilight data found for this stationary period.",
          easyClose = TRUE,
          footer = modalButton("Close")
        ))
        return()
      }

      # Create stap_known for calibration
      stap_known <- stapath_[idx, ]
      stap_known$known_lat <- stap_known$lat
      stap_known$known_lon <- stap_known$lon

      # Compute calibration
      twl_calib_stap <- tryCatch(
        {
          GeoPressureR:::geolight_calibration(twl_stap, stap_known)
        },
        error = function(e) {
          return(NULL)
        }
      )

      if (is.null(twl_calib_stap)) {
        showModal(modalDialog(
          title = "Calibration Error",
          "Could not compute calibration for this stationary period.",
          easyClose = TRUE,
          footer = modalButton("Close")
        ))
        return()
      }

      # Prepare data for plotting
      twl_calib_orig <- twl_calib()
      x_lim_stap <- range(twl_calib_stap$x[
        twl_calib_stap$y > .001 * max(twl_calib_stap$y)
      ])

      if (!is.null(twl_calib_orig)) {
        x_lim_orig <- range(twl_calib_orig$x[
          twl_calib_orig$y > .001 * max(twl_calib_orig$y)
        ])
        x_lim <- range(c(x_lim_stap, x_lim_orig))
      } else {
        x_lim <- x_lim_stap
      }

      # Prepare line data for current stap calibration
      line_data_stap <- data.frame(
        x = twl_calib_stap$x,
        y = twl_calib_stap$y /
          max(twl_calib_stap$y) *
          max(twl_calib_stap$hist_count)
      )
      line_data_stap <- line_data_stap[
        line_data_stap$x >= x_lim[1] & line_data_stap$x <= x_lim[2],
      ]

      # Create plotly figure
      p <- plotly::plot_ly()

      # Add original calibration curve if available
      if (!is.null(twl_calib_orig)) {
        line_data_orig <- data.frame(
          x = twl_calib_orig$x,
          y = twl_calib_orig$y /
            max(twl_calib_orig$y) *
            max(twl_calib_stap$hist_count)
        )
        line_data_orig <- line_data_orig[
          line_data_orig$x >= x_lim[1] & line_data_orig$x <= x_lim[2],
        ]

        p <- p |>
          plotly::add_lines(
            data = line_data_orig,
            x = ~x,
            y = ~y,
            line = list(color = "#1f77b4", width = 4),
            name = "Calibration (original)",
            hovertemplate = "Solar zenith angle: %{x:.2f}<br>Density: %{y:.2f}<extra></extra>"
          )
      }

      # Add current stap data
      p <- p |>
        plotly::add_bars(
          x = twl_calib_stap$hist_mids,
          y = twl_calib_stap$hist_count,
          marker = list(
            color = "rgba(255, 127, 14, 0.5)",
            line = list(color = "rgba(255, 127, 14, 0.8)", width = 1)
          ),
          width = diff(twl_calib_stap$hist_mids)[1],
          name = "Twilight count (current stap)",
          hovertemplate = "Solar zenith angle: %{x:.2f}<br>Count: %{y}<extra></extra>"
        ) |>
        plotly::add_lines(
          data = line_data_stap,
          x = ~x,
          y = ~y,
          line = list(color = "#ff7f0e", width = 4),
          name = "Calibration (current stap)",
          hovertemplate = "Solar zenith angle: %{x:.2f}<br>Density: %{y:.2f}<extra></extra>"
        )

      p <- p |>
        plotly::layout(
          xaxis = list(
            title = "Solar zenith angle (°)",
            range = x_lim
          ),
          yaxis = list(
            title = "Count of twilights"
          ),
          showlegend = TRUE,
          legend = list(
            x = 0.02,
            y = 0.98,
            xanchor = "left",
            yanchor = "top",
            bgcolor = "rgba(255, 255, 255, 0.9)"
          ),
          plot_bgcolor = "white",
          paper_bgcolor = "white",
          margin = list(l = 60, r = 20, t = 40, b = 60),
          hovermode = "x unified"
        ) |>
        plotly::config(
          displaylogo = FALSE,
          modeBarButtonsToRemove = c(
            "select2d",
            "lasso2d",
            "zoomIn2d",
            "zoomOut2d"
          )
        )

      # Render the plot
      output$calibration_plot <- plotly::renderPlotly({
        p
      })

      # Show modal
      showModal(modalDialog(
        title = glue::glue(
          "Twilight Calibration - Stap #{idx} ({round(stapath_$duration[idx], 1)} days)"
        ),
        modal_calibration_ui(session$ns("")),
        size = "xl",
        easyClose = TRUE,
        footer = modalButton("Close")
      ))
    }

    return(show_calibration_modal)
  })
}
