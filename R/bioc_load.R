bioc_load <- function(pkgname, biocpath){
  if(!file.exists(biocpath)){
    stopifnot(dir.create(biocpath));
  }
  
  pkgpath <- file.path(biocpath, pkgname);
  blockpath <- paste(pkgpath, "block", sep="_")
  
  #is there is a blocker but its old, we remove it. This should not happen.
  if(isTRUE(difftime(Sys.time(), file.info(blockpath)$mtime, units="secs") > config("timelimit.get")+5)){
    stopifnot(file.remove(blockpath, recursive=TRUE, force=TRUE));    
  }
  
  #wait for the block to disappear
  while(file.exists(blockpath)){
    Sys.sleep(1);
  }
  
  #see if it exists and if it is fresh enough
  if(file.exists(pkgpath)){
    return(pkgpath);      
  } 
  
  #make sure its gone
  unlink(pkgpath, recursive=TRUE, force=TRUE);    
  
  #setup a blocker (for concurrent requests to the same gist)
  stopifnot(file.create(blockpath));
  on.exit(unlink(blockpath, force=TRUE));
  
  #NOTE: for now we can't capture output from install.packages
  if(pkgname == "BiocInstaller"){
    output <- try_rscript(paste0('.libPaths(', deparse(biocpath), '); source("http://bioconductor.org/biocLite.R");'));
  } else {
    output <- try_rscript(paste0("BiocInstaller::biocLite(", deparse(pkgname), ", ask=FALSE, lib.loc=", deparse(biocpath), ", lib=", deparse(biocpath), ");"))
  }

  #Installer is done
  if(pkgname == "BiocInstaller"){
    #check if BiocInstaller was loaded.
    if(!eval(call("require","BiocInstaller"))){
      stop("Failed to load BiocInstaller.\n\n", paste(output, collapse="\n"))
    }       
    return(system.file(package="BiocInstaller"));
  }

  #check if package has been installed
  if(!file.exists(pkgpath)){
    #note that stop() might not work because error message is too large (install log)
    header <- paste("Package installation of", pkgname, "was unsuccessful.\n\n");
    msg <- paste(output, collapse="\n");
    res$error(paste(header, msg, sep="\n"));
  }
  
  #return the path 
  return(pkgpath);
}