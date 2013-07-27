httpget_doc <- function(requri){
  #set cache value as for libraries
  res$setcache("lib");    
  
  #find doc dir
  docdir <- Sys.getenv("R_DOC_DIR", "/usr/share/R/doc");
  httpget_file(file.path(docdir, paste(requri, collapse="/")));
}
