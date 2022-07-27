#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)

files <- rev(sort(list.files("sam", full.names = TRUE)))
sam <- data.table::rbindlist(lapply(files, data.table::fread))


season <- function (x, lang = c("en", "es")) {
  if (is.character(x))
    x <- as.Date(x)
  if (.is.somedate(x))
    x <- lubridate::month(x)
  if (lang[1] == "en") {
    djf <- "DJF"
  }
  else {
    djf <- "DEF"
  }
  jja <- "JJA"
  mam <- "MAM"
  son <- "SON"
  seasons <- c(djf, djf, rep(c(mam, jja, son), each = 3),
               djf)
  return(factor(seasons[x], levels = c(djf, mam, jja, son)))
}



seasonally <- function (x)  {

  if (is.character(x)) {
    x <- as.Date(x)
  }

  times <- unique(x)
  m <- data.table::month(times)
  times_org <- times
  lubridate::year(times[m == 12]) <- data.table::year(times[m == 12]) + 1
  s <- season(times)
  lubridate::day(times) <- 15
  lubridate::month(times) <- (as.numeric(s) - 1) * 3 + 1
  as.Date(times[match(x, times_org)])
}


#* @apiTitle Plumber Example API
#* @apiDescription Plumber example description.

#* Return the sum of two numbers
#* @param mindate First date
#* @param maxdate Last date
#* @param timestep optional processsing
#* @get /getsam
#* @serializer csv
function(mindate, maxdate, timestep = "daily") {
    mindate <- as.Date(mindate)
    maxdate <- as.Date(maxdate)

    out <- sam[time >= mindate & time <= maxdate]

    if (timestep == "monthly") {
        out <- out[, .(estimate = mean(estimate),
                       r.squared = mean(r.squared)),
                   by = .(lev, term, time = lubridate::floor_date(time, "month"))]
    } else if (timestep == "seasonal") {
        out <- out[, .(estimate = mean(estimate),
                       r.squared = mean(r.squared)),
                   by = .(lev, term, time = seasonally(time))]
    }

    return(out)
}
