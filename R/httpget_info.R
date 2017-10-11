httpget_info <- function(requri){
  #get sessioninfo
  myobject <- list(
    session = utils::sessionInfo(),
    config = environment(config)$confpaths,
    libpaths = .libPaths()
  )

  #only GET allowed
  res$checkmethod("GET");

  #return object
  switch(req$method(),
    "GET" = httpget_object(myobject, "print", "sessionInfo"),
    stop("invalid method")
  );
}
