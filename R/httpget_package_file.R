httpget_package_file <- function(pkgpath, requri){
  # Prevent path traversal attack via ../../../
  path <- file.path(pkgpath, paste(requri, collapse="/"))
  assert_subdir(path, pkgpath)

  #For file executions, we should load the package the file is in.
  if(req$method() == "POST"){
    reqpackage <- basename(pkgpath);
    reqlib <- dirname(pkgpath);

    #try to load package from reqlib, but otherwise other paths are OK
    inlib(reqlib,{
      library(reqpackage, character.only=TRUE);
      httpget_file(path)
    });
  } else {
    httpget_file(path)
  }
}
