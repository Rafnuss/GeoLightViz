#!/usr/bin/env Rscript

#' Generate Screenshots for GeoLightViz Documentation (Alternative Version)
#'
#' This script provides an alternative approach using webshot2 for capturing
#' screenshots. It's simpler and more reliable than chromote for most use cases.
#'
#' Requirements:
#' - webshot2 package
#' - GeoLightViz package installed
#' - GeoPressureR package installed
#'
#' Usage:
#'   Rscript tools/make_screenshot_webshot.R

# Load required packages
library(GeoLightViz)
library(GeoPressureR)
library(webshot2)

# Create output directory if it doesn't exist
output_dir <- "man/figures"
if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
}

vwidth <- 1400
vheight <- 900

# ============================================================================
# Helper function to capture app screenshot
# ============================================================================
get_url <- function(tag) {
    # Temporary connection to capture messages
    tf <- tempfile()
    con <- file(tf, open = "wt")
    sink(con, type = "message")

    GeoLightViz::geolightviz(tag)

    sink(type = "message")
    close(con)

    # Read captured messages
    msg <- readLines(tf, warn = FALSE)
    url <- sub(".*<([^>]+)>.*", "\\1", msg[grepl("Opening GeoLightViz", msg)])

    url
}

# ============================================================================
# Step 1: Basic App Screenshot
# ============================================================================

# Get the path to the extdata directory
extdata_dir <- system.file("extdata", package = "GeoLightViz")


tag <- tag_create(
    "14OI",
    directory = file.path(extdata_dir, "data/raw-tag/14OI"),
    crop_start = "2015-08-09",
    crop_end = "2016-07-11",
    assert_pressure = FALSE
)

tag <- twilight_create(tag)

url <- get_url(tag)

# Capture screenshot
if (F) {
    webshot2::webshot(
        url = url,
        file = file.path(output_dir, "screenshot-01-basic.png"),
        delay = 5,
        vwidth = vwidth,
        vheight = vheight
    )
}

system2(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    args = c("--incognito", "--new-window", url, "--window-size=1400,900")
)


# ============================================================================
# Step 2: Enhanced App Screenshot
# ============================================================================

# Load twilight labels
tag <- twilight_label_read(
    tag,
    file = file.path(extdata_dir, "data/twilight-label/14OI-labeled.csv")
)

# Load staps with known locations
tag$stap <- read.csv(file.path(extdata_dir, "data/staps/14OI.csv")) |>
    dplyr::mutate(
        known_lon = 11.93128,
        known_lat = 51.3629
    )

# Configure map extent
tag$param$tag_set_map <- list(
    extent = c(-5, 25, -10, 55),
    scale = 5
)

url <- get_url(tag)


# ============================================================================
# Step 3: Enhanced App Screenshot
# ============================================================================
url <- get_url(tag)

system2(
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    args = c("--incognito", "--new-window", url, "--window-size=1400,900")
)

# Capture a region (x, y, width, height)
# system2("screencapture", args = c("-R0,0,1400,900", "screenshot.png"))
