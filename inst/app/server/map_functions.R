# Map-related reactive expressions and helper functions

# Initialize map-related reactive expressions
init_map_reactives <- function(.g, .pgz, twl, stapath, input, thr_likelihood) {
  if (is.null(.g) || is.null(.pgz)) {
    shinyjs::hide("map_container")
    return(list(has_map = FALSE))
  }

  # EPSG:3857 projection calculations
  lonInEPSG3857 <- (.g$lon * 20037508.34 / 180)
  latInEPSG3857 <- (log(tan((90 + .g$lat) * pi / 360)) / (pi / 180)) *
    (20037508.34 / 180)
  fac_res_proj <- 4
  res_proj <- c(
    stats::median(diff(lonInEPSG3857)),
    stats::median(abs(diff(latInEPSG3857))) / fac_res_proj
  )
  origin_proj <- c(stats::median(lonInEPSG3857), stats::median(latInEPSG3857))

  # Likelihood calculation helper
  twl_llp <- function(n) log(n) / n

  map_likelihood_fx <- function(twl_id) {
    if (sum(twl_id) > 1) {
      l <- exp(rowSums(
        twl_llp(sum(twl_id)) * log(.pgz[, twl_id] + .Machine$double.eps)
      ))
    } else if (sum(twl_id) == 1) {
      l <- .pgz[, twl_id]
    } else {
      l <- rep(1, .g$dim[1] * .g$dim[2])
    }
    m <- l / sum(l, na.rm = TRUE)

    # Find threshold of percentile
    ms <- sort(m)
    id_prob_percentile <- sum(cumsum(ms) < (1 - thr_likelihood))
    thr_prob <- ms[id_prob_percentile + 1]

    # Set to NA all values below this threshold
    m[m < thr_prob] <- NA

    matrix(m, nrow = .g$dim[1], ncol = .g$dim[2])
  }

  # Reactive: Calculate likelihood map
  map_likelihood <- reactive({
    twl_ <- twl()
    twl_id <- twl_$twilight > stapath()$start[as.numeric(input$stap_id)] &
      twl_$twilight < stapath()$end[as.numeric(input$stap_id)] &
      twl_$label != "discard"
    map_likelihood_fx(twl_id)
  })

  # Reactive: Project map for display
  map_display <- reactive({
    terra::project(
      terra::rast(
        simplify2array(map_likelihood()),
        extent = .g$extent,
        crs = "epsg:4326"
      ),
      "epsg:3857",
      method = "near",
      res = res_proj,
      origin = origin_proj
    )
  })

  # Reactive: Generate contour display
  contour_display <- reactive({
    map_likelihood_ <- map_likelihood()

    terra::rast(
      simplify2array(!is.na(map_likelihood_)),
      extent = .g$extent,
      crs = "epsg:4326"
    ) |>
      terra::disagg(fact = 10, method = "bilinear") |>
      terra::as.contour(levels = 0.5) |>
      sf::st_as_sf() |>
      sf::st_coordinates() |>
      as.data.frame() |>
      dplyr::rename(lng = X, lat = Y)
  })

  list(
    has_map = TRUE,
    map_likelihood_fx = map_likelihood_fx,
    map_likelihood = map_likelihood,
    map_display = map_display,
    contour_display = contour_display,
    extent = .g$extent
  )
}
