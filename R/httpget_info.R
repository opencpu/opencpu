httpget_info <- function(requri){
  #some diagnostics
  myobject <- list(
    session = utils::sessionInfo(),
    config = environment(config)$confpaths,
    libpaths = .libPaths()
  )

  if(!is_windows()){
    try({
      myobject$rlimits <- unix::rlimit_all()
      myobject$apparmor <- unlist(sys::aa_config())
    }, silent = TRUE)
  }

  #only GET allowed
  res$checkmethod("GET");

  #return object
  switch(req$method(),
    "GET" = httpget_object(myobject, "print", "sessionInfo"),
    stop("invalid method")
  );
}
