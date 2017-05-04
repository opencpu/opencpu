#' OpenCPU Single-User Server
#'
#' Starts the OpenCPU single-user server for developing and testing apps locally.
#'
#' @importFrom utils getFromNamespace
#' @importFrom parallel makeCluster stopCluster
#' @importFrom evaluate evaluate
#' @importFrom jsonlite toJSON fromJSON validate
#' @importFrom sys eval_safe
#' @aliases opencpu ocpu
#' @export
#' @rdname server
#' @param port port number
#' @param root base of the URL where to host the OpenCPU API
#' @param workers number of worker processes
#' @param preload character vector of packages to preload in the workers. This speeds
#' up requests to those packages.
#' @param on_startup function to call once server has started (e.g. \code{browseURL})
start_server <- function(port = 9999, root ="/ocpu", workers = 2, preload = NULL, on_startup = NULL) {
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
      cl <- makeCluster(n)
      lapply(cl, sendCall, fun = function(){
        lapply(preload, getNamespace)
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
    res <- recvResult(node)
    if(inherits(res, "try-error"))
      stop("Cluster failed init: ", res)
    structure(list(node), class = c("SOCKcluster", "cluster"))
  }

  # main interface
  run_worker <- function(fun, ..., timeout = NULL){
    if(length(timeout)){
      setTimeLimit(elapsed = timeout)
      on.exit(setTimeLimit(cpu = Inf, elapsed = Inf))
    }
    cl <- get_worker()
    on.exit(kill_workers(cl))
    node <- cl[[1]]
    sendCall(node, fun, list(...))
    res <- recvResult(node)
    if(inherits(res, "try-error"))
      stop(res)
    res
  }

  kill_workers <- function(cl){
    log("Stopped %d worker(s)", length(cl))
    stopCluster(cl)
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

  # Start the server
  server_id <- httpuv::startServer("0.0.0.0", port, app = rookhandler(root, run_worker))
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


#' @rdname server
#' @inheritParams download_apps
#' @export
start_github_app <- function(repo, ...){
  info <- app_info(repo)
  gitpath <- info$path
  Sys.setenv(R_LIBS = gitpath)
  on.exit(Sys.unsetenv("R_LIBS"), add = TRUE)
  # Install on the fly
  if(!info$installed)
    download_apps(repo)
  inlib(gitpath, {
    start_server_app(info$pkg, file.path("apps", info$user), ...)
  })
}

#' @export
#' @param package name of locally installed package
#' @rdname server
start_local_app <- function(package, ...){
  start_server_app(package, "library", ...)
}

start_server_app <- function(package, path, ...){
  getNamespace(package)
  start_server(..., preload = package, on_startup = function(server_address){
    app_url <- file.path(server_address, path, package, "www")
    log("Opening %s", app_url)
    utils::browseURL(app_url)
  })
}
