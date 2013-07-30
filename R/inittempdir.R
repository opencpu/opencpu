inittempdir <- function(){
  #roottmpdir() will query config()
  mynewtempdir <- file.path(roottmpdir(), "ocpu-temp");
  
  #override temp directory
  dir.create(mynewtempdir, showWarnings = FALSE, recursive = TRUE, mode = "0777");
  getExportedValue("unixtools", "set.tempdir")(mynewtempdir);
  
  #These are needed for install packages
  Sys.setenv(TMPDIR = tempdir());
  options(configure.vars = paste0("TMPDIR=", tempdir()));  
}
