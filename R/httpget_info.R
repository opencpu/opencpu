httpget_info <- function(requri){
  #get sessioninfo
  myobject <- sessionInfo();
  
  #return object
  switch(req$method(),
    "GET" = httpget_object(myobject, "print", "sessionInfo"),
    stop("invalid method")
  );
}