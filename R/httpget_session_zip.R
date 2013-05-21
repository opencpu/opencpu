httpget_session_zip <- function(sessionpath, requri){
  setwd(sessionpath);
  allfiles <- list.files(all=TRUE, recursive=TRUE);
  tmpzip <- tempfile(fileext=".zip");
  zip(tmpzip, files=allfiles);
  
  #debug
  tryCatch(unzip(tmpzip), warning=function(w) {stop(w$message)});
  res$setheader("tmpfile", tmpzip)  
  
  #continue
  res$setbody(file=tmpzip);
  res$setheader("Content-Type", "application/octet-stream")
  res$setheader("Content-Disposition", paste('attachment; filename="', basename(sessionpath), '.zip"', sep=""));
  res$finish();
}
