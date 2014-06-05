parse_post <- function(reqbody, contenttype){
  #check for no data
  if(!length(reqbody)){
    return(list())  
  }

  #strip title form header
  contenttype <- sub("Content-Type: ?", "", contenttype, ignore.case=TRUE);
  
  #invalid content type
  if(!length(contenttype) || !nchar(contenttype)){
    stop("No Content-Type header found.")  
  }
  
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
    if(is.raw(reqbody)){
      jsondata <- rawToChar(reqbody);
    } else {
      jsondata <- reqbody;        
    }
    if(!validate(jsondata)){
      stop("Invalid JSON was posted.")
    }
    obj <- as.list(fromJSON(jsondata));
    if(!is.list(obj) || length(names(obj)) < length(obj)){
      stop("JSON input should be a named list (json object).")
    }
    return(lapply(obj, function(x){
      if(isTRUE(is.atomic(x) && length(x) == 1)){
        #primitives as expressions
        return(deparse(x))
      } else {
        return(I(x))
      }
    }));
  } else if(grepl("protobuf", contenttype, fixed=TRUE)){
    if(is.raw(reqbody)){
      return(RProtoBuf::unserialize_pb(reqbody));
    } else {
      stop("ProtoBuf payload was posted as text ??")
    }    
  } else {
    stop("POST body with unknown conntent type: ", contenttype);
  }  
}