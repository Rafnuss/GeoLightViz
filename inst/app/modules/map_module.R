# Map module for displaying likelihood and positions
map_module_server <- function(
  id,
  stapath,
  known_positions,
  col,
  has_map,
  map_display,
  contour_display
) {
  moduleServer(id, function(input, output, session) {
    output$map <- leaflet::renderLeaflet({
      if (!has_map) {
        return(NULL)
      }

      map <- leaflet::leaflet() |>
        leaflet::addMapPane("raster_pane", zIndex = 210) |>
        leaflet::addProviderTiles(
          "CartoDB.DarkMatterNoLabels",
          group = "Dark Matter"
        ) |>
        leaflet::addProviderTiles("Esri.WorldImagery", group = "Satellite") |>
        leaflet::addProviderTiles("Esri.WorldTopoMap", group = "Topography") |>
        leaflet::addLayersControl(
          baseGroups = c("Dark Matter", "Satellite", "Topography"),
          position = c("topleft")
        ) |>
        leaflet::fitBounds(
          .g$extent[1],
          .g$extent[3],
          .g$extent[2],
          .g$extent[4]
        ) |>
        leaflet::addControl(
          div(
            style = "background-color: white; padding: 6px 8px; border-radius: 5px;",
            div(
              style = "margin-bottom: 8px;",
              radioButtons(
                "map_style",
                NULL,
                choices = c("Raster" = "raster", "Contour" = "contour"),
                selected = "raster",
                inline = TRUE
              )
            ),
            actionButton(
              "ml_position",
              "Find ML Position",
              class = "btn-sm",
              onclick = "event.stopPropagation();"
            ),
            actionButton(
              "edit_position",
              "Edit Position",
              class = "btn-sm",
              onclick = "event.stopPropagation();"
            )
          ),
          position = "topright",
          className = "legend"
        )

      return(map)
    })

    # Observer for updating map
    observe({
      if (!has_map) {
        return()
      }

      req(input$map_style)
      proxy <- leaflet::leafletProxy("map") |>
        leaflet::clearShapes() |>
        leaflet::clearImages() |>
        leaflet::clearMarkers()

      if (input$map_style == "raster") {
        proxy <- proxy |>
          leaflet::addRasterImage(
            map_display(),
            opacity = 0.8,
            colors = leaflet::colorNumeric(
              palette = "magma",
              domain = NULL,
              na.color = "#00000000",
              alpha = TRUE
            ),
            project = FALSE,
            options = leaflet::pathOptions(pane = "raster_pane")
          )
      } else {
        contour_display_ <- contour_display()
        proxy <- proxy |>
          leaflet::addPolylines(
            lng = contour_display_$lng,
            lat = contour_display_$lat,
            color = col[as.numeric(input$stap_id)],
            fill = FALSE,
            weight = 3
          )
      }

      # Add known positions if they exist
      if (!is.null(known_positions) && nrow(known_positions) > 0) {
        proxy <- proxy |>
          leaflet::addCircleMarkers(
            lng = known_positions$known_lon,
            lat = known_positions$known_lat,
            fillOpacity = 1,
            radius = 10,
            weight = 2,
            color = "#000",
            label = as.character(glue::glue(
              "#{known_positions$stap_id} (known), {round(known_positions$duration, 1)} days"
            )),
            fillColor = "red"
          )
      }

      stapath_ <- stapath() |>
        dplyr::filter(!is.na(lon), !is.na(lat))

      if (nrow(stapath_) > 0) {
        proxy <- proxy |>
          leaflet::addPolylines(
            lng = stapath_$lon,
            lat = stapath_$lat,
            opacity = 1,
            color = "#FFF",
            weight = 3
          ) |>
          leaflet::addCircleMarkers(
            lng = stapath_$lon,
            lat = stapath_$lat,
            fillOpacity = 1,
            radius = stapath_$duration^(0.3) * 6,
            weight = 1,
            color = "#FFF",
            label = as.character(glue::glue(
              "#{stapath_$stap_id}, {round(stapath_$duration, 1)} days"
            )),
            fillColor = col[seq_len(nrow(stapath_))]
          )
      }
    })

    return(list(
      map_click = reactive(input$map_click),
      map_style = reactive(input$map_style),
      ml_position = reactive(input$ml_position),
      edit_position = reactive(input$edit_position)
    ))
  })
}
