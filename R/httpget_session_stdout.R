httpget_session_stdout <- function(filepath, requri){
  
  #load data
  myeval <- readRDS(sessionfile <- file.path(filepath, ".REval"));
  mymsg <- extract(myeval, "text");
  
  #render
  reqformat <- requri[1];
  httpget_object(mymsg, reqformat, "stdout", "text");
}
