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
      return(webutils::parse_query(reqbody));
    } else {
      return(as.list(reqbody));
    }
  # test for json
  } else if(grepl("^application/json", contenttype)){
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
  } else if(grepl("^application/r?protobuf", contenttype)){
    if(is.raw(reqbody)){
      obj <- protolite::unserialize_pb(reqbody);
    } else {
      stop("ProtoBuf payload was posted as text ??")
    }
  } else if(grepl("^application/rds", contenttype)){
    obj <- readRDS(gzcon(rawConnection(reqbody)))
  } else {
    stop("POST body with unknown conntent type: ", contenttype);
  }

  # Empty POST data
  if(is.null(obj))
    obj <- as.list(obj)

  if(!is.list(obj) || length(names(obj)) < length(obj)){
    stop("JSON or ProtoBuf input should be a named list.")
  }

  return(lapply(obj, function(x){
    if(is.null(x) ||
       isTRUE(is.atomic(x) && length(x) == 1 &&
              !length(dim(x))) && is.null(names(x))){
      #primitives as expressions
      return(deparse_atomic(x))
    } else {
      return(I(x))
    }
  }));
}

# base::deparse() fucks up utf8 strings
deparse_atomic <- function(x){
  if(is.character(x) && !is.na(x)){
    str <- jsonlite::toJSON(x)
    str <- sub("^\\[", "c(", str)
    sub("\\]$", ")", str)
  } else {
    paste(deparse(x), collapse = "\n")
  }
}
