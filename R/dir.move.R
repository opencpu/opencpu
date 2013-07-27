dir.move <- function(from, to){
  stopifnot(length(from) == 1);
  stopifnot(length(to) == 1);
  stopifnot(!file.exists(to));
  if(file.rename(from, to)){
    return(TRUE)
  }
  stopifnot(dir.create(to, recursive=TRUE));
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
