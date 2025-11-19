# Drawing and range editing observers

# Helper function to toggle drawing mode
create_draw_range_function <- function(drawing, session) {
  function(type) {
    # Toggle drawing state
    if (is.null(drawing())) {
      drawing(type)
    } else {
      drawing(NULL)
    }

    if (is.null(drawing())) {
      # Enable all buttons
      shinyjs::enable("label_twilight")
      shinyjs::enable("change_range")
      shinyjs::enable("add_stap")
      shinyjs::enable("remove_stap")
      shiny::updateActionButton(session, "change_range", icon = icon("pen"))
      shiny::updateActionButton(session, "add_stap", icon = icon("square-plus"))
    } else {
      # Disable certain buttons based on drawing type
      shinyjs::disable(c("label_twilight", "remove_stap"))
      if (type == "change_range") {
        shiny::updateActionButton(session, "change_range", icon = icon("ban"))
        shinyjs::disable("add_stap")
        shinyjs::disable("remove_stap")
      } else if (type == "add_stap") {
        shiny::updateActionButton(session, "add_stap", icon = icon("ban"))
        shinyjs::disable("change_range")
        shinyjs::disable("remove_stap")
      }
    }
  }
}

# Setup drawing-related observers
setup_drawing_observers <- function(
  input,
  drawing,
  stapath,
  twl,
  map_likelihood_fx,
  update_stapath,
  session
) {
  # Create draw_range function
  draw_range <- create_draw_range_function(drawing, session)

  # Add stap button
  observeEvent(input$add_stap, {
    draw_range("add_stap")
  })

  # Remove stap button
  observeEvent(input$remove_stap, {
    stapath_ <- stapath()
    if (nrow(stapath_) == 1) {
      shinyjs::alert("Only one stap left. You cannot remove it")
    } else {
      idx <- as.numeric(input$stap_id)
      stapath_ <- stapath_[-idx, ]
      stapath_$stap_id <- seq_len(nrow(stapath_))
      update_stapath(stapath_, selected = max(1, idx - 1))
    }
  })

  # Change range button
  observeEvent(input$change_range, {
    draw_range("change_range")
  })

  # Plotly relayout event (for drawing rectangles)
  observeEvent(plotly::event_data("plotly_relayout"), {
    drawing_ <- drawing()
    if (!is.null(drawing_)) {
      s <- plotly::event_data("plotly_relayout")$shape

      if (!is.null(s)) {
        r <- c(
          as.POSIXct(utils::tail(s$x0, 1), tz = "UTC"),
          as.POSIXct(utils::tail(s$x1, 1), tz = "UTC")
        )

        new_row <- data.frame(start = min(r), end = max(r))
        new_row$duration <- GeoPressureR::stap2duration(new_row)

        new_stapath <- stapath()
        new_row[, setdiff(names(new_stapath), names(new_row))] <- NA
        new_row <- new_row[, names(new_stapath)]

        idx <- as.numeric(input$stap_id)

        if (drawing_ == "change_range") {
          new_row$lat <- new_stapath$lat[idx]
          new_row$lon <- new_stapath$lon[idx]
          new_stapath[idx, ] <- new_row
          selected <- NULL
        } else if (drawing_ == "add_stap") {
          # If map present, start stap with most likely position
          if (!is.null(.g)) {
            twl_ <- twl()
            twl_id <- twl_$twilight > new_row$start &
              twl_$twilight < new_row$end &
              twl_$label != "discard"
            lk <- map_likelihood_fx(twl_id)

            max_idx <- which(lk == max(lk), arr.ind = TRUE)
            new_row$lat <- .g$lat[max_idx[1]]
            new_row$lon <- .g$lon[max_idx[2]]
          }
          new_stapath <- rbind(new_stapath, new_row)
          selected <- NULL
        }

        new_stapath <- new_stapath[order(new_stapath$start), ]
        new_stapath$stap_id <- seq_len(nrow(new_stapath))

        idx <- which(new_stapath$start == new_row$start)

        update_stapath(new_stapath, selected = idx)
      }
      draw_range("") # Deactivate drawing mode
    }
  })
}
