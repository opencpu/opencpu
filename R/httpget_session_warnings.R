httpget_session_warnings <- function(filepath, requri){
  
  #load data
  myeval <- readRDS(sessionfile <- file.path(filepath, ".REval"));
  mywarnings <- extract(myeval, "warning");
  mywarnings <- lapply(mywarnings, "[[", "message");
  
  #render
  reqformat <- requri[1];
  httpget_object(mywarnings, reqformat, "warnings", "text");
}
