# Getting Started with GeoLightViz

``` r

library(GeoLightViz)
library(GeoPressureR)
library(tidyverse)
# Get the path to the extdata directory
extdata_dir <- system.file("extdata", package = "GeoLightViz")
```

## Overview

GeoLightViz is an interactive Shiny application designed to streamline
the analysis of geolocator light data. It provides an intuitive
interface for visualizing and labeling twilight events (sunrise/sunset
times) while simultaneously displaying geographic positions on an
interactive map.

This tutorial demonstrates a two-step workflow using data from a
European Bee-eater (tag ID: 14OI) tagged in Germany:

1.  **Step 1**: Label twilight events and define stationary periods
    (equipment/retrieval sites)
2.  **Step 2**: Generate likelihood maps and refine position estimates

## Before You Begin

Prepare the following information for your geolocator analysis: - **Crop
dates**: Start and end dates to exclude pre-deployment and
post-retrieval data - **Known locations**: GPS coordinates for equipment
and retrieval sites (if available)

## Step 1: Labeling Twilights and Defining Stationary Periods

### Creating the Tag Object

The first step is to load your geolocator data using the
[`tag_create()`](https://raphaelnussbaumer.com/GeoPressureR/reference/tag_create.html)
function from the GeoPressureR package. This function reads raw light
measurements and structures them into a standardized format.

**Key parameters:** - `crop_start` and `crop_end`: Define the analysis
period, excluding irrelevant data before deployment and after
retrieval - `assert_pressure = FALSE`: Required for light-only
geolocators without atmospheric pressure sensors

``` r

tag <- tag_create(
  "14OI",
  directory = file.path(extdata_dir, "data/raw-tag/14OI"),
  crop_start = "2015-08-09",
  crop_end = "2016-07-11",
  assert_pressure = FALSE
)

# Detect twilight events
tag <- twilight_create(tag)

# View the tag structure
tag
```

The resulting `tag` object contains: - **Light data**: Cropped to your
specified date range - **Twilight events**: Automatically detected
sunrise and sunset times

### Launching the Interactive Application

``` r

geolightviz(tag)
```

### Working in the Application

The GeoLightViz interface provides two main functions:

#### 1. Labeling Twilight Events

Twilight times detected from light measurements can be noisy due to
weather conditions, shading, or sensor issues. The labeling tool helps
you identify and exclude problematic data points.

**How to label:** 1. Click **“Start labeling”** in the toolbar 2.
**Single points**: Click individual twilight markers to toggle their
status 3. **Batch selection**: Draw a rectangle to select multiple
points at once 4. **Discard criteria**: Remove twilights that show clear
irregularities or outliers

#### 2. Defining Stationary Periods (Staps)

Stationary periods are time intervals when the bird remained at a fixed
location. These are crucial for: - **Calibration**: Using known
locations (e.g., breeding sites) to estimate sun elevation angles -
**Migration analysis**: Identifying stopover sites and wintering grounds

**How to create staps:** 1. Click the **“+” icon** in the toolbar to
enable drawing mode 2. **Draw a rectangle** on the light plot to define
the time range 3. **Look for patterns**: Parallel, smooth twilight lines
indicate stable latitude (stationary behavior)

## Identifying Stationary Periods

In the light plot, stationary periods appear as: - **Parallel
sunrise/sunset lines** (constant day length = stable latitude) -
**Minimal scatter** in twilight times - **Extended duration** (typically
weeks to months for wintering sites)

For this initial step, focus on defining: - **Equipment period**: Tag
attachment to departure - **Retrieval period**: Arrival back to
recapture

### Exporting Your Work

Once you’ve completed labeling and stap definition:

1.  **Export twilight labels**:
    - Click **“Export”** → **“Export Twilight Labels”**
    - Save as `data/twilight-label/14OI.csv`
2.  **Export stationary periods**:
    - Click **“Export”** → **“Export Staps”**
    - Save as `data/staps/14OI.csv`

These files will be used in Step 2 for spatial analysis.

## Step 2: Visualizing Positions with Likelihood Maps

In this step, we enhance the analysis by incorporating spatial
information. Using the twilight labels and known locations from Step 1,
GeoLightViz generates likelihood maps showing probable bird positions
based on day length patterns.

### Loading Previously Labeled Data

First, load the twilight labels you created and exported in Step 1:

``` r

tag <- twilight_label_read(
  tag,
  file = file.path(extdata_dir, "data/twilight-label/14OI-labeled.csv")
)
```

### Adding Known Location Information

Next, load the stationary periods and add GPS coordinates for known
locations. In this example, we add coordinates for the
equipment/breeding site in Germany:

``` r

tag$stap <- read.csv(file.path(extdata_dir, "data/staps/14OI.csv")) |>
  mutate(
    known_lon = 11.93128,
    known_lat = 51.3629
  )
```

**Why known locations matter:** - They serve as **calibration points**
for estimating the sun elevation angle - This angle varies by species,
habitat, and tag placement - Accurate calibration improves position
estimates throughout the entire tracking period

### Configuring the Spatial Grid

Define the geographic extent and resolution for likelihood map
calculations:

``` r

tag$param$tag_set_map <- list(
  extent = c(-5, 25, -10, 55), # put the same order in the excel file
  scale = 5
)
```

**Parameters explained:** - `extent`: Geographic bounding box
`[west, east, south, north]` in decimal degrees - Defines the area where
the bird could potentially have traveled - Should encompass known
breeding, migration, and wintering regions - `scale`: Grid resolution
(higher = finer detail, but slower computation) - `scale = 1`: ~111 km
grid cells (fast, suitable for initial exploration) - `scale = 5`: ~22
km grid cells (detailed, used here for European Bee-eater)

## Choosing Your Map Extent

The extent should be large enough to cover all possible locations but
not unnecessarily large, as this increases computation time. For most
species: - Include known breeding and wintering areas - Add buffer zones
for potential stopover sites - Consider the species’ known migration
range

### Launching the Enhanced Application

``` r

geolightviz(tag)
```

### Features Available in the Enhanced Application

With the map configuration complete, GeoLightViz now provides additional
powerful features:

#### Twilight Labeling (as before)

- Continue to refine your twilight labels
- Discard or restore individual events as needed

#### Stationary Period Management (as before)

- Add, modify, or remove stationary periods
- Adjust start/end times for precision

#### Geographic Position Visualization (NEW)

The map panel now displays: - **Likelihood surfaces**: Color-coded
probability maps based on day length matching - **Position markers**:
Geographic locations for each stationary period - **Interactive
exploration**: Click positions on the map to see corresponding twilight
patterns

#### Position Refinement

- **Manual adjustment**: Click on the map to test different position
  hypotheses
- **Twilight comparison**: Observe how predicted twilight times (lines)
  match observed data (points)
- **Maximum likelihood**: Use the “ML” button to automatically find the
  most probable position

#### Calibration Assessment

- **Compare twilight distributions** between calibrated stationary
  periods (with known coordinates) and uncalibrated periods
- **Evaluate quality**: Assess how well the sun elevation angle
  calibration performs across different time periods
- **Visualize uncertainty**: Use the histogram view to examine twilight
  error distributions

## Interpreting Likelihood Maps

- **Warm colors (yellow/red)**: High probability locations based on day
  length
- **Cool colors (blue)**: Low probability locations
- **Multiple peaks**: Indicate ambiguity (common with light-only data
  due to latitude symmetry)
- **Narrow distributions**: Suggest confident position estimates

------------------------------------------------------------------------

## Next Steps

After completing this workflow, you can:

1.  **Export refined results** for use in other analyses
2.  **Integrate pressure data** (if available) using GeoPressureR for
    improved accuracy
3.  **Perform statistical path analysis** to estimate migration routes
4.  **Generate publication-ready figures** using the exported data

For advanced features including pressure integration, movement modeling,
and wind assistance analysis, see the [GeoPressureR
documentation](https://raphaelnussbaumer.com/GeoPressureR/).
