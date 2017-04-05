listallusers <- function(user.only=TRUE){
  if(grepl("darwin", R.Version()$platform)){
    out <- system2("dscl", ". list /Users | grep -v ^_.*", stdout=TRUE)
    if(is.null(attr(out, "status")) || attr(out, "status") == 0){
      return(out);
    }
  }
  if(file.exists("/etc/passwd")){
    out <- try(utils::read.table("/etc/passwd", sep=":", as.is=TRUE));
    if(!inherits(out, "try-error") && length(out) && nrow(out)){
      if(isTRUE(user.only)){
        out <- out[out$V3 > 999 & out$V3 < 65534, ]
      }      
      return(out$V1)
    }
  } 
  return(vector());
}

checkuser = function(username, user.only = TRUE){
  if(username %in% opencpu:::listallusers(FALSE)){
    return(TRUE)
  } else {
    out <- try(read.table("/etc/sysconfig/authconfig", sep="=", as.is=TRUE))
    if(!is(out, "try-error") && length(out) && nrow(out) &&
         out$V2[out$V1 == "USESSSD"] == "yes"){
      out <- system2("id", username, stdout=TRUE)
      if(is.null(attr(out, "status")) || attr(out, "status") == 0){
        if(isTRUE(user.only)){
          uid = as.numeric(regmatches(out, regexpr("(?<=uid=)[0-9]*", out, perl=TRUE)))
          return(uid > 999 && uid < 65534)
        }
        return(TRUE)
      }
      return(FALSE)
    }
    return(FALSE)
  }
}