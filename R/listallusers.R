listallusers <- function(user.only=TRUE){
  if(grepl("darwin", R.Version()$platform)){
    out <- system2("dscl", ". list /Users | grep -v ^_.*", stdout=TRUE)
    if(is.null(attr(out, "status")) || attr(out, "status") == 0){
      return(out);
    }
  }
  if(file.exists("/etc/passwd")){
    out <- try(read.table("/etc/passwd", sep=":", as.is=TRUE));
    if(!inherits(out, "try-error") && length(out) && nrow(out)){
      if(isTRUE(user.only)){
        out <- out[out$V3 > 999 & out$V3 < 65534, ]
      }      
      return(out$V1)
    }
  } 
  return(vector());
}
