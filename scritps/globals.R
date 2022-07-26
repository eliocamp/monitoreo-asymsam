# Crea un environment llamado gl donde guardar variables globales
# comunes a todo el sistema de monitoreo.
gl <- list()

gl$climatology <- as.Date(c("1979-01-01", "2000-12-31"))
gl$levels <- c(700, 50)
gl$sam_area <- c(-20, 0, -90, 360)
gl$res <- c(2.5, 2.5)


gl$base_request <- list(
  product_type = "reanalysis",
  format = "netcdf",
  variable = "geopotential",
  dataset_short_name = "reanalysis-era5-pressure-levels",
  pressure_level = as.character(gl$levels),
  year = NA,
  month = NA,
  day = NA,
  time = c("00:00"),
  area = gl$sam_area,
  grid = gl$res,
  target = "download.nc"
)



gl$sam_file <- here::here("datos/campos.csv")
gl$climatologia_file <- here::here("datos/climatologia.gz")
gl$sam_sd_file <- here::here("datos/sam_sd.csv")


gl$plots <- list(
  sam_campos  = here::here("plots/campos.png"),
  sam_latest12 = here::here("plots/latest12.png"),
  sam_latest6 = here::here("plots/latest6.png"),
  sam_latest3 = here::here("plots/latest3.png")
)
