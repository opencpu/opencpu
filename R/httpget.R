httpget <- function(){
  
  #extract path
  reqpath <- strsplit(substring(URLdecode(req$path_info()), 2),"/")[[1]];
  
  if(!length(reqpath)){
    res$checkmethod();
    res$redirect(paste(req$uri(), "/test", sep=""));    
  }
  
  reqhead <- head(reqpath, 1);
  reqtail <- tail(reqpath, -1);

  switch(reqhead,
    "library" = httpget_library(.libPaths(), reqtail),
    "apps" = httpget_apps(config("appspaths"), reqtail),         
    "tmp" = httpget_tmp(reqtail),
    "doc" = httpget_doc(reqtail),
    "user" = httpget_user(reqtail),
    "gist" = httpget_gist(reqtail),
    "github" = httpget_github(reqtail),     
    "cran" = httpget_cran(reqtail),
    "bioc" = httpget_bioc(reqtail),         
    "test" = httpget_static(),
    res$notfound(message=paste("Invalid top level api: /", reqhead, sep=""))         
  )
}	
