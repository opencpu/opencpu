httpget_package_info <- function(pkgpath) {
  reqpackage <- basename(pkgpath);
  reqlib <- dirname(pkgpath);  
  pkghelp <- eval(call("help", package=reqpackage, lib.loc=reqlib, help_type="text"))
  res$sendtext(format(pkghelp));
}
