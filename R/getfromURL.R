getfromURL <- function(url){
  req <- GET(url)
  ctype <- req$headers[["content-type"]];
  
  if(!length(ctype) || !nchar(ctype)){
    stop("No content-type found for: ", ctype)
  }
  
  if(ctype == "application/json"){
    json <- rawToChar(req$content)
    stopifnot(validate(json))
    return(fromJSON(json))
  }
  
  if(grepl("protobuf", ctype, fixed=TRUE)){
    return(RProtoBuf::unserialize_pb(req$content));
  }
  
  if(ctype == "application/r-rds" || ctype == "application/octet-stream"){
    return(unserialize(gzcon(rawConnection(req$content))))
  }
  
  stop("Unsupported content type ", ctype, "for argument: ", req$url)
}
