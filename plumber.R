#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)

files <- rev(sort(list.files(here::here("sam"), full.names = TRUE)))
sam <- rbindlist(lapply(files, fread))[, term := factor_sam(term)]


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
