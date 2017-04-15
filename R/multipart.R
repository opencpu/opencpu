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
    } else if(is.raw(x$value)){
      rawToChar(x$value)
    } else {
      return(x$value)
    }
  })
}
