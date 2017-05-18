packagename = "opencpu"

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

send_email <- function(to, ...){
  sendmail <- from("sendmailR", "sendmail");
  lapply(to, function(rcpt){
    sendmail(to = rcpt, ...);
  })
}

address <- function(name, address){
  if(!length(address) || !is.character(address) || !grepl("@", address, fixed = TRUE))
    return(NULL)
  if(!length(name) || !is.character(name) || !nchar(name))
    return(address)
  sprintf('"%s"<%s>', name, address)
}

errbuf <- function(e){
  errmsg <- e$message;
  if(isTRUE(config("error.showcall")) && !is.null(e$call)){
    errmsg <- c(errmsg, "", "In call:", deparse(e$call));
  }
  charToRaw(paste(errmsg, collapse = "\n"))
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

is_linux <- function(){
  grepl("linux", R.Version()$platform)
}

is_admin <- function(){
  is_linux() && isTRUE(Sys.info()[["user"]] %in% c("root", "opencpu"))
}

win_or_mac <- function(){
  grepl("mingw|darwin", R.Version()$platform)
}

is_rstudio_server <- function(){
  as.logical(nchar(Sys.getenv("RSTUDIO_HTTP_REFERER")))
}

islazydata <- function(x, ns){
  exists(x, ns, inherits=FALSE) &&
    identical("lazyLoadDBfetch", deparse(eval(call("substitute", as.name(x), ns))[[1]]))
}

#actual directory
sessiondir <- function(hash){
  file.path(ocpu_store(), hash);
}

#http path for a session (not actual file path!)
sessionpath <- function(hash){
  paste("/tmp/", hash, sep="");
}

#test if a dir is a session
issession <- function(mydir){
  any(file.exists(file.path(mydir, c(".RData", ".REval"))));
}

#changes default to call.=FALSE
stop <- function(..., call. = FALSE, domain = NULL){
  args <- list(...)
  if(length(args) == 1L && inherits(args[[1L]], "condition")){
    #when error is a condition object
    base::stop(args[[1L]])
  } else{
    #when error is a string
    base::stop(..., call. = call., domain = domain);
  }
}

# This function is never called
# It only suprresses the "Namespaces in Imports field not imported from:" check
stub <- function(){
  curl::curl_fetch_memory()
  pander::pander()
  devtools::install_github()
  brew::brew()
  httpuv::runServer()
  knitr::knit()
}

eval_current <- function(expr, envir=parent.frame(), timeout = 60){
  setTimeLimit(elapsed = timeout);
  on.exit(setTimeLimit(cpu = Inf, elapsed = Inf), add = TRUE)
  eval(expr, envir)
}

# Note:
file_move <- function(from, to){
  if(!file.rename(from, to))
    stop(sprintf("Failed to move %s to %s", from, to))
}

guess_content_type <- function(file){
  type <- mime::guess_type(file)
  ifelse(grepl("^text/", type), paste0(type, "; charset=utf-8"), type)
}

deparse_query <- function(x){
  paste(names(x), curl::curl_escape(unlist(x)), sep = "=", collapse = "&")
}

format_user_error <- function(e){
  errmsg <- e$message;
  if(length(e$call)){
    errmsg <- c(errmsg, "", "In call:", deparse(e$call));
  }
  return(errmsg)
}

url_path <- function(...){
  file.path(..., fsep = "/")
}

is_ocpu_server <- function(){
  identical("dev.opencpu.org", Sys.info()[["nodename"]])
}

collapse <- function(x){
  paste(x, collapse = ", ")
}

public_url <- function(){
  tryCatch({
    url_path(config("public.url"), req$mount())
  }, error = function(e){
    req$fullmount()
  })
}
