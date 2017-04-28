write_to_file <- function(...){
  mytempfile <- tempfile();
  mytext <- eval(...)
  write(mytext, mytempfile);
  return(mytempfile)
}

from <- function (pkg, name) {
  utils::getFromNamespace(name, pkg)
}

printwithmax <- function(..., max.print = getOption("max.print")){
  oldopt <- options(max.print=max.print);
  print(...);
  options(max.print=oldopt$max.print)
}

# Note .libPaths() only appends paths, doesn't replace anything.
setLibPaths <- function(newlibs, baselib = TRUE){
  checkfordir <- function(path){
    return(isTRUE(file.info(path)$isdir));
  }  
  if(baselib){
    baselibpath <- file.path(Sys.getenv("R_HOME"), "library");
    newlibs <- unique(c(newlibs, baselibpath));
  }
  newlibs <- newlibs[vapply(newlibs, checkfordir, logical(1))]
  assign(".lib.loc", newlibs, envir=environment(.libPaths));
}

check.enabled <- function(what){
  if(isTRUE(config(paste0("enable.", what)))){
    return(TRUE);
  }
  stop('The ', what, ' feature has not been enabled on this server.\nAdmin needs to set: {"enable.', what,'":true}');
}

dir.move <- function(from, to){
  stopifnot(length(from) == 1);
  stopifnot(length(to) == 1);
  stopifnot(!file.exists(to));
  if(file.rename(from, to)){
    return(TRUE)
  }
  stopifnot(dir.create(to, recursive=TRUE));
  setwd(from)
  if(all(file.copy(list.files(all.files=TRUE, include.dirs=TRUE), to, recursive=TRUE))){
    #success!
    unlink(from, recursive=TRUE);
    return(TRUE)
  }
  #fail!
  unlink(to, recursive=TRUE);
  stop("Failed to move ", from, " to ", to);
}

email <- function(to, ...){
  sendmail <- from("sendmailR", "sendmail");
  lapply(to, function(rcpt){
    sendmail(to = rcpt, ...);
  })
}

address <- function(name, mail){
  paste0('"', name, '"<', mail, '>');
}

error2file <- function(e){
  mytempfile <- tempfile();
  errmsg <- e$message;
  if(isTRUE(config("error.showcall")) && !is.null(e$call)){
    errmsg <- c(errmsg, "", "In call:", deparse(e$call));
  }
  write(errmsg, mytempfile);
  return(mytempfile)  
}

errorif <- function(condition, msg){
  errorifnot(!condition, msg)
}

errorifnot <- function(condition, msg){
  if(!isTRUE(condition)){
    res$error(msg);
  }
}

getrapache <- function(x){
  get(x, "rapache")
}

is_windows <- function(){
  grepl("mingw", R.Version()$platform)
}

is_mac <- function(){
  grepl("darwin", R.Version()$platform)
}

islazydata <- function(x, ns){
  exists(x, ns, inherits=FALSE) && 
    identical("lazyLoadDBfetch", deparse(eval(call("substitute", as.name(x), ns))[[1]]))
}

generate_hash <- function(){
  while(file.exists(sessiondir(
    hash <- paste0("x0", substring(paste(rand_bytes(config("key.length")), collapse=""), 1, config("key.length")))
  ))){}
  hash
}

#actual directory
sessiondir <- function(hash){
  file.path(gettmpdir(), "tmp_library", hash);
}

#http path for a session (not actual file path!)
sessionpath <- function(hash){
  paste("/tmp/", hash, sep="");
}

#test if a dir is a session
issession <- function(mydir){
  any(file.exists(file.path(mydir, c(".RData", ".REval"))));
}
