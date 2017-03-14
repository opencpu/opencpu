httpget_session_source <- function(filepath, requri){
  
  #load data
  myeval <- readRDS(sessionfile <- file.path(filepath, ".REval"));
  mysrc <- extract(myeval, "source");

  #render
  reqformat <- requri[1];
  httpget_object(mysrc, reqformat, "warnings", "text");
}
