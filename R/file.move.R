dir.move <- function(from, to){
  if(file.rename(from, to)){
    return(TRUE)
  }
  stopifnot(dir.create(to));
  setwd(from)
  if(all(file.copy(list.files(all.files=TRUE, include.dirs=TRUE), to, recursive=TRUE))){
    #success!
    unlink(from, recursive=TRUE);
    return(TRUE)
  }
  #fail!
  unlink(to, recursive=TRUE);
  stop("Failed to move ", from, " to ", to);
}
