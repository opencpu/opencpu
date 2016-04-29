httpget_session_tar <- function(sessionpath, requri){
  setwd(sessionpath);
  tmptar <- tempfile(fileext=".tar.gz");
  utils::tar(tmptar, files=".", compression="gzip");

  #continue
  res$setbody(file=tmptar);
  res$setheader("Content-Type", "application/x-gzip")
  res$setheader("Content-Disposition", paste('attachment; filename="', basename(sessionpath), '.tar.gz"', sep=""));
  res$finish();
}
