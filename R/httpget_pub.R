httpget_pub <- function(uri){
  
  #GET /ocpu/gist/jeroen
  reqhead <- uri[1];
  reqtail <- uri[-1];
  
  if(is.na(reqhead)){
    res$checkmethod();    
    res$sendlist(c("library", "apps"))
  }
  
  switch(reqhead,
     "library" = httpget_library(.libPaths(), reqtail),
     "apps" = httpget_apps(config("appspaths"), reqtail),
     stop("Invalid /pub API:", reqhead)      
  )
}
