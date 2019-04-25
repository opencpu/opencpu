httpget_info <- function(requri){
  #some diagnostics
  myobject <- structure(list(
    System = utils::sessionInfo(),
    Configuration = environment(config)$confpaths,
    Libraries = .libPaths(),
    Apps = github_rootpath()
  ), class = "opencpu_info")

  if(!is_windows()){
    try({
      myobject$Limits <- unix::rlimit_all()
      myobject$Apparmor <- unlist(unix::aa_config())
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

print.opencpu_info <- function(x, ...){
  titles <- names(x)
  type <- ifelse(is_rapache(), "Cloud", "Single-User")
  cat("# OpenCPU: Producing and Reproducing Results\n")
  cat(sprintf("%s Server (version: %s)\n\n", type, as.character(utils::packageVersion('opencpu'))))
  for(i in seq_along(x)){
    cat(sprintf("## %s\n", titles[i]))
    print(x[[i]])
    cat("\n")
  }
}
