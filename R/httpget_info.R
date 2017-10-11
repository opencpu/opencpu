httpget_info <- function(requri){
  #get sessioninfo
  myobject <- list(
    config = environment(config)$confpaths,
    libpaths = .libPaths(),
    session = utils::sessionInfo()
  )

  #only GET allowed
  res$checkmethod("GET");

  #return object
  switch(req$method(),
    "GET" = httpget_object(myobject, "print", "sessionInfo"),
    stop("invalid method")
  );
}
