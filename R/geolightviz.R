#' Start the GeoLightViz shiny app
#'
#' @param x a GeoPressureR `tag` object, a `.Rdata` file or the
#' unique identifier `id` with a `.Rdata` file located in `"./data/interim/{id}.RData"`.
#' @param path a GeoPressureR `path` or `pressurepath` data.frame.
#' @param launch_browser If true (by default), the app runs in your browser, otherwise it runs on
#' Rstudio.
#' @param run_bg If true (by default), the app runs in a background R process using `callr::r_bg()`,
#' allowing you to continue using the R console. If false, the app blocks the console until closed.
#'
#' @export
geolightviz <- function(x, path = NULL, launch_browser = TRUE, run_bg = TRUE) {
  if (!inherits(x, "tag")) {
    if (is.character(x) && file.exists(x)) {
      file <- x
    } else if (is.character(x)) {
      file <- glue::glue("./data/interim/{x}.RData")
    } else {
      file <- NULL
    }

    if (is.character(file) && file.exists(file)) {
      # Make of copy of the argument so that they don't get overwritten
      if (!is.null(path)) {
        path0 <- path
      }
      # Avoid CMD error
      path_most_likely <- NULL
      pressurepath <- NULL
      pressurepath_most_likely <- NULL
      # Load interim data
      load(file)
      # Accept path_most_likely instead of path
      if (!is.null(path_most_likely)) {
        path <- path_most_likely
      }
      # Use pressurepath if available over path_most_likely
      if (!is.null(pressurepath_most_likely)) {
        pressurepath <- pressurepath_most_likely
      }
      if (!is.null(pressurepath)) {
        if ("pressure_era5" %in% names(pressurepath)) {
          cli::cli_warn(c(
            "!" = "{.var pressurepath} has been create with an old version of \\
      {.pkg GeoPressureR} (<v3.2.0)",
            ">" = "For optimal performance, we suggest to re-run \\
      {.fun pressurepath_create}"
          ))
          pressurepath$surface_pressure <- pressurepath$pressure_era5
          pressurepath$surface_pressure_norm <- pressurepath$pressure_era5_norm
        }
        path <- pressurepath
      }
      # Overwrite loaded variable with arguments if provided
      if (exists("path0")) {
        path <- path0
      }
    } else {
      cli::cli_abort(
        "The first argument {.var x} needs to be a {.cls tag}, a {.field file} or \\
                     an {.field id}"
      )
    }
  } else {
    tag <- x
  }

  GeoPressureR::tag_assert(tag, "light")

  # If twilight has not been computed we need to be able to display it
  if (!("twilight" %in% names(tag))) {
    tag <- GeoPressureR::twilight_create(tag)
  }

  light_trace <- light_matrix(tag)
  twl <- prepare_twilight(tag, ref = light_trace$time[1])

  if ("stap" %in% names(tag)) {
    stapath <- tag$stap
    if (!("stap_id" %in% names(stapath))) {
      stapath$stap_id <- seq_len(nrow(stapath))
    }
    # Use negative indexing
    stapath$stap_id[stapath$stap_id < 0] <-
      nrow(stapath) - 1 - stapath$stap_id[stapath$stap_id < 0]
    if (!("lat" %in% names(stapath))) {
      stapath$lat <- NA_real_
    }
    if (!("lon" %in% names(stapath))) {
      stapath$lon <- NA_real_
    }
    if ("known_lat" %in% names(stapath)) {
      stapath$lat[!is.na(stapath$known_lat)] <- stapath$known_lat[
        !is.na(stapath$known_lat)
      ]
    }
    if ("known_lon" %in% names(stapath)) {
      stapath$lon[!is.na(stapath$known_lon)] <- stapath$known_lon[
        !is.na(stapath$known_lon)
      ]
    }
    if ("start" %in% names(stapath)) {
      stapath$start <- as.POSIXct(stapath$start, tz = "UTC")
    }
    if ("end" %in% names(stapath)) {
      stapath$end <- as.POSIXct(stapath$end, tz = "UTC")
    }
  } else {
    stapath <- data.frame(
      stap_id = integer(),
      start = as.POSIXct(character()),
      end = as.POSIXct(character()),
      lat = numeric(),
      lon = numeric()
    )
  }
  assertthat::assert_that(all(
    c("stap_id", "start", "end", "lat", "lon") %in% names(stapath)
  ))
  stapath$duration <- GeoPressureR::stap2duration(stapath)

  # Compute Calibration
  if ("known_lat" %in% names(stapath)) {
    if (!("stap_id" %in% names(tag$twilight))) {
      tag$twilight$stap_id <- GeoPressureR:::find_stap(
        stapath,
        tag$twilight$twilight
      )
    }
    twl_calib <- GeoPressureR:::geolight_calibration(
      twl = tag$twilight,
      stap_known = stapath
    )
  } else {
    twl_calib <- NULL
  }

  if (("tag_set_map" %in% names(tag$param)) && !is.null(twl_calib)) {
    extent <- tag$param$tag_set_map$extent

    if (
      any(
        !(stapath$known_lon >= extent[1] &
          stapath$known_lon <= extent[2] &
          stapath$known_lat >= extent[3] &
          stapath$known_lat <= extent[4]),
        na.rm = TRUE
      )
    ) {
      cli::cli_abort(c(
        x = "The known latitude and longitude are not inside the extent of the map",
        i = "Modify {.var extent} or {.var known} to match this requirement."
      ))
    }

    pgz <- GeoPressureR:::geolight_map_twilight(
      twl = tag$twilight,
      extent = extent,
      scale = tag$param$tag_set_map$scale,
      twl_calib = twl_calib
    )
  } else {
    pgz <- NULL
  }

  g <- if ("tag_set_map" %in% names(tag$param)) {
    GeoPressureR::map_expand(
      tag$param$tag_set_map$extent,
      tag$param$tag_set_map$scale
    )
  } else {
    NULL
  }

  if (run_bg) {
    p <- callr::r_bg(
      func = function(tag, twl, light_trace, twl_calib, pgz, stapath, g) {
        # Set shiny options instead of global variables
        shiny::shinyOptions(
          tag = tag,
          twl = twl,
          light_trace = light_trace,
          twl_calib = twl_calib,
          pgz = pgz,
          stapath = stapath,
          g = g
        )
        shiny::runApp(
          system.file("app", package = "GeoLightViz"),
          launch.browser = TRUE
        )
      },
      args = list(
        tag = tag,
        twl = twl,
        light_trace = light_trace,
        twl_calib = twl_calib,
        pgz = pgz,
        stapath = stapath,
        g = g
      )
    )
    port <- NA
    while (p$is_alive()) {
      p$poll_io(1000) # wait up to 1s for new output
      err <- p$read_error()
      out <- p$read_output()
      txt <- paste(err, out, sep = "\n")

      if (grepl("Listening on http://127\\.0\\.0\\.1:[0-9]+", txt)) {
        port <- sub(".*127\\.0\\.0\\.1:([0-9]+).*", "\\1", txt)
        url <- glue::glue("http://127.0.0.1:{port}")
        cli::cli_alert_success("Opening GeoLightViz app at {.url {url}}")
        utils::browseURL(url)
        break
      }
      # Silently wait - no printing of intermediate output
    }
    return(invisible(p))
  } else {
    # Set shiny options instead of global variables
    shiny::shinyOptions(
      tag = tag,
      twl = twl,
      light_trace = light_trace,
      twl_calib = twl_calib,
      pgz = pgz,
      stapath = stapath,
      g = g
    )

    if (launch_browser) {
      launch_browser <- getOption("browser")
    } else {
      launch_browser <- getOption("shiny.launch.browser", interactive())
    }

    # Start the app
    shiny::runApp(
      system.file("app", package = "GeoLightViz"),
      launch.browser = TRUE
    )
  }
}


light_matrix <- function(tag) {
  GeoPressureR::tag_assert(tag, "twilight")

  ## Same as geolight_map()
  light <- tag$light

  # Transform light value for better display
  light$value <- GeoPressureR:::twilight_create_transform(light$value)

  # Use by order of priority: (1) tag$param$twilight_create$twl_offset or (2) guess from light data
  if ("twl_offset" %in% names(tag$param$twilight_create)) {
    twl_offset <- tag$param$twilight_create$twl_offset
  } else {
    twl_offset <- GeoPressureR:::twilight_create_guess_offset(light)
  }

  # Compute the matrix representation of light
  mat <- GeoPressureR::ts2mat(light, twl_offset = twl_offset)

  mat$plottime <- time2plottime(mat$time)

  # Export for plotly object
  mat
}

#' @noRd
prepare_twilight <- function(tag, ref) {
  GeoPressureR::tag_assert(tag, "twilight")
  twl <- tag$twilight
  # twl$date <- as.Date(twl$twilight)
  twl$plottime <- time2plottime(twl$twilight, ref = ref)

  if (!("label" %in% names(twl))) {
    twl$label <- ""
  }

  # twl$id <- seq(1, nrow(twl))
  twl
}

# Modify the time to be compatible with figure
datetime2floathour <- \(x) {
  if (!is.character(x)) {
    x <- format(x, "%H:%M")
  }
  as.numeric(substr(x, 1, 2)) + as.numeric(substr(x, 4, 5)) / 60
}

#' @noRd
time2plottime <- \(x, ref = x[1]) {
  floathour <- datetime2floathour(x)
  time_hour <- floathour + 24 * (floathour < datetime2floathour(ref))
  as.POSIXct(Sys.Date()) + time_hour * 3600
}
