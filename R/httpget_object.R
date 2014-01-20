httpget_object <- local({
  main <- function(object, reqformat, objectname, defaultformat){
    #Default format
    if(is.na(reqformat)){
      if(missing(defaultformat)){
        defaultformat <- "print";
      }
      res$redirectpath(defaultformat);
    }
    
    #render object
    switch(reqformat,
      "print" = httpget_object_print(object),
      "md" = httpget_object_pander(object),
      "text" = httpget_object_text(object),
      "ascii" = httpget_object_ascii(object),
      "bin" = httpget_object_bin(object, objectname),
      "csv" = httpget_object_csv(object, objectname),
      "file" = httpget_object_file(object),
      "json" = httpget_object_json(object),
      "rda" = httpget_object_rda(object, objectname),
      "rds" = httpget_object_rds(object, objectname),
      "pb" = httpget_object_pb(object, objectname),
      "tab" = httpget_object_tab(object, objectname),
      "png" = httpget_object_png(object),
      "pdf" = httpget_object_pdf(object, objectname),
      "svg" = httpget_object_svg(object, objectname),
      res$notfound(message=paste("Invalid output format for objects:", reqformat))
    )    
  }
  
  httpget_object_bin <- function(object, objectname){
    mytmp <- tempfile();
    do.call("writeBin", c(req$get(), list(object=object, con=mytmp)));
    res$setbody(file=mytmp);
    res$setheader("Content-Type", "application/octet-stream");
    res$setheader("Content-disposition", paste("attachment;filename=", objectname, ".bin", sep=""));
    res$finish();
  }
  
  httpget_object_csv <- function(object, objectname){
    mytmp <- tempfile();
    do.call(function(row.names=FALSE, eol="\r\n", na="", ...){
      write.csv(x=object, file=mytmp, row.names=as.logical(row.names), eol=eol, na=na, ...);
    }, req$get());
    res$setbody(file=mytmp);
    res$setheader("Content-Type", "text/csv");
    res$setheader("Content-disposition", paste("attachment;filename=", objectname, ".csv", sep=""));
    res$finish();
  } 
  
  httpget_object_tab <- function(object, objectname){
    mytmp <- tempfile();
    do.call(function(row.names=FALSE, eol="\r\n", na="", ...){
      write.table(x=object, file=mytmp, row.names=as.logical(row.names), eol=eol, na=na, ...);
    }, req$get());
    res$setbody(file=mytmp);
    res$setheader("Content-Type", 'text/plain; charset=utf-8');
    res$setheader("Content-disposition", paste("attachment;filename=", objectname, ".tab", sep=""));
    res$finish();
  }  
  
  httpget_object_file <- function(object){
    #this assumes "object" is actually a path to a file
    res$sendfile(object);
  }
  
  #note: switch to our own json encoder later.
  #this encoder has padding argument.
  #it also replaces /encode
  #and also converts arguments to numeric where needed.
  
  httpget_object_json <- function(object){
    jsonstring <- do.call(function(pretty=TRUE, ...){
      toJSON(x=object, pretty=pretty, ...);
    }, req$get());
    res$setbody(jsonstring);
    if(is.null(req$get()$padding)){
      res$setheader("Content-Type", "application/json");
    } else {
      res$setheader("Content-Type", "application/javascript");    
    }
    res$finish();
  }
  
  httpget_object_print <- function(object){
    outtext <- capture.output(do.call(printwithmax, c(req$get(), list(x=object))));
    res$sendtext(outtext);
  }
  
  httpget_object_pander <- function(object){
    outtext <- capture.output(do.call("pander", c(req$get(), list(x=object))));
    res$sendtext(outtext);
  }
    
  httpget_object_text <- function(object){
    object <- paste(unlist(object), collapse="\n")
    mytmp <- tempfile(fileext=".txt")
    do.call("cat", c(req$get(), list(x=object, file=mytmp)));
    res$sendfile(mytmp);
  }  
  
  httpget_object_ascii <- function(object){
    outtext <- deparse(object);
    res$sendtext(outtext);
  }    
  
  httpget_object_rda <- function(object, objectname){
    mytmp <- tempfile();
    myenv <- new.env();
    assign(objectname, object, myenv);  
    do.call("save", c(req$get(), list(object=objectname, file=mytmp, envir=myenv)));
    res$setbody(file=mytmp);
    res$setheader("Content-Type", "application/octet-stream");
    res$setheader("Content-disposition", paste("attachment;filename=", objectname, ".RData", sep=""));
    res$finish();
  }
  
  httpget_object_rds <- function(object, objectname){
    mytmp <- tempfile();
    do.call("saveRDS", c(req$get(), list(object=object, file=mytmp)));
    res$setbody(file=mytmp);
    res$setheader("Content-Type", "application/octet-stream");
    res$setheader("Content-disposition", paste("attachment;filename=", objectname, ".rds", sep=""));
    res$finish();
  }
  
  httpget_object_pb <- function(object, objectname){
    mytmp <- tempfile();
    do.call(RProtoBuf::serialize_pb, list(object=object, connection=mytmp));
    res$setbody(file=mytmp);
    res$setheader("Content-Type", "application/x-protobuf");
    res$setheader("Content-disposition", paste("attachment;filename=", objectname, ".pb", sep=""));
    res$finish();
  }  
  
  httpget_object_png <- function(object){
    if(is(object, "recordedplot")){
      object <- fixplot(object);
    }
    mytmp <- tempfile();
    do.call(function(width=800, height=600, pointsize=12, ...){
      png(type="cairo", file=mytmp, width=as.numeric(width), height=as.numeric(height), pointsize=as.numeric(pointsize), ...);  
    }, req$get()); 
    print(object);
    dev.off();
    if(!file.exists(mytmp)){
      stop("This call did not generate any plot. Make sure the function/object produces a graph.");	
    }    
    res$setbody(file=mytmp);
    res$setheader("Content-Type", "image/png");
    res$finish();    
  }
  
  httpget_object_pdf <- function(object, objectname){
    if(is(object, "recordedplot")){
      object <- fixplot(object);
    }
    mytmp <- tempfile();
    do.call(function(width=11.69, height=8.27, pointsize=12, paper="A4r", ...){
      pdf(file=mytmp, width=as.numeric(width), height=as.numeric(height), pointsize=as.numeric(pointsize), paper=paper, ...);
    }, req$get());
    print(object);
    dev.off();
    if(!file.exists(mytmp)){
      stop("This call did not generate any plot. Make sure the function/object produces a graph.");  
    }       
    res$setbody(file=mytmp);
    res$setheader("Content-Type", "application/pdf");
    res$setheader("Content-disposition", paste("attachment;filename=", objectname, ".pdf", sep=""));    
    res$finish();    
  }  
  
  httpget_object_svg <- function(object, objectname){
    if(is(object, "recordedplot")){
      object <- fixplot(object);
    }
    mytmp <- tempfile();
    do.call(function(width=11.69, height=8.27, pointsize=12, ...){
      svg(file=mytmp, width=as.numeric(width), height=as.numeric(height), pointsize=as.numeric(pointsize), ...);
    }, req$get());
    print(object);
    dev.off();
    if(!file.exists(mytmp)){
      stop("This call did not generate any plot. Make sure the function/object produces a graph.");  
    }        
    res$setbody(file=mytmp);
    res$setheader("Content-Type", "image/svg+xml");
    #res$setheader("Content-disposition", paste("attachment;filename=", objectname, ".svg", sep=""));      
    res$finish();    
  }    
  
  #export only main
  main
});