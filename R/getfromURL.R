getfromURL <- function(url){
  if(!is_rapache() && grepl(req$fullmount(), rstudioproxy(url))){
    #stop("Loopback URL arguments currently not supported in single-user server: ", url)
    tmpres <- getlocalurl(rstudioproxy(url))
    ctype <- tmpres$headers[["Content-Type"]]
    content <- readBin(tmpres$body, raw(), file.info(tmpres$body)$size)
  } else {
    req <- GET(url, httr::config(
      httpheader = c(`User-Agent` = "RCurl/OpenCPU", Accept="application/r-rds, application/json, */*")
    ))    
    ctype <- req$headers[["content-type"]];
    content <- req$content
  }

  if(!length(ctype) || !nchar(ctype)){
    stop("No content-type found for: ", ctype)
  }
  
  if(ctype == "application/json"){
    json <- rawToChar(content)
    stopifnot(validate(json))
    return(fromJSON(json))
  }
  
  if(grepl("protobuf", ctype, fixed=TRUE)){
    return(RProtoBuf::unserialize_pb(content));
  }
  
  if(ctype == "application/r-rds"){
    return(unserialize(gzcon(rawConnection(content))))
  }
  
  stop("Unsupported content type ", ctype, " for argument: ", url)
}
