library(plumber)

port <- Sys.getenv("PORT")
pr_run(pr("plumber.R"), port=8000)
