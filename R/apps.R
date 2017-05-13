#' OpenCPU Application
#'
#' Manage installed OpenCPU applications. These applications can be started locally
#' using \link{ocpu_start_app} or deployed online on \href{https://ocpu.io}{ocpu.io}.
#'
#' OpenCPU apps are simply R packages. For regular users, apps get installed in a
#' user-specific app library which is persistent between R sessions. This is used
#' for locally running or developing web applications.
#'
#' When running these functions as \code{opencpu} user on an OpenCPU cloud server, apps
#' will be installed in the global opencpu server app library; the same library as used
#' by the OpenCPU Github webhook.
#'
#' @export
#' @param repo a github repository such as \code{user/repo}, see \link{install_github}.
#' @param ... additional options for \code{install_github}
#' @rdname apps
#' @name apps
#' @aliases apps
#' @family ocpu
#' @example examples/apps.R
#' @export
install_apps <- function(repo, ...){
  lapply(repo, install_apps_one, ...)
  repo[repo %in% installed_apps()]
}

install_apps_one <- function(repo, ...){
  info <- ocpu_app_info(repo)
  github_info <- github_package_info(url_path(info$user, info$repo))
  package <- github_info$package
  lib <- info$path
  if(!file.exists(lib)){
    dir.create(lib)
    pkgpath <- file.path(lib, package)
    on.exit({
      if(!file.exists(pkgpath)){
        unlink(lib, recursive = TRUE)
        stop(sprintf("Installation of %s failed", repo))
      }
    }, add = TRUE)
  }
  inlib(lib, {
    devtools::install_github(repo, force = TRUE, ...)
    writeLines(package, file.path(lib, "_APP_"))
  })
}

#' @rdname apps
#' @export
remove_apps <- function(repo){
  vapply(repo, function(full_name){
    info <- ocpu_app_info(full_name)
    # cannot remove loaded packages
    try(unloadNamespace(info$package))
    !unlink(info$path, recursive = TRUE)
  }, logical(1))
}

ocpu_app_info <- function(repo){
  parts <- strsplit(repo[1], "[/@#]")[[1]]
  user <- parts[1]
  reponame <- parts[2]
  path <- github_userlib(user, reponame)
  appfile <- file.path(path, "_APP_")
  package <- if(file.exists(appfile)){
    readLines(appfile, n = 1L)[1]
  } else {
    reponame
  }
  data.frame (
    user = user,
    repo = reponame,
    package = package,
    path = path,
    installed = file.exists(path),
    stringsAsFactors = FALSE
  )
}

#' @rdname apps
#' @export
installed_apps <- function(){
  pattern <- paste0("^", github_prefix, "_")
  apps <- list.files(github_rootpath(), pattern = pattern)
  apps <- sub(pattern, "", apps)
  sub("_", "/", apps, fixed = TRUE)
}

#' @rdname apps
#' @export
available_apps <- function(){
  data <- jsonlite::fromJSON('https://api.github.com/users/rwebapps/repos')
  data$full_name
}
