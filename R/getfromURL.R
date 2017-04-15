getfromURL <- function(url){
  if(!is_rapache() && grepl(req$fullmount(), rstudioproxy(url))){
    #stop("Loopback URL arguments currently not supported in single-user server: ", url)
    tmpres <- getlocalurl(rstudioproxy(url))
    ctype <- tmpres$headers[["Content-Type"]]
    content <- readBin(tmpres$body, raw(), file.info(tmpres$body)$size)
  } else {
    h <- curl::new_handle("useragent" = "OpenCPU")
    curl::handle_setheaders(h, Accept="application/r-rds, application/json, */*")
    req <- curl::curl_fetch_memory(url)
    if(req$status_code >= 400)
      stop(sprintf("Failed to download %s: HTTP %d", url, req$status_code))
    headers <- curl::parse_headers(req$headers)
    ptrn <- "^content-type: "
    ctype <- sub(ptrn, "", grep(ptrn, headers, ignore.case = TRUE, value = TRUE), ignore.case = TRUE)
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
    return(protolite::unserialize_pb(content));
  }
  
  if(ctype == "application/r-rds"){
    return(unserialize(gzcon(rawConnection(content))))
  }
  
  stop("Unsupported content type ", ctype, " for argument: ", url)
}
