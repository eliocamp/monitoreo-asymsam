library(magrittr)

clim <- readRDS(gl$mean_rds)
sd <- readRDS(gl$sam_sd_rds)
campos <- readRDS(gl$sam_rds) %>%
  data.table::melt(id.vars = c("lon", "lat", "lev"))

sam_file <- function(date) {
  file.path(here::here("analysis/monitoreo/sam"),
            paste0(format(date, "%Y-%m-%d"), "_sam.csv"))
}

normalise_coords <- function(data,
                             rules =  list(lev = c("level"),
                                           lat = c("latitude"),
                                           lon = c("longitude", "long"),
                                           time = c("date")),
                             extra = list()) {
  rules <- c(rules, extra)

  for (f in seq_along(rules)) {
    old <- colnames(data)[colnames(data) %in% rules[[f]]]

    if (length(old) != 0) {
      data.table::setnames(data,
                           old,
                           names(rules)[[f]],
                           skip_absent = TRUE)
    }
  }
  return(invisible(data))
}


strip_year <- function(time) {
  lubridate::year(time) <- 2000
  time
}


computar_sam <- function(file) {
  hgt <- metR::ReadNetCDF(file, vars = c(hgt = "z")) %>%
    normalise_coords() %>%
    .[, time2 := strip_year(time[1]), by = time]


  clim[hgt, on = c("lon", "lat", "lev", "time2")] %>%
    .[, anom := hgt - mean] %>%
    campos[., on = c("lon", "lat", "lev"), allow.cartesian = TRUE] %>%
    .[, metR::FitLm(anom, value, weights = cos(lat*pi/180), r2 = TRUE), by = .(variable, lev, time)] %>%
    .[term != "(Intercept)"] %>%
    .[, term := NULL] %>%
    data.table::setnames("variable", "term") %>%
    sd[., on = c("lev", "term")] %>%
    .[, estimate := estimate/sd] %>%
    .[, sd := NULL] %>%
    .[]

}





