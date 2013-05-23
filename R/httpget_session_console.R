httpget_session_console <- function(filepath, requri){
  
  #load data
  myeval <- readRDS(sessionfile <- file.path(filepath, ".REval"));
  mymsg <- extract(myeval, "console");
  
  #render
  reqformat <- requri[1];
  httpget_object(mymsg, reqformat, "console", "text");
}
