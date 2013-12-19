httpget_file <- function(fullpath){
  fullpath <- do.call("file.path", as.list(fullpath));
  res$checkfile(fullpath);

  #only GET/POST allowed
  res$checkmethod(c("GET", "POST"));
  
  switch(req$method(),
    "GET" = res$sendfile(fullpath),
    "POST" = execute_file(fullpath),
    stop("invalid method: ", req$method())
  );  
}
