ui <- function() {
  bootstrapPage(
    theme = bslib::bs_theme(version = 5),
    shinyjs::useShinyjs(),
    shiny::tags$head(
      shiny::tags$link(
        rel = "shortcut icon",
        href = "https://raphaelnussbaumer.com/GeoPressureR/favicon-16x16.png"
      ),
      shiny::tags$link(
        href = "https://fonts.googleapis.com/css?family=Oswald",
        rel = "stylesheet"
      ),
      shiny::tags$style(
        type = "text/css",
        "html, body {width:100%;height:100%; font-family: Oswald, sans-serif;}
      .primary{background-color:#007bff; color: #fff;}
      .selectize-input{border-radius:0; border-color:#404040;}
      .form-group{margin-bottom: 0;}"
      ),
      #  .js-plotly-plot .plotly .modebar{left: 0};
      # includeHTML("meta.html"),
    ),
    div(
      class = "container-fluid d-flex flex-column vh-100",
      fluidRow(
        class = "text-center bg-black align-items-center",
        column(
          2,
          tags$h2("GeoLightViz", style = "color:white;"), #
          # tags$a("About GeoPressureR", href = "https://raphaelnussbaumer.com/GeoPressureR/"),
          htmlOutput("tag_id")
        ),
        column(
          4,
          div(
            actionButton(
              "label_twilight",
              "Start labeling",
              class = "primary",
              icon = icon("pen")
            ),
            downloadButton(
              "export_twilight",
              "Export labeling",
              class = "primary"
            )
          )
        ),
        column(
          3,
          fluidRow(
            column(
              2,
              style = "padding:0px;",
              actionButton(
                "previous_position",
                "<",
                style = "width:100%; height:100%; padding:0; border-top-right-radius: 0;border-bottom-right-radius: 0;"
              )
            ),
            column(
              6,
              style = "padding:0px;",
              selectInput(
                "stap_id",
                label = NULL,
                choices = "1",
                width = "100%"
              )
            ),
            column(
              2,
              style = "padding:0px;",
              actionButton(
                "next_position",
                ">",
                style = "width:100%; height:100%; padding:0; border-top-left-radius: 0;border-bottom-left-radius: 0;"
              )
            ),
            column(
              2,
              style = "padding:0px;",
              actionButton(
                "show_twilight_histogram",
                "",
                icon = icon("chart-bar"),
                style = "width:100%; height:100%; padding:0;"
              )
            ),
          ),
        ),
        column(
          3,
          div(
            # tags$p("Stationary period", style = "font-weight:bold;"),
            actionButton("add_stap", "", icon = icon("square-plus")),
            actionButton("remove_stap", "", icon = icon("square-minus")),
            actionButton("change_range", "", icon = icon("pen")),
            downloadButton(
              "export_stap",
              "Export stap",
              class = "primary"
            )
          )
        )
      ),
      fluidRow(
        class = "d-flex flex-fill", # height = "100%",
        column(
          7,
          id = "plot_container",
          class = "d-flex flex-column flex-fill bg-black", # height = "100%",
          div(
            class = "d-flex flex-column flex-fill",
            height = "100%",
            plotly::plotlyOutput("plotly_div", width = "100%", height = "100%"),
          )
        ),
        column(
          5,
          id = "map_container",
          class = "flex-fill p-0",
          leaflet::leafletOutput("map", width = "100%", height = "100%"),
        ),
      ),
    )
  )
}
