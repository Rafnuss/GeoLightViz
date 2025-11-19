
<!-- README.md is generated from README.Rmd. Please edit that file -->

# GeoLightViz

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/Rafnuss/GeoLightViz/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Rafnuss/GeoLightViz/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/Rafnuss/GeoLightViz/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/Rafnuss/GeoLightViz/actions/workflows/pkgdown.yaml)
[![lint](https://github.com/Rafnuss/GeoLightViz/actions/workflows/lint.yaml/badge.svg)](https://github.com/Rafnuss/GeoLightViz/actions/workflows/lint.yaml)
[![style](https://github.com/Rafnuss/GeoLightViz/actions/workflows/style.yaml/badge.svg)](https://github.com/Rafnuss/GeoLightViz/actions/workflows/style.yaml)
<!-- badges: end -->

**GeoLightViz** is an interactive visual tool designed to help
researchers understand and explore the complete workflow from light
measurements to geographic positions with light-level geolocator data.

The app provides a unique **side-by-side visualization** where you can
see how twilight events (sunrise/sunset times) directly translate to
positions on a map. This interadevtools::build_readme()ctive linkage
helps you:

- 🔍 **Visualize the twilight → position relationship**: See immediately
  how each twilight pattern corresponds to a geographic location
- 🎨 **Explore labeling effects**: Interactively label or discard
  twilight points and watch how this changes position estimates in
  real-time
- 📊 **Understand calibration**: Compare calibrated vs uncalibrated
  periods to grasp how known locations improve accuracy
- 🗺️ **Test position hypotheses**: Click anywhere on the map to see what
  twilight pattern would be expected at that location
- ⚡ **Learn by doing**: The interactive interface makes the complex
  twilight geolocation method more intuitive and transparent

Rather than treating geolocator analysis as a black box, GeoLightViz
opens up the process, making it easier to understand why certain
positions are more likely, how data quality affects results, and what
role calibration plays in improving estimates.

## Features

- � **Interactive twilight-map linkage**: Side-by-side visualization
  showing the direct connection between twilight patterns and geographic
  positions
- 🎯 **Real-time position updates**: Click on the map to instantly see
  predicted twilight times for any location
- ✏️ **Visual labeling feedback**: Discard problematic twilight points
  and immediately see how position estimates change
- 📍 **Stationary period explorer**: Define time periods and watch the
  app calculate the most likely geographic position
- � **Calibration comparison**: Visualize twilight error distributions
  to understand calibration quality and its impact
- �️ **Likelihood exploration**: Explore probability surfaces to
  understand position uncertainty and alternative locations
- 💾 **Workflow support**: Export labeled data for integration with
  GeoPressureR’s advanced modeling tools

## Installation

You can install the development version of GeoLightViz from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Rafnuss/GeoLightViz")
```

## Quick Start

``` r
library(GeoLightViz)
library(GeoPressureR)

# Load your geolocator data
tag <- tag_create(
  "your_tag_id",
  directory = "path/to/data",
  crop_start = "2015-08-09",
  crop_end = "2016-07-11",
  assert_pressure = FALSE
)

# Detect twilight events
tag <- twilight_create(tag)

# Launch the interactive app
geolightviz(tag)
```

That’s it! The app will open in your browser where you can: 1. **Label
twilights** to exclude problematic data 2. **Define stationary periods**
by drawing rectangles on the plot 3. **Explore positions** on the
interactive map 4. **Export your results** for further analysis

For a detailed step-by-step tutorial with examples, see the **[Getting
Started vignette](vignettes/geolightviz-tutorial.Rmd)**.

## Workflow Overview

    1. Load data → 2. Detect twilights → 3. Launch app → 4. Explore & label → 5. Export
                                               ↓
                                  (Optional: Add map configuration)
                                               ↓
                             6. Relaunch → 7. Explore with spatial context

**The power of GeoLightViz**: Unlike batch processing tools, the app
lets you explore the data interactively at each step, building intuition
about how twilight geolocation works and where uncertainty comes from.

📖 **[See the complete workflow in the tutorial
→](vignettes/geolightviz-tutorial.Rmd)**

## Key Concepts

### Interactive Twilight-Position Linkage

The core feature of GeoLightViz is the **real-time connection** between
twilight patterns and map positions. As you interact with either panel
(twilight plot or map), the other updates instantly, helping you
understand: - How day length constrains latitude - How twilight timing
constrains longitude  
- Why multiple locations can produce similar twilight patterns (the
“latitude ambiguity” problem) - How data quality affects position
certainty

### What You’ll Learn in the App

**Twilight Events**: See how sunrise/sunset times translate to
geographic positions

**Stationary Periods**: Identify time intervals of stable location by
their parallel twilight lines

**Calibration Effects**: Compare error distributions to understand how
known locations improve accuracy

**Likelihood Maps**: Explore probability surfaces and test “what if”
scenarios by clicking on the map

📖 **[Learn more about these concepts in the tutorial
→](vignettes/geolightviz-tutorial.Rmd)**

## Example Data

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

tag <- twilight_create(tag)
geolightviz(tag)
```

📖 **[See the full example with map configuration
→](vignettes/geolightviz-tutorial.Rmd)**

## Function Arguments

### `geolightviz(x, path = NULL, launch_browser = TRUE, run_bg = TRUE)`

**Arguments:** - `x`: A GeoPressureR `tag` object, `.RData` file, or tag
ID - `path`: Optional `path` or `pressurepath` data.frame from
GeoPressureR - `launch_browser`: If `TRUE` (default), opens in browser;
if `FALSE`, opens in RStudio viewer - `run_bg`: If `TRUE` (default),
runs app in background process; if `FALSE`, blocks R console

## Next Steps

After labeling and position estimation with GeoLightViz, continue with
[GeoPressureR](https://raphaelnussbaumer.com/GeoPressureR/) for:

- Integrating atmospheric pressure data
- Graph-based movement modeling  
- Wind assistance analysis
- Statistical path optimization

## Getting Help

- 📖 [Tutorial vignette](vignettes/geolightviz-tutorial.Rmd): Detailed
  step-by-step guide
- 💻 [Function documentation](man/geolightviz.Rd): `?geolightviz`
- 🔗 [GeoPressureR](https://raphaelnussbaumer.com/GeoPressureR/):
  Companion package documentation
- 🐛 [Issues](https://github.com/Rafnuss/GeoLightViz/issues): Report
  bugs or request features

## Citation

If you use GeoLightViz in your research, please cite:

    # Citation information will be added

## License

This project is licensed under the GPL-3 License.
