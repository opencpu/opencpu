#' Load OpenCPU application
#'
#' Loads an OpenCPU app from your local library or a github repository.
#'
#' @export
#' @param repo either name of a locally installed package, or a repository
#' address (passed to \code{install_github})
#' @param ... passed to \code{start_server}
#' @rdname apps
#' @aliases apps
start_github_app <- function(repo, ...){
  repo <- repo[1]
  user <- dirname(repo)
  pkg <- basename(repo)
  gitpath <- github_userlib(user, pkg)
  Sys.setenv(R_LIBS = gitpath)
  on.exit(Sys.unsetenv("R_LIBS"), add = TRUE)
  install_apps(repo, gitpath)
  inlib(gitpath, start_local_app(pkg, ...))
}

#' @export
#' @param package name of locally installed package
#' @rdname apps
start_local_app <- function(package, ...){
  getNamespace(package)
  api <- file.path("library", package)
  start_server(..., preload = package, on_startup = function(server_address){
    app_url <- file.path(server_address, api, "www")
    log("Opening %s", app_url)
    utils::browseURL(app_url)
  })
}

install_apps <- function(repo, lib, ...){
  # create new app lib
  if(!file.exists(lib)){
    dir.create(lib)
    pkgpath <- file.path(lib, basename(repo))
    on.exit({
      if(!file.exists(pkgpath)){
        unlink(lib, recursive = TRUE)
        stop("installation failed: ", pkgpath)
      }
    }, add = TRUE)
  }
  inlib(lib, {
    devtools::install_github(repo, ...)
  })
}
