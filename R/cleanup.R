cleanup <- function(what = c("Rtmp", "ocpu_github", "ocpu_gist", "ocpu_tmp", "ocpu_session"), maxage=10*60){
  allfiles <- list.files(gettmpdir(), full.names=TRUE, include.dirs=TRUE, pattern=paste("^", what, sep="", collapse="|"));
  infos <- file.info(allfiles);
  ages <- difftime(Sys.time(), infos$mtime, units="secs");
  unlink(allfiles[ages > maxage], recursive=TRUE);
}
