#' Clean up OpenCPU files from disk
#' 
#' OpenCPU stores a library with recent sessions and packages on disk. 
#' These files are stored in the temporary directory, so on most systems they are wiped on reboot.
#' The cleanup function can be used to manually force removal of temporary files from disk.
#' 
#' @param what What to clean up? Values correspond to API /ocpu/:what/
#' @param maxage The maximum age (in seconds) for a directory to exempted from deletion.
#' @export
cleanup <- function(what = c("tmp", "gist", "github", "cran", "bioc"), maxage=10*60){
  what <- match.arg(what, several.ok=TRUE)
  libnames <- file.path(gettmpdir(), paste0(what, "_library"));
  allfiles <- list.files(libnames, full.names=TRUE, include.dirs=TRUE);
  infos <- file.info(allfiles);
  ages <- difftime(Sys.time(), infos$ctime, units="secs");
  unlink(allfiles[ages > maxage], recursive=TRUE);
}
