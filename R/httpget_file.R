httpget_file <- function(fullpath){
  res$checkfile(fullpath);
  switch(req$method(),
    "GET" = res$sendfile(fullpath),
    "POST" = execute_file(fullpath),
    stop("invalid method: ", req$method())
  );  
}