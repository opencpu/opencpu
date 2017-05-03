#' @importFrom openssl rand_bytes
generate_hash <- function(){
  paste0("x0", substring(paste(rand_bytes(config("key.length")), collapse=""), 1, config("key.length")))
}

session_regex <- function(){
  paste0("^x[0-9a-f]{", config("key.length") + 1, "}$")
}

session_eval <- local({
  preview_object <- function(hash, obj, format){
    tmppath <- sessionpath(hash);
    outputpath <- paste0(req$uri(), tmppath, "/");
    res$setheader("Location", outputpath);
    res$setheader("X-ocpu-session", hash)
    httpget_object(obj, format, "object");
  }

  #redirects the client to the session location
  preview_index <- function(hash, execdir){
    tmppath <- sessionpath(hash);
    path_absolute <- paste0(req$uri(), tmppath, "/");
    path_relative <- paste0(req$mount(), tmppath, "/");
    outlist <- session_index(execdir);
    text <- paste(path_relative, outlist, sep="", collapse="\n");
    res$setheader("Content-Type", 'text/plain; charset=utf-8');
    res$setheader("X-ocpu-session", hash)
    res$redirect(path_absolute, 201, text)
  }

  #evaluates something inside a session
  function(input, args, storeval=FALSE, format="list"){

    #create workding directory
    worker_home <- ifelse(is_rapache(), tempdir(), Sys.getenv('OCPU_SESSION_DIR'))
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

    #store output
    hash <- basename(worker_home)
    save(file=".RData", envir=sessionenv, list=ls(sessionenv, all.names=TRUE), compress=FALSE);
    saveRDS(output$res, file=".REval", compress=FALSE);
    saveRDS(utils::sessionInfo(), file=".RInfo", compress=FALSE);
    saveRDS(.libPaths(), file=".Rlibs", compress=FALSE);
    saveDESCRIPTION(hash)

    #Shortcuts to get object immediately
    if(format %in% c("json", "print", "pb")){
      preview_object(hash, get(".val", sessionenv), format);
    } else if(format %in% c("console")) {
      preview_object(hash, extract(output$res, format), "text");
    } else {
      #default: send 201 with output list.
      preview_index(hash, execdir)
    }
  }
})

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
