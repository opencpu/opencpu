#' @importFrom webutils parse_http
multipart <- function(body, type){
  formdata <- webutils::parse_http(body, type)
  lapply(formdata, function(x){
    if(length(x$filename)){
      tmp <- tempfile(fileext=paste0("_", basename(x$filename)))
      writeBin(x$value, tmp)
      list (
        name = x$filename,
        tmp_name = tmp
      )
    } else if(length(x$content_type)){
      # binary form-data objects that are not file uploads
      if(identical(x$content_type, "application/rds")){
        I(unserialize(x$value))
      } else if(identical(x$content_type, "application/json")){
        I(jsonlite::fromJSON(rawToChar(x$value)))
      } else if(grepl("^application/r?protobuf$", x$content_type)){
        I(protolite::unserialize_pb(x$value))
      } else if(grepl("^text/", x$content_type)){
        I(rawToChar(x$value))
      } else if(grepl("^application/octet", x$content_type)){
        I(x$value)
      } else {
        stop(sprintf("Multipart request contains unsupported data type '%s'.", x$content_type))
      }
    } else if(is.raw(x$value)){
      rawToChar(x$value)
    } else {
      return(x$value)
    }
  })
}
