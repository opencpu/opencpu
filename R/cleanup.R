cleanup <- function(what = c("tmp_library", "gist_library", "github_library", "cran_library", "bioc_library"), maxage=10*60){
  libnames <- file.path(gettmpdir(), what);
  allfiles <- list.files(libnames, full.names=TRUE, include.dirs=TRUE);
  infos <- file.info(allfiles);
  ages <- difftime(Sys.time(), infos$mtime, units="secs");
  unlink(allfiles[ages > maxage], recursive=TRUE);
}
