httpget <- function(){

  #temporary fix for OPTIONS method support
  #should implement this per resource and send some text
  if(isTRUE(req$method() == "OPTIONS")){
    res$setheader("Access-Control-Allow-Methods", "POST, GET, HEAD, OPTIONS, DELETE");
    res$sendtext("OPTIONS OK");
  }

  #extract path
  reqpath <- strsplit(substring(curl::curl_unescape(req$path_info()), 2),"/")[[1]];

  if(!length(reqpath)){
    res$checkmethod();
    res$redirectpath("/test");
  }

  reqhead <- utils::head(reqpath, 1);
  reqtail <- utils::tail(reqpath, -1);

  switch(reqhead,
    "library" = httpget_library(.libPaths(), reqtail),
    "lib" = httpget_library(.libPaths(), reqtail), # new alias for /library
    "tmp" = httpget_tmp(reqtail),
    "doc" = httpget_doc(reqtail),
    "user" = httpget_user(reqtail),
    "github" = httpget_apps(reqtail),
    "apps" = httpget_apps(reqtail), # new alias for /github
    "webhook" = httpget_webhook(),
    "test" = httpget_static(),
    "info" = httpget_info(),
    res$notfound(message=paste("Invalid top level api: /", reqhead, sep=""))
  )
}
