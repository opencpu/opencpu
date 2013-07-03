#this is a placeholder for something more advanced

install.apps <- function(pkg, ...){
  
  #input validation
  stopifnot(length(pkg) == 1);
  db <- available.packages();
  stopifnot(pkg %in% row.names(db));
  
  #install in home or site library
  sitelib <- config("appspaths");
  randompath <- file.path(sitelib, round(runif(1, 1e5, 9e5)));
  iswritable <- file.create(randompath, showWarnings=FALSE);
  if(iswritable){
    file.remove(randompath);
    targetpath <- sitelib;
  } else {
    targetpath <- paste(Sys.getenv("R_LIBS_USER"), "-apps", sep="");
    if(!file.exists(targetpath)){
      dir.create(targetpath, recursive=TRUE);
    }
  }
  
  fullname <- paste(pkg, db[pkg,"Version"], sep="_");
  fullpath <- file.path(targetpath, fullname);
  if(file.exists(fullpath)){
    stop("App already exists: ", fullpath);
  }
  dir.create(fullpath);
  oldlib <- .libPaths();
  message("Installing app in: ", fullpath)

  try({
    #go ahead and install
    setLibPaths(fullpath);
    install.packages(pkg, lib=fullpath, dependencies=TRUE, ...);
    
    #autocreate a LIBRARY file
    newdb <- installed.packages();
    alldep <- package_dependencies(pkg, db=newdb, recursive=TRUE)[[pkg]];
    alldep <- c(pkg, alldep);
    allvers <- newdb[alldep, "Version"];
    libstring <- paste(alldep, "==", allvers);
    writeLines(libstring, file.path(fullpath, "LIBRARY"));
    cat("Installed:", libstring, sep="\n");
  });

  setLibPaths(oldlib);
}
