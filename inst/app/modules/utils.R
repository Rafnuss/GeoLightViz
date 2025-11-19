# Utility functions used across the app

time2plottime <- function(x, ref = x[1]) {
  floathour <- datetime2floathour(x)
  time_hour <- floathour + 24 * (floathour < datetime2floathour(ref))
  as.POSIXct(Sys.Date()) + time_hour * 3600
}

datetime2floathour <- function(x) {
  if (!is.character(x)) {
    x <- format(x, "%H:%M")
  }
  as.numeric(substr(x, 1, 2)) + as.numeric(substr(x, 4, 5)) / 60
}
