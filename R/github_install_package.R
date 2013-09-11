github_install_package <- function(user, package, lib){
  setwd(tempdir())
  myurl <- paste("https://github.com", user, package, "archive/master.tar.gz", sep="/");
  mytmp <- paste(package, ".tar.gz", sep="");
  
  #On unix we use wget. On windows we rely on setInternet2(TRUE).
  if(.Platform$OS.type == "windows"){
    download.file(myurl, mytmp);
  } else {
    output <- system_capture("wget", paste("-O", deparse(mytmp), deparse(myurl)));
    if(!identical(as.character(output$status), "0")){
      stop("Package download failed.\n\n", paste(output$text, collapse="\n"));
    }
  }
  
  #check if file exists
  if(!file.exists(mytmp) || file.info(mytmp)$size == 0){
    stop("Download failed: ", myurl, "\n\n", paste(output$text, collapse="\n"))
  }
  
  #untar the github tar
  untar(mytmp);
  
  #detect R path. Must be a better way.
  R <- from("parallel", "defaultClusterOptions")$rprog; 
  
  #call out to system
  system_capture(
    R,
    paste("CMD", "INSTALL", paste(package, "master", sep="-"), paste("--library", deparse(lib), sep="="))
  );
}
