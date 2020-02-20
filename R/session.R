#' @importFrom openssl rand_bytes
generate_hash <- function(){
  paste0("x0", substring(paste(rand_bytes(config("key.length")), collapse=""), 1, config("key.length")))
}

session_regex <- function(){
  paste0("^x[0-9a-f]{", config("key.length") + 1, "}$")
}

preview_index <- function(hash, execdir){
  tmppath <- sessionpath(hash)
  path_relative <- paste0(req$mount(), tmppath, "/")
  outlist <- session_index(execdir)
  text <- paste0(path_relative, outlist)
  res$sendtext(text)
}

#evaluates function or script inside a session
session_eval <- function(input, args = NULL, storeval=FALSE, format="list"){

  #create workding directory
  worker_home <- Sys.getenv('OCPU_SESSION_DIR', tempdir())
  Sys.unsetenv('OCPU_SESSION_DIR')
  execdir <- file.path(worker_home, "workspace")
  stopifnot(dir.create(execdir))
  setwd(execdir)

  #copy files to execdir
  lapply(req$files(), function(x){
    stopifnot(file.copy(x$tmp_name, basename(x$name)))
  })

  #load sessions namespaces
  attach_sessions()

  # In OpenCPU 1.x this was executed inside another fork with a stricter apparmor profile
  output <- evaluate_input(input, args, storeval)
  sessionenv <- output$sessionenv

  #in case code changed dir
  setwd(execdir)

  #unload session namespaces, otherwise sessionInfo() crashes
  unload_session_namespaces()

  #set the hash (even if evaluate() returns an error)
  hash <- basename(worker_home)
  res$setheader("X-ocpu-session", hash)
  res$setheader("Location", paste0(req$uri(), sessionpath(hash), "/"))

  #store output
  save(file=".RData", envir = sessionenv, list=ls(sessionenv, all.names = TRUE), compress = FALSE)
  saveRDS(output$res, file=".REval", compress = FALSE)
  saveRDS(utils::sessionInfo(), file=".RInfo", compress = FALSE)
  saveRDS(.libPaths(), file=".Rlibs", compress = FALSE)
  saveDESCRIPTION(hash)

  # OpenCPU 2.0 now uses stop_on_error = 1 so we need to raise the error manually
  if(length(output$error)){
    res$error(format_user_error(output$error), 400)
  }

  # Use 201 instead of 200 in case of success
  res$setstatus(201)

  # Shortcuts to get output immediately
  if(format %in% c("png", "svg", "pdf", "svglite")){
    myplots <- extract(output$res, "graphics")
    if(length(myplots) < 1)
      res$error("Function call did not generate any graphics", 400)
    object <- myplots[[length(myplots)]] # last generated plot
    httpget_object(object, format)
  } else if(format %in% c("print", "md", "bin", "csv", "feather", "json", "rda", "rds", "pb", "tab", "ndjson")){
    httpget_object(get(".val", sessionenv), format, "object")
  } else if(format %in% c("console")) {
    httpget_object(extract(output$res, format), "text")
  } else {
    #default: send 201 with output list.
    preview_index(hash, execdir)
  }
}

#get a list of the contents of the current session
session_index <- function(filepath){

  #verify session exists
  stopifnot(issession(filepath))

  #set the dir
  setwd(filepath)

  #outputs
  outlist <- vector();

  #list data files
  if(file.exists(".RData")){
    myenv <- new.env();
    load(".RData", myenv);
    if(length(ls(myenv, all.names=TRUE))){
      outlist <- c(outlist, paste("R", ls(myenv, all.names=TRUE), sep="/"));
    }
  }

  #list eval files
  if(file.exists(".REval")){
    myeval <- readRDS(".REval");
    if(length(extract(myeval, "graphics"))){
      outlist <- c(outlist, paste("graphics", seq_along(extract(myeval, "graphics")), sep="/"));
    }
    if(length(extract(myeval, "message"))){
      outlist <- c(outlist, "messages");
    }
    if(length(extract(myeval, "text"))){
      outlist <- c(outlist, "stdout");
    }
    if(length(extract(myeval, "warning"))){
      outlist <- c(outlist, "warnings");
    }
    if(length(extract(myeval, "source"))){
      outlist <- c(outlist, "source");
    }
    if(length(extract(myeval, "console"))){
      outlist <- c(outlist, "console");
    }
  }

  #list eval files
  if(file.exists(".RInfo")){
    outlist <- c(outlist, "info");
  }

  #other files
  sessionfiles <- file.path("files", list.files(recursive=TRUE))
  if(length(sessionfiles)){
    outlist <- c(outlist, sessionfiles)
  }

  return(outlist);
}
