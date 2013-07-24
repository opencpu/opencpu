cleanup <- function(what = c("tmp_library", "gist_library", "github_library", "cran_library", "bioc_library"), maxage=10*60){
  allfiles <- list.files(gettmpdir(), full.names=TRUE, include.dirs=TRUE, pattern=paste("^", what, sep="", collapse="|"));
  infos <- file.info(allfiles);
  ages <- difftime(Sys.time(), infos$mtime, units="secs");
  unlink(allfiles[ages > maxage], recursive=TRUE);
}
