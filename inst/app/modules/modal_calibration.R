# Modal for twilight calibration display
modal_calibration_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      class = "modal-calibration-container",
      h4("Twilight Calibration"),
      p("The likelihood maps are computed assuming that twilight errors follow the distribution shown by the blue line (active calibration). The orange bars show the twilight errors of the current stationary period, based on the location selected on the map."),
      plotly::plotlyOutput(ns("calibration_plot"), width = "100%", height = "450px"),
      p(
        "The calibration consists of fitting a kernel density to the twilight errors. You can control the smoothness of the fit using the ",
        tags$code("twl_calib_adjust"),
        " argument of ",
        tags$a(tags$code("geolight_map()"), href = "https://raphaelnussbaumer.com/GeoPressureR/reference/geolight_map.html#arg-twl-calib-adjust", target = "_blank"),
      ),
      fluidRow(
        column(
          6,
          div(
            class = "modal-input-group",
            tags$label("twl_calib_adjust:", title = "Adjustment parameter for density()"),
            numericInput(ns("twl_calib_adjust"), label = NULL, value = 1.2, step = 0.1, width = "70px")
          ),
        ),
        column(
          6,
          shiny::actionButton(
            ns("use_calibration"),
            "Use the proposed calibration",
            class = "btn-primary",
            icon = icon("check"),
            style = "width: 100%;"
          )
        )
      ),
      shiny::hr(),
      h4("Likelihood Aggregation"),
      p(
        "The second parameter controlling the likelihood map is how twilight likelihood maps are aggregated over stationary periods. Since twilight errors are typically correlated over time, we use a log-linear pooling function. See more information in the ",
        a("Probability Aggregation chapter of the GeoPressureManual", href = "https://raphaelnussbaumer.com/GeoPressureManual/probability-aggregation.html#log-linear-pooling-w-lognn", target = "_blank"),
        " and ", tags$a(tags$code("geolight_map()"), href = "https://raphaelnussbaumer.com/GeoPressureR/reference/geolight_map.html#arg-twl-llp", target = "_blank"), "."
      ),
      fluidRow(
        column(
          6,
          div(
            class = "modal-input-group",
            tags$label("Log-Linear Pooling factor: f(n) = 1 /"),
            numericInput(ns("llp_adjust"), label = NULL, value = 1.0, step = 0.1, width = "70px"),
            tags$label("log(n) / n")
          )
        ),
        column(
          6,
          actionButton(
            ns("update_likelihood"),
            "Update Likelihood Map",
            class = "btn-primary",
            icon = icon("refresh"),
            style = "width: 100%;"
          )
        )
      )
    )
  )
}

modal_calibration_server <- function(
  id,
  twl,
  stapath,
  twl_calib,
  pgz,
  col,
  extent,
  tag,
  llp_param
) {
  moduleServer(id, function(input, output, session) {
    selected_stap_idx <- reactiveVal(NULL)

    # Compute calibration based on selected stap and input adjustment
    current_calibration <- reactive({
      req(selected_stap_idx())
      # Get default values from current calibration or use defaults
      default_adjust <- if (!is.null(twl_calib()) && !is.null(twl_calib()$adjust)) twl_calib()$adjust else 1.2
      # Transform llp_param to display value (1/x) for default
      default_llp <- if (!is.null(llp_param())) {
        if (llp_param() != 0) 1 / llp_param() else 1.0
      } else {
        1.0
      }

      adjust <- if (is.null(input$twl_calib_adjust)) default_adjust else input$twl_calib_adjust
      # Note: llp_x is not actually used in this reactive, but keeping for consistency
      llp_x <- if (is.null(input$llp_adjust)) default_llp else input$llp_adjust

      idx <- selected_stap_idx()
      twl_ <- twl()
      stapath_ <- stapath()

      # Filter twilight data for the selected stap
      twl_stap <- twl_ |>
        dplyr::filter(
          twilight > stapath_$start[idx],
          twilight < stapath_$end[idx],
          label != "discard"
        )
      twl_stap$stap_id <- idx

      if (nrow(twl_stap) == 0) {
        return(NULL)
      }

      # Create stap_known for calibration
      stap_known <- stapath_[idx, ]
      stap_known$known_lat <- stap_known$lat
      stap_known$known_lon <- stap_known$lon

      # Compute calibration
      tryCatch(
        {
          GeoPressureR:::geolight_calibration(
            twl_stap,
            stap_known,
            twl_calib_adjust = adjust
          )
        },
        error = function(e) {
          return(NULL)
        }
      )
    })

    # Render the plot
    output$calibration_plot <- plotly::renderPlotly({
      twl_calib_stap <- current_calibration()
      validate(need(twl_calib_stap, "Could not compute calibration for this stationary period."))

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
            name = "Active Calibration",
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
          name = "Twilights Errors of current stap",
          hovertemplate = "Solar zenith angle: %{x:.2f}<br>Count: %{y}<extra></extra>"
        ) |>
        plotly::add_lines(
          data = line_data_stap,
          x = ~x,
          y = ~y,
          line = list(color = "#ff7f0e", width = 4),
          name = "Proposed Calibration",
          hovertemplate = "Solar zenith angle: %{x:.2f}<br>Density: %{y:.2f}<extra></extra>"
        )

      p |>
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
    })

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

      if (nrow(twl_stap) == 0) {
        showModal(modalDialog(
          title = "No Data",
          "No valid twilight data found for this stationary period.",
          easyClose = TRUE,
          footer = modalButton("Close")
        ))
        return()
      }

      selected_stap_idx(idx)

      # Show modal
      showModal(modalDialog(
        title = "Likelihood Map Settings",
        modal_calibration_ui(id),
        size = "xl",
        easyClose = TRUE,
        footer = NULL
      ))

      # Update inputs with current active values (must be after showModal)
      current_adjust <- if (!is.null(twl_calib()) && !is.null(twl_calib()$adjust)) twl_calib()$adjust else 1.2
      # Transform llp_param back to display value (1/x)
      current_llp <- if (!is.null(llp_param())) {
        if (llp_param() != 0) 1 / llp_param() else 1.0
      } else {
        1.0
      }

      updateNumericInput(session, "twl_calib_adjust", value = current_adjust)
      updateNumericInput(session, "llp_adjust", value = current_llp)
    }

    observeEvent(input$use_calibration, {
      req(current_calibration())

      # Disable button during processing
      shinyjs::disable("use_calibration")
      on.exit(shinyjs::enable("use_calibration"))

      # Update calibration
      twl_calib(current_calibration())

      # Recompute pgz
      tryCatch(
        {
          new_pgz <- GeoPressureR:::geolight_map_twilight(
            twl = tag$twilight,
            extent = extent,
            scale = tag$param$tag_set_map$scale,
            twl_calib = current_calibration()
          )
          pgz(new_pgz)
          showNotification("Calibration updated and map recomputed.", type = "message")
          removeModal() # Close modal on success
        },
        error = function(e) {
          showNotification(
            paste("Error recomputing map:", e$message),
            type = "error"
          )
        }
      )
    })

    observeEvent(input$update_likelihood, {
      # Disable button during processing
      shinyjs::disable("update_likelihood")
      on.exit(shinyjs::enable("update_likelihood"))

      # Update llp_param (transform input to 1/x)
      if (!is.null(input$llp_adjust) && input$llp_adjust != 0) {
        llp_param(1 / input$llp_adjust)
        showNotification("Likelihood map updated with new Log-Linear Pool factor.", type = "message")
        removeModal() # Close modal on success
      }
    })

    return(show_calibration_modal)
  })
}
