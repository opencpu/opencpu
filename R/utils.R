utils <- local({
   is.binary <- function(filepath,max=1000){
    f=file(filepath,"rb",raw=TRUE)
    b=readBin(f,"int",max,size=1,signed=FALSE)
    close(f)
    return(max(b)>128)
  }
  
  is.ascii <- function(...){
    !is.binary(...)
  }
  
  #rook needs this
  asfile <- function(x){
    stopifnot(file.exists(x));
    structure(x, names="file");
    list(file=x);
  }
   
  write_to_file <- function(...){
    mytempfile <- tempfile();
    mytext <- eval(...)
    write(mytext, mytempfile);
    return(mytempfile)
  }
   
  #export from local
  environment();
})

from <- function (pkg, name) {
  utils::getFromNamespace(name, pkg)
}

