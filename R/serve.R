serve <- function(REQDATA, run_worker = NULL){

  # Windows / Mac don't support eval_fork() (OSX segfault for CoreFoundation)
  if(win_or_mac()){
    if(REQDATA$METHOD %in% c("HEAD", "GET", "OPTIONS")){
      pwd <- getwd()
      on.exit(setwd(pwd), add = TRUE)
      return(request(REQDATA))
    } else {
      hash <- generate_hash()
      tmp <- file.path(ocpu_temp(), hash)
      stopifnot(dir.create(tmp))
      mytmp <- normalizePath(tmp)
      on.exit({
        gc() #GC on windows closes open file descriptors before moving dir!
        if(file.exists(file.path(mytmp, "workspace/.RData")))
          file_move(file.path(mytmp, "workspace"), sessiondir(hash))
      }, add = TRUE)
      on.exit(unlink(mytmp, recursive = TRUE), add = TRUE)
      expr <- c(
        call("Sys.setenv", OCPU_SESSION_DIR = mytmp),
        parse(text = "opencpu:::request(REQDATA)")
      )
      return(tryCatch({
        run_worker(eval, expr = expr, envir = list(REQDATA = REQDATA), timeout = config("timelimit.post"))
      }, error = error_handler)) #extra error catching shouldn't be needed but just in case
    }
  }

  # Everything else (rapache, linux, macos)
  timeout <- if(isTRUE(grepl("^/webhook", REQDATA$PATH_INFO))) {
    config("timelimit.webhook")
  } else if(isTRUE(REQDATA$METHOD %in% c("HEAD", "GET", "OPTIONS"))){
    config("timelimit.get")
  } else {
    config("timelimit.post")
  }

  # Use an AppArmor profile if available
  profile <- if(use_apparmor()){
    ifelse(isTRUE(grepl("^/webhook", REQDATA$PATH_INFO)), "opencpu-main", "opencpu-exec")
  }

  # Don't enforce proc limit when running single user server (regular user)
  limits <- if(config("enable.rlimits")){
    c(
      cpu = timeout + 3,
      as = config("rlimit.as"),
      fsize = config("rlimit.fsize"),
      nproc = if(is_rapache()) config("rlimit.nproc")
    )
  }

  # RApache (cloud server) runs request in a fork, saves workding dir and wipes tmpdir afterwards
  hash <- generate_hash()
  tmp <- file.path(ocpu_temp(), hash)
  if(!dir.create(tmp))
    stop(sprintf("Failed to create tempdir %s. Check directory permissions.", tmp))
  mytmp <- normalizePath(tmp)
  if(REQDATA$METHOD == "POST"){
    on.exit({
      if(file.exists(file.path(mytmp, "workspace")))
        file_move(file.path(mytmp, "workspace"), sessiondir(hash))
    }, add = TRUE)
  }
  on.exit(unlink(mytmp, recursive = TRUE), add = TRUE)

  # Extra tryCatch in case eval_safe() raises a timeout/memory error
  tryCatch(sys::eval_safe(request(REQDATA), tmp = mytmp, timeout = as.numeric(timeout),
                        profile = profile, rlimits = limits, device = ocpu_grdev),
           error = error_handler)
}
