httpget_session_zip <- function(sessionpath, requri){
  setwd(sessionpath);
  allfiles <- list.files(all.files = TRUE, recursive = TRUE);
  tmpzip <- tempfile(fileext=".zip");
  zip::zip(tmpzip, files = allfiles, recurse = FALSE);

  #debug
  stoponwarn(utils::unzip(tmpzip));

  #continue
  res$setbody(file=tmpzip);
  res$setheader("Content-Type", "application/zip")
  res$setheader("Content-Disposition", paste('attachment; filename="', basename(sessionpath), '.zip"', sep=""));
  res$finish();
}

stoponwarn <- function(...){
  tryCatch(eval(...), warning=function(w){
    stop("warning! ", w$message)
  })
}
