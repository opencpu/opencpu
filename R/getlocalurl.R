getlocalurl <- function(url){
  path <- sub(req$fullmount(), "", url)
  split <- strsplit(path, "?", fixed=TRUE)[[1]];

  REQDATA = list(
    METHOD = "GET",
    MOUNT = req$mount(),
    PATH_INFO = split[1],
    FULLMOUNT = req$fullmount(),
    GET = if(is.na(split[2])) list() else parse_query(split[2]),
    ACCEPT = "*/*" 
  )
  
  tmpres <- eval_psock(
    tryCatch(
      get("request", envir=asNamespace("opencpu"))(get("main", envir=asNamespace("opencpu"))(REQDATA)), error=get("reshandler", envir=asNamespace("opencpu"))
    ), timeout=config("timelimit.get")-3
  )
  
  if(tmpres$status != 200L){
    stop("Failed to download object ", url, ": ", readLines(tmpres$body))
  }
  return(tmpres)
}
