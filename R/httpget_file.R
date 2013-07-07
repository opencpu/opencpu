httpget_file <- function(fullpath){
  fullpath <- do.call("file.path", as.list(fullpath));
  res$checkfile(fullpath);
  switch(req$method(),
    "GET" = res$sendfile(fullpath),
    "POST" = execute_file(fullpath),
    stop("invalid method: ", req$method())
  );  
}
