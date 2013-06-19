httpget_session_zip <- function(sessionpath, requri){
  setwd(sessionpath);
  allfiles <- list.files(all=TRUE, recursive=TRUE);
  tmpzip <- tempfile(fileext=".zip");
  zip(tmpzip, files=allfiles);
  
  #debug 
  tryCatch(unzip(tmpzip), warning=function(w) {stop(w$message)});
  
  #continue
  res$setbody(file=tmpzip);
  res$setheader("Content-Type", "application/zip")
  res$setheader("Content-Disposition", paste('attachment; filename="', basename(sessionpath), '.zip"', sep=""));
  res$finish();
}
