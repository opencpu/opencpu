#' OpenCPU Single-User Server
#'
#' Starts the OpenCPU single-user server for developing and running apps locally.
#' To deploy your apps on a cloud server or [ocpu.io](https://ocpu.io), simply push
#' them to github and install the opencpu webhook. Some example apps are available
#' from [github::rwebapps/](https://github.com/rwebapps).
#'
#' @importFrom utils getFromNamespace
#' @importFrom parallel makeCluster stopCluster
#' @importFrom evaluate evaluate
#' @importFrom jsonlite toJSON fromJSON validate
#' @aliases opencpu ocpu strings
#' @family ocpu
#' @export
#' @rdname server
#' @name ocpu-server
#' @param port port number
#' @param root base of the URL where to host the OpenCPU API
#' @param workers number of worker processes
#' @param preload character vector of packages to preload in the workers. This speeds
#' up requests to those packages.
#' @param on_startup function to call once server has started (e.g. [utils::browseURL])
#' @param no_cache sets `Cache-Control: no-cache` for all responses to disable browser
#' caching. Useful for development when files change frequently. You might still need
#' to manually flush the browser cache for resources cached previously. Try pressing
#' `CTRL+R` or go incognito if your browser is showing old content.
#' @example examples/apps.R
ocpu_start_server <- function(port = 5656, root ="/ocpu", workers = 2, preload = NULL,
                              on_startup = NULL, no_cache = FALSE) {
  if(is_rapache()){
    # some packages do ocpu_start_server() inside onAttach()
    warning("Not starting single-user server inside rapache")
    return(NULL)
  }

  # normalize root path
  root <- sub("/$", "", sub("^//", "/", paste0("/", root)))

  # set root home for workers
  Sys.setenv("OCPU_MASTER_HOME" = tmp_root())
  on.exit(Sys.unsetenv("OCPU_MASTER_HOME"))

  # import
  sendCall <- getFromNamespace('sendCall', 'parallel')
  recvResult <- getFromNamespace('recvResult', 'parallel')
  preload <- unique(c("opencpu", preload, config("preload")))

  # worker pool
  pool <- list()

  # add new workers if needed
  add_workers <- function(n = 1){
    if(length(pool) < workers){
      log("Starting %d new worker(s). Preloading: %s", n, paste(preload, collapse = ", "))
      cl <- parallel::makeCluster(n)
      lapply(cl, sendCall, fun = function(){
        lapply(preload, getNamespace)
        Sys.getpid()
      }, args = list())
      pool <<- c(pool, cl)
    }
  }

  # get a worker
  get_worker <- function(){
    if(!length(pool))
      add_workers(1)
    node <- pool[[1]]
    pool <<- pool[-1]
    pid <- recvResult(node)
    if(inherits(pid, "try-error"))
      warning("Worker preload error: ", pid, call. = FALSE, immediate. = TRUE)
    node$pid <- pid
    structure(list(node), class = c("SOCKcluster", "cluster"))
  }

  # main interface
  run_worker <- function(fun, ..., timeout = NULL){
    res <- tryCatch({
      if(length(timeout)){
        setTimeLimit(elapsed = timeout)
        on.exit(setTimeLimit(cpu = Inf, elapsed = Inf), add = TRUE)
      }
      cl <- get_worker()
      on.exit(kill_workers(cl), add = TRUE)
      node <- cl[[1]]
      sendCall(node, fun, list(...))
      recvResult(node)
    }, error = function(e){
      if(grepl("elapsed time limit", e$message)){
        log("Worker timeout (%ds, see rlimit.post in user.conf). Killing process %d!", timeout, node$pid)
        tools::pskill(node$pid)
        stop(sprintf("Timeout reached: %ds (see rlimit.post in user.conf)", timeout))
      }
      stop(e)
    })
    if(inherits(res, "try-error"))
      stop(res)
    res
  }

  kill_workers <- function(cl){
    log("Stopped %d worker(s)", length(cl))
    stopCluster(cl) # does not work when child is busy

    #This prevends child from cleaning own tempdir
    #log("Killing process %d", cl[[1]]$pid)
    #tools::pskill(cl[[1]]$pid, tools::SIGKILL) # try to interrupt gracefully
  }

  # Initiate worker pool
  log("OpenCPU single-user server, version %s", as.character(utils::packageVersion('opencpu')))

  # On Linux we use forks instead of workers
  if(win_or_mac()){
    add_workers(workers)
    on.exit(kill_workers(structure(pool, class = c("SOCKcluster", "cluster"))), add = TRUE)
  } else {
    workers <- 0
  }

  # Useful for debugging
  warn <- getOption('warn')
  on.exit(options(warn = warn), add = TRUE)
  options(warn = 1)

  # Start the server
  server_id <- httpuv::startServer("0.0.0.0", port, app = rookhandler(root, run_worker, no_cache))
  server_address <- paste0(get_localhost(port), root)
  log("READY to serve at: %s", server_address)
  log("Press ESC or CTRL+C to quit!")

  # Cleanup server when terminated
  on.exit({
    log("Stopping OpenCPU single-user server")
    httpuv::stopServer(server_id)
  }, add = TRUE)

  # Run a hook
  if(is.function(on_startup))
    on_startup(server_address)

  # Main loop
  repeat {
    for(i in 1:10)
      httpuv::service(100)
    add_workers()
    Sys.sleep(0.001)
  }
}

ocpu_start_app_github <- function(repo, update = TRUE, ...){
  if(isTRUE(update) && curl::has_internet()){
    install_apps(repo)
  }
  info <- ocpu_app_info(repo)
  if(!info$installed)
    stop(sprintf("Application '%s' is not installed. Try: opencpu::install_apps('%s')", repo, repo))
  gitpath <- info$path
  Sys.setenv(R_LIBS = gitpath)
  on.exit(Sys.unsetenv("R_LIBS"), add = TRUE)
  inlib(gitpath, {
    start_server_with_app(info$package, url_path("apps", info$user, info$repo), ...)
  })
}

start_local_app_local <- function(package, ...){
  start_server_with_app(package, url_path("library", package), ...)
}

start_server_with_app <- function(package, path, ...){
  if(!isNamespaceLoaded(package)){
    ns <- getNamespace(package)
    on.exit(unloadNamespace(ns), add = TRUE)
  }
  ocpu_start_server(..., preload = package, on_startup = function(server_address){
    app_url <- url_path(server_address, path)
    log("Opening %s", app_url)
    utils::browseURL(app_url)
  })
}

#' @rdname server
#' @param app either the name of a locally installed package, or a github remote
#' (see \link{install_apps})
#' @param update checks if the app is up-to-date (if possible) before running
#' @param ... extra parameters passed to \link{ocpu_start_server}
#' @export
ocpu_start_app <- function(app, update = TRUE, ...){
  if(!is.character(app) || length(app) != 1)
    stop("Parameter 'app' must be a package name or a github remote")
  if(grepl("/", app)){
    ocpu_start_app_github(app, update = update, ...)
  } else {
    start_local_app_local(app, ...)
  }
}
