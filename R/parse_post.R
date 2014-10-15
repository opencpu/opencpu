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
  
  # test for multipart
  if(grepl("multipart/form-data", contenttype, fixed=TRUE)){
    return(multipart(reqbody, contenttype));
  # test for url-encoded
  } else if(grepl("x-www-form-urlencoded", contenttype, fixed=TRUE)){
    if(is.raw(reqbody)){
      return(parse_query(reqbody));
    } else {
      return(as.list(reqbody));
    }
  # test for json
  } else if(grepl("application/json", contenttype, fixed=TRUE)){
    if(is.raw(reqbody)){
      jsondata <- rawToChar(reqbody);
    } else {
      jsondata <- reqbody;        
    }
    if(!(is_valid <- validate(jsondata))){
      stop("Invalid JSON was posted: ", attr(is_valid, "err"))
    }
    obj <- as.list(fromJSON(jsondata));
  # test for protobuf
  } else if(grepl("protobuf", contenttype, fixed=TRUE)){
    if(is.raw(reqbody)){
      obj <- RProtoBuf::unserialize_pb(reqbody);
    } else {
      stop("ProtoBuf payload was posted as text ??")
    }    
  } else {
    stop("POST body with unknown conntent type: ", contenttype);
  }
  
  if(!is.list(obj) || length(names(obj)) < length(obj)){
    stop("JSON or ProtoBuf input should be a named list.")
  }
  
  return(lapply(obj, function(x){
    if(isTRUE(is.atomic(x) && length(x) == 1)){
      #primitives as expressions
      return(deparse(x))
    } else {
      return(I(x))
    }
  }));  
}