rapachehandler <- function(){

  #Fix for case insensitive headers
  reqheaders <- getrapache("SERVER")$headers_in;
  names(reqheaders) <- tolower(names(reqheaders));

  #Note getrapache("POST") before internals("postParsed") to evaluate the promise.
  if(getrapache("SERVER")$internals("postParsed")){
    getrapache("setStatus")(503L)
    getrapache("sendBin")(charToRaw("request was already parsed"))
    return(getrapache("OK"))
  }

  #Do not let apreq parse parse POST
  MYRAW <- if(getrapache("SERVER")$method %in% c("POST", "PUT")){
    rawdata <- getrapache("receiveBin")()
    ctype <- reqheaders[["content-type"]]
    list(
      body = rawdata,
      ctype = ctype
    )
  }

  #reconstruct the full URL
  scheme <- ifelse(isTRUE(getrapache("SERVER")$HTTPS), "https", "http");
  host <- reqheaders[["host"]];
  mount <- getrapache("SERVER")$cmd_path;
  fullmount <- paste0(scheme, "://", host, mount);

  #collect request data from rapache
  REQDATA <- list(
    METHOD = getrapache("SERVER")$method,
    MOUNT = getrapache("SERVER")$cmd_path,
    FULLMOUNT = fullmount,
    PATH_INFO = getrapache("SERVER")$path_info,
    GET = getrapache("GET"),
    RAW = MYRAW,
    CTYPE = reqheaders[["content-type"]],
    ACCEPT = reqheaders[["accept"]]
  );

  # Silence extra output
  sink("/dev/null")
  on.exit(sink(), add = TRUE)
  response <- serve(REQDATA)

  #set server header
  response$headers["X-ocpu-server"] <- "rApache";

  #hack for cors support
  if(identical(response$headers[["Access-Control-Allow-Origin"]], "*") && length(reqheaders[["origin"]])){
    response$headers[["Access-Control-Allow-Origin"]] <- reqheaders[["origin"]]
  }

  #set status code
  getrapache("setStatus")(response$status);

  #set headers
  headerlist <- response$headers;
  for(i in seq_along(headerlist)){
    if(identical(names(headerlist[i]), "Content-Type")){
      getrapache("setContentType")(headerlist[[i]]);
    } else {
      getrapache("setHeader")(names(headerlist[i]), headerlist[[i]]);
    }
  }

  # response must be raw vector
  stopifnot(is.raw(response$body))
  getrapache("sendBin")(response$body)

  #return
  return(getrapache("OK"))
}
