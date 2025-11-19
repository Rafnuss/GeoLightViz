# Position editing observers (ML position finder and manual editing)

# Setup position editing observers
setup_position_observers <- function(
  input,
  stapath,
  is_edit,
  map_likelihood,
  session
) {
  # Find ML (Maximum Likelihood) position button
  observeEvent(input$ml_position, {
    lk <- map_likelihood()
    max_idx <- which(lk == max(lk, na.rm = TRUE), arr.ind = TRUE)

    new_stapath <- stapath()
    idx <- as.numeric(input$stap_id)

    new_stapath$lat[idx] <- .g$lat[max_idx[1]]
    new_stapath$lon[idx] <- .g$lon[max_idx[2]]
    stapath(new_stapath)
  })

  # Toggle manual position editing mode
  observeEvent(input$edit_position, {
    if (is_edit()) {
      is_edit(FALSE)
      shiny::updateActionButton(
        session,
        "edit_position",
        label = "Edit Position"
      )
      shinyjs::removeClass("edit_position", "primary")
    } else {
      is_edit(TRUE)
      shiny::updateActionButton(
        session,
        "edit_position",
        label = "Stop editing"
      )
      shinyjs::addClass("edit_position", "primary")
    }
  })

  # Handle map clicks for manual position editing
  observeEvent(input$map_click, {
    if (!is_edit()) {
      return()
    }
    click <- input$map_click
    if (is.null(click)) {
      return()
    }

    new_stapath <- stapath()
    idx <- as.numeric(input$stap_id)

    new_stapath$lat[idx] <- click$lat
    new_stapath$lon[idx] <- click$lng
    stapath(new_stapath)
  })
}
