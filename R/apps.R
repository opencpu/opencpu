#' OpenCPU Application
#'
#' Manage installed OpenCPU applications. These applications can be started locally
#' using \link{ocpu_start_app}.
#'
#' When running this functions as \code{root} user, they can be used to manage globally
#' installed apps on an OpenCPU cloud server. However to install apps on cloud servers and
#' \code{ocpu.io} it is easier to the Github webhook.
#'
#' @export
#' @param repo a github repository such as \code{user/repo}, see \link{install_github}.
#' @param ... additional options for \code{install_github}
#' @rdname apps
#' @name apps
#' @aliases apps
#' @family ocpu
#' @export
ocpu_install_apps <- function(repo, ...){
  info <- ocpu_info_apps(repo)
  lib <- info$path
  if(!file.exists(lib)){
    dir.create(lib)
    pkgpath <- file.path(lib, info$pkg)
    on.exit({
      if(!file.exists(pkgpath)){
        unlink(lib, recursive = TRUE)
        stop(sprintf("Installation of %s failed", repo))
      }
    }, add = TRUE)
  }
  inlib(lib, {
    devtools::install_github(repo, force = TRUE, ...)
  })
}

#' @rdname apps
#' @export
ocpu_remove_apps <- function(repo){
  unlink(ocpu_info_apps(repo)$path, recursive = TRUE)
}

#' @rdname apps
#' @export
ocpu_info_apps <- function(repo){
  parts <- strsplit(repo[1], "[/@#]")[[1]]
  user <- parts[1]
  pkg <- parts[2]
  path <- github_userlib(user, pkg)
  data.frame (
    user = user,
    pkg = pkg,
    path = path,
    installed = file.exists(path),
    stringsAsFactors = FALSE
  )
}

#' @rdname apps
#' @export
ocpu_installed_apps <- function(){
  pattern <- paste0("^", github_prefix, "_")
  apps <- list.files(github_rootpath(), pattern = pattern)
  apps <- sub(pattern, "", apps)
  sub("_", "/", apps, fixed = TRUE)
}
