httpget_doc <- function(requri){
  docdir <- Sys.getenv("R_DOC_DIR");
  httpget_file(file.path(docdir, paste(requri, collapse="/")));
}
