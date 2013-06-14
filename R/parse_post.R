parse_post <- function(reqbody, contenttype){
  #check for no data
  if(is.null(reqbody) || !length(reqbody)){
    return(list())  
  }
  
  #strip title form header
  contenttype <- sub("Content-Type: ?", "", contenttype, ignore.case=TRUE);
  
  #test for multipart
  if(grepl("multipart/form-data", contenttype, fixed=TRUE)){
    return(multipart(reqbody, contenttype));
  } else if(grepl("x-www-form-urlencoded", contenttype, fixed=TRUE)){
    if(is.raw(reqbody)){
      return(parse_query(reqbody));
    } else {
      return(as.list(reqbody));
    }
  } else if(grepl("application/json", contenttype, fixed=TRUE)){
    library(RJSONIO)
    if(is.raw(reqbody)){
      return(fromJSON(rawToChar(reqbody)));
    } else {
      return(fromJSON(reqbody));        
    }
  } else {
    stop("POST body with unknown conntent type: ", contenttype);
  }  
}