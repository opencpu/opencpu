listallusers <- function(user.only=TRUE){
  if(file.exists("/etc/passwd")){
    out <- try(read.table("/etc/passwd", sep=":", as.is=TRUE));
    if(!is(out, "try-error") && length(out) && nrow(out)){
      if(isTRUE(user.only)){
        out <- subset(out, V3 > 999 & V3 < 65534) 
      }      
      return(out$V1)
    }
  } 
  return(vector());
}
