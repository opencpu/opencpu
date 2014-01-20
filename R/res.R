#simple closure store for response data
res <- local({
  bodyfile <- NULL;
  headers <- list();  
  
  reset <- function(){
    bodyfile <<- NULL;
    headers <<- list();
    invisible();
  };
  
  finish <- function(status=200){
    if(is.null(bodyfile)){
      stop("No body set.")
    }
    resvalue <- list(status=status, headers=headers, body=bodyfile);
    do.call(respond, resvalue);
  };
  
  setbody <- function(text, file){
    if(!missing(file)){
      stopifnot(file.exists(file));
      bodyfile <<- file;     
      return(invisible());
    } 
    bodyfile <<- utils$write_to_file(text);
    invisible();
  };
  
  setheader <- function(name, value){
    MAXLENGTH = 100 #truncate long headers
    if(is.character(value) && length(value) > 0){
      value <- substring(paste(value, collapse=". ", sep=". "), 0, MAXLENGTH);
      headers <<- c(headers, structure(list(value), names=name));
    }
    invisible();
  };

  setcookie <- function(name, value){
    cookiestring = paste(name, "=", value, "; ",sep="")
    setheader("Set-Cookie", cookiestring);
    invisible();
  }  
  
  redirect <- function(target, status=302, txt){
    if(missing(txt)){
      setbody(paste("Redirect to", target));
    } else {
      setbody(txt);
    }    
    setheader("Location", target);
    finish(status);
  };
    
  redirectpath <- function(subpath, status = 302){
    baseuri <- paste0(req$uri(), req$path_info());
    baseuri <- sub("/$", "", baseuri);
    subpath <- sub("^/", "", subpath);
    fullpath <- paste0(baseuri, "/", subpath);
    redirect(fullpath, status=status);
  }
  
  notfound <- function(filepath, message){
    if(missing(message)){
      if(missing(filepath)){
        message <- paste("Invalid API call:", req$path_info()) 
      } else {
        message <- paste("File not found:", filepath);
      }
    };
    setbody(message);
    setheader("Content-Type", "text/plain")
    finish(404);
  };
  
  error <- function(msg, status=400){
    setbody(msg);
    finish(status);
  }

  checktrail <- function(){
    if(!grepl("/$", req$path_info())){
      redirectpath("/")
    }
  };
  
  checkfile <- function(filepath){
    if(!file.exists(filepath)){
      notfound(filepath);
    }      
  };
  
  checkmethod <- function(methods = "GET"){
    if(!(req$method() %in% methods)){
      error(paste("Method:", req$method(), "invalid on", req$path_info()), 405);
    }
  }
  
  setcache <- function(what){
    method <- req$method();
    if(method == "POST"){
      cachevalue <- config("httpcache.post");
    } else if(method == "GET"){
      cachevalue <- switch(what,
        git = config("httpcache.git"),
        gitapi = config("httpcache.gitapi"),                           
        lib = config("httpcache.lib"),
        tmp = config("httpcache.tmp"),
        cran = config("httpcache.cran"),
        bioc = config("httpcache.bioc"),                           
        static = config("httpcache.static"),  
        stop("Setcache called for unknown type: ", what)
      );
    } else {
      stop("Setcache called for unknown method: ", method);         
    }
    setheader("Cache-Control", paste("max-age=", cachevalue, ", public", sep=""));    
  }
  
  listdir <- function(dirpath){
    checkfile(dirpath);
    sendtext(list.files(dirpath));
    finish(200);
  };
  
  sendlist <- function(vector){
    checktrail();
    vector <- sort(unique(vector));
    sendtext(paste(vector, sep="\n", collapse="\n"));
  }
        
  sendtext <- function(text){
    text <- paste(text, collapse="\n");
    setbody(text);
    setheader("Content-Type", 'text/plain; charset=utf-8')
    finish(200);
  };
  
  sendfile <- function(filepath, mimetype){
    #windows doesn't like trailing slash
    filepath <- sub("/$", "", filepath);
    checkfile(filepath);
    if(file.info(filepath)$isdir){
      checktrail();
      if(file.exists(file.path(filepath, "index.html"))){
        sendfile(file.path(filepath, "index.html"));
      } else{
        listdir(filepath);
      }
    }
    bodyfile <<- filepath;
    if(missing(mimetype)){
      mimetype <- utils$mimetype(filepath);
    }
    setheader("Content-Type", mimetype);
    finish(200);
  };
  
  environment();
});