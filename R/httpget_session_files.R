httpget_session_files <- function(filepath, requri){
  res$sendfile(file.path(filepath, paste(requri, collapse="/")));  
}