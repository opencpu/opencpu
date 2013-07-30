utils <- local({
   is.binary <- function(filepath,max=1000){
    f=file(filepath,"rb",raw=TRUE)
    b=readBin(f,"int",max,size=1,signed=FALSE)
    close(f)
    return(max(b)>128)
  }
  
  is.ascii <- function(...){
    !is.binary(...)
  }
  
  mimetype <- function(filepath){
    alltypes <- mimelist;
    filename <- tail(strsplit(filepath, "/", fixed=T)[[1]], 1);
    
    #files without a dot are special
    if(!grepl(".", filename, fixed=TRUE)){
      if(is.ascii(filepath)){
        return('text/plain; charset="UTF-8"');
      } else {
        return("application/octet-stream");
      }
    }
   
    #otherwise lookup in mimelist
    input <- tolower(tail(strsplit(filename, ".", fixed=T)[[1]], 1));
    contenttype <- alltypes[[input]];
    if(is.null(contenttype)){
      contenttype <- "application/octet-stream";
    }
    return(contenttype)
  }   
  
  #rook needs this
  asfile <- function(x){
    stopifnot(file.exists(x));
    structure(x, names="file");
    list(file=x);
  }
   
  write_to_file <- function(...){
    mytempfile <- tempfile();
    mytext <- eval(...)
    write(mytext, mytempfile);
    return(mytempfile)
  }
   
  #export from local
  environment();
});
