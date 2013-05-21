httpget_doc <- function(requri){
  docdir <- Sys.getenv("R_DOC_DIR");
  myfile <- file.path(docdir, paste(requri, collapse="/"));
  res$sendfile(myfile);
}