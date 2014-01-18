multipart <- local({
  main <- function(body, contenttype){
    if(!grepl("multipart/form-data; boundary=", contenttype, fixed=TRUE)){
      stop("Content type is not multipart/form-data: ", contenttype);
    }
    
    #we expect body to be raw vector
    if(is.character(body)){
      body <- charToRaw(body);
    }
    stopifnot(is.raw(body));
    
    #get the boundary string
    boundary <- sub("multipart/form-data; boundary=", "--", contenttype, fixed=TRUE);
    blength <- nchar(boundary);
    
    #indexes
    indexes <- grepRaw(boundary, body, fixed=TRUE, all=TRUE);
    
    if(length(indexes) == 0){
      stop("Boundary was not found in the body.")
    }
    
    if(length(indexes) == 1){
      if(length(body) < nchar(boundary)+5){
        #in case of an empty JS FormData object
        return(list())
      } else {
        #this probably means something went wrong
        stop("The 'boundary' was only found once in the multipart/form-data message. It should appear at least twice. The request-body seems to be truncated.")        
      }
    }
    
    parts <- list();
    for(i in seq_along(head(indexes, -1))){
      from <- indexes[i] + blength;
      to <- indexes[i+1] -1;
      parts[[i]] <- body[from:to];
    }

    postparts <- lapply(parts, multipart_sub);
    
    #same output as 'Rook' package
    POST <- list();
    for(i in seq_along(postparts)){
      if(postparts[[i]]$type == "file"){
        POST <- c(POST, structure(list(list(name=postparts[[i]]$filename, tmp_name=postparts[[i]]$value)), names=postparts[[i]]$name));
      } else {
        POST <- c(POST, structure(list(postparts[[i]]$value), names=postparts[[i]]$name))
      }
    }
    
    return(POST);
  }
  
  multipart_sub <- function(bodydata){
    stopifnot(is.raw(bodydata));
    
    splitchar <- grepRaw("\\r\\n\\r\\n|\\n\\n|\\r\\r", bodydata);
    if(!length(splitchar)){
      stop("Invalid multipart subpart:\n\n", rawToChar(bodydata));
    }
    
    headers <- bodydata[1:(splitchar-1)];
    headers <- trail(rawToChar(headers));
    headers <- gsub("\r\n", "\n", headers);
    headers <- gsub("\r", "\n", headers);
    headerlist <- unlist(lapply(strsplit(headers, "\n")[[1]], trail));
    
    dispindex <- grep("^Content-Disposition:", headerlist);
    if(!length(dispindex)){
      stop("Content-Disposition header not found:", headers);
    }
    dispheader <- headerlist[dispindex];
    
    #get parameter name
    regmatch <- regexpr("; name=\\\"(.*?)\\\"", dispheader);
    if(regmatch < 0){
      stop('failed to find the name="..." header')
    }
    namefield <- substring(dispheader, regmatch, regmatch+attr(regmatch,"match.length")-1);
    namefield <- sub("; name=", "", namefield, fixed=TRUE);
    namefield <- unquote(namefield)
    
    #test for file upload
    regmatch <- regexpr("; filename=\\\"(.*?)\\\"", dispheader);
    if(regmatch < 0){
      type <- "value";
      filenamefield = "";
    } else {
      type <- "file";
      filenamefield <- substring(dispheader, regmatch, regmatch+attr(regmatch,"match.length"));
      filenamefield <- sub("; filename=", "", filenamefield, fixed=TRUE);
      filenamefield <- unquote(filenamefield)
    }
    
    #filedata  
    splitval  <- grepRaw("\\r\\n\\r\\n|\\n\\n|\\r\\r", bodydata, value=TRUE); 
    start <- splitchar + length(splitval);
    if(identical(tail(bodydata,2), charToRaw("\r\n"))){
      end <- length(bodydata)-2;      
    } else {
      end <- length(bodydata)-1;      
    }
    subdata <- bodydata[start:end];
    
    if(type == "value"){
      value <- rawToChar(subdata);
    } else {
      mytmp <- tempfile(fileext=paste("_", filenamefield, sep=""));
      writeBin(subdata, mytmp);
      value <- mytmp;
    }
    
    list(
      type = type,
      value = value,
      name = namefield,
      filename = filenamefield
    )
  }
  
  trail <- function(str){
    str <- sub("\\s+$", "", str, perl = TRUE);
    sub("^\\s+", "", str, perl = TRUE);
  }
  
  unquote <- function(str){
    len <- nchar(str)
    if(substr(str, 1, 1) == '"' && substr(str, len, len) == '"'){
      return(substr(str, 2, len-1));
    } else {
      return(str)
    }
  }
  main
});
