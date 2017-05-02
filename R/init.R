# Setup directories etc
.onLoad <- function(lib, pkg){
  ocpu_init()
}

# Note we MUST hardcode for rapache because ocpu_init() changes tempdir()
TMPROOTDIR <- NULL
tmp_root <- function(){
  if(is.null(TMPROOTDIR))
    stop("TMPROOTDIR is not set")
  TMPROOTDIR
}

ocpu_temp <-function(){
  file.path(tmp_root(), "ocpu-temp")
}

ocpu_store <-function(){
  file.path(tmp_root(), "ocpu-store")
}

ocpu_init <- function(){
  # Check for cloud server options
  if(isTRUE(getOption("rapache"))){
    is_rapache(TRUE)
  }

  if(isTRUE(getOption("apparmor"))){
    use_apparmor(TRUE)
  }

  if(isTRUE(getOption("no_rapparmor"))){
    no_rapparmor(TRUE)
  }

  # Find configurations
  load_config_and_settings(preload = TRUE)

  # Set the initial root dir
  TMPROOTDIR <<- tryCatch(config("tempdir"), error = function(e){
    if(is_rapache())
      return("/tmp")
    worker_home <- Sys.getenv("OCPU_WORKER_HOME", NA)
    ifelse(is.na(worker_home), tempdir(), dirname(dirname(worker_home)))
  })

  # Create temporary directories
  dir.create(ocpu_temp(), showWarnings = FALSE, recursive = TRUE, mode = "0777")
  dir.create(ocpu_store(), showWarnings = FALSE, recursive = TRUE, mode = "0777")

  # Needed for install.packages() in rapache / rapparmor
  if(is_rapache()){
    sys:::set_tempdir(ocpu_temp())
    Sys.setenv(TMPDIR = tempdir())
    Sys.setenv(HOME = tempdir())
    options(configure.vars = paste0("TMPDIR=", tempdir()))
  }
}
