#' Load OpenCPU application
#'
#' Loads an OpenCPU app from your local library or a github repository.
#'
#' @export
#' @param repo either name of a locally installed package, or a repository
#' address (passed to \code{install_github})
#' @param ... passed to \code{ocpu_start}
load_app <- function(repo,  ...){
  repo <- repo[1]
  if(grepl("/", repo))
    devtools::install_github(repo)
  pkg <- basename(repo)
  getNamespace(pkg)
  ocpu_start(..., preload = basename(repo), on_startup = function(server_address){
    app_url <- paste0(server_address, "/library/", pkg, "/www")
    log("Opening %s", app_url)
    utils::browseURL(app_url)
  })
}
