httpget_session_info <- function(filepath, requri){
  #load data
  myinfo <- readRDS(sessionfile <- file.path(filepath, ".RInfo"));
  
  #render
  reqformat <- requri[1];
  httpget_object(myinfo, reqformat, "sessionInfo");  
}