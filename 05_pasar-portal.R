source(here::here("scritps/globals.R"))

cmd <- paste0("scp ", "index.html",
              " elio.campitelli@portal.cima.fcen.uba.ar:~/wwwuser/asymsam/monitoreo/index.html")

system(cmd)


file <- gl$plots[[1]]

lapply(gl$plots, function(file) {
  cmd <- paste0("scp ", shQuote(file),
                " ", shQuote(paste0("elio.campitelli@portal.cima.fcen.uba.ar:~/wwwuser/asymsam/monitoreo/plots/",
                                    basename(file))))

  system(cmd)
})

