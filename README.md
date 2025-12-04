
<!-- README.md is generated from README.Rmd. Please edit that file and use devtools::build_readme() -->

# GeoLightViz

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/Rafnuss/GeoLightViz/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Rafnuss/GeoLightViz/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/Rafnuss/GeoLightViz/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/Rafnuss/GeoLightViz/actions/workflows/pkgdown.yaml)
[![lint](https://github.com/Rafnuss/GeoLightViz/actions/workflows/jarl-check.yml/badge.svg)](https://github.com/Rafnuss/GeoLightViz/actions/workflows/jarl-check.yml)
[![format](https://github.com/Rafnuss/GeoLightViz/actions/workflows/format-check.yaml/badge.svg)](https://github.com/Rafnuss/GeoLightViz/actions/workflows/format-check.yaml)
<!-- badges: end -->

**GeoLightViz** is an R package that provides an interactive Shiny
application for visualizing and analyzing light-level geolocator data.
The app helps researchers explore the complete workflow from raw light
measurements to geographic positions.

## Features

- 🔍 **Side-by-side twilight–map visualization**: Instantly see how
  sunrise/sunset times translate to geographic positions
- ✏️ **Interactive labeling**: Interactively discard twilight points and
  watch position estimates update in real time
- 📍 **Stationary period explorer**: Define periods where the bird can
  be assumed at the same location and estimate likely locations
- 🎯 **Real-time position updates**: Change the position on the map to
  preview expected twilight patterns for any location
- 📊 **Calibration comparison**: Visualize error distributions to assess
  the calibration assumptions and its impact on known locations
- 🗺️ **Likelihood exploration**: Explore probability surfaces and
  position uncertainty
- 💾 **Workflow support**: Export labeled data for integration with
  GeoPressureR’s advanced modeling tools
- ⚡ **Learn by doing**: The intuitive interface makes twilight
  geolocation methods transparent and accessible

## Installation

You can install the development version of GeoLightViz with:

``` r
# install.packages("pak")
pak::pak("Rafnuss/GeoLightViz")
```

## Quick Start

The package includes example data from a European Bee-eater tagged in
Germany. Try it out:

``` r
# Get example data path
extdata_dir <- system.file("extdata", package = "GeoLightViz")

# Load and launch
tag <- tag_create(
  "14OI",
  directory = file.path(extdata_dir, "data/raw-tag/14OI"),
  crop_start = "2015-08-09",
  crop_end = "2016-07-11",
  assert_pressure = FALSE
)

geolightviz(tag)
```

That’s it! The app will open in your browser where you can:

<div class="callout-note">

📖 For a detailed step-by-step tutorial with examples, see **[See the
complete workflow in the tutorial
→](vignettes/geolightviz-tutorial.Rmd)**

</div>

## Citation

If you use GeoLightViz in your research, please cite:

    # Citation information will be added

## License

This project is licensed under the GPL-3 License.
