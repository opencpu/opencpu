httpget <- function(){
  
  #extract path
  reqpath <- strsplit(substring(req$path_info(), 2),"/")[[1]];
  
  if(!length(reqpath)){
    res$checkmethod();
    res$redirect(paste(req$uri(), "/pages", sep=""));    
  }
  
  reqhead <- head(reqpath, 1);
  reqtail <- tail(reqpath, -1);

  switch(reqhead,
    "pub" = httpget_pub(reqtail),
    "tmp" = httpget_tmp(reqtail),
    "doc" = httpget_doc(reqtail),
    "user" = httpget_user(reqtail),
    "gist" = httpget_gist(reqtail),
    "github" = httpget_github(reqtail),     
    "cran" = httpget_cran(reqtail),
    "bioc" = httpget_bioc(reqtail),         
    "pages" = httpget_pages(),
    res$notfound(message=paste("Invalid top level api: /", reqhead, sep=""))         
  )
}	
