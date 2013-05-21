httpget_session_console <- function(filepath, requri){
  
  #load data
  myeval <- readRDS(sessionfile <- file.path(filepath, ".REval"));
  mytext <- extract(myeval, "text");
  
  #render
  reqformat <- requri[1];
  httpget_object(mytext, reqformat, "messages");
}
