httpget_session_files <- function(filepath, requri){
  httpget_file(file.path(filepath, paste(requri, collapse="/")));  
}