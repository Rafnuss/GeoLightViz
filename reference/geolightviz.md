# Start the GeoLightViz shiny app

Start the GeoLightViz shiny app

## Usage

``` r
geolightviz(x, path = NULL, launch_browser = TRUE, run_bg = TRUE)
```

## Arguments

- x:

  a GeoPressureR `tag` object, a `.Rdata` file or the unique identifier
  `id` with a `.Rdata` file located in `"./data/interim/{id}.RData"`.

- path:

  a GeoPressureR `path` or `pressurepath` data.frame.

- launch_browser:

  If true (by default), the app runs in your browser, otherwise it runs
  on Rstudio.

- run_bg:

  If true (by default), the app runs in a background R process using
  [`callr::r_bg()`](https://callr.r-lib.org/reference/r_bg.html),
  allowing you to continue using the R console. If false, the app blocks
  the console until closed.
