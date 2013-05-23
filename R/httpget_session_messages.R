httpget_session_messages <- function(filepath, requri){
  
  #load data
  myeval <- readRDS(sessionfile <- file.path(filepath, ".REval"));
  mymsg <- extract(myeval, "message");
  mymsg <- lapply(mymsg, "[[", "message");
  
  #render
  reqformat <- requri[1];
  httpget_object(mymsg, reqformat, "messages", "text");
}
