execute_file <- local({
  main <- function(filepath){
    res$checkfile(filepath);
    ext <- tolower(tail(strsplit(filepath, ".", fixed=TRUE)[[1]], 1));
    
    switch(ext,
      "r" = httppost_rscript(filepath),
      "rnw" = httppost_knittex2(filepath),
      "rtex" = httppost_knittex2(filepath),           
      "rmd" = httppost_knitpandoc(filepath),
      "rrst" = httppost_knitpandoc(filepath),   
      "rhtml" = httppost_knit(filepath),
      "brew" = httppost_brew(filepath),
      "md" = httppost_pandoc(filepath),
      "rst" = httppost_pandoc(filepath),           
      "tex" = httppost_latex(filepath),  
      "pdr" = httppost_pander(filepath),
      stop("Unsupported script type: ", ext)
    );
  }
  
  #Evaluate Rscript using evaluate
  httppost_rscript <- function(filepath){
    mycon <- file(filepath);
    session$eval(mycon);
  } 
  
  #Standard knit
  httppost_knit <- function(filepath){
    #explicit package so that we don't have to preload
    library(knitr);
    
    knitcalls <- c(
      "library(knitr)",
      paste("knit('", filepath, "')", sep="")
    );
    
    knitcall <- paste(knitcalls, collapse="\n")
    session$eval(knitcall);
  }
  
  #Does both knitr and pdflatex
  httppost_knittex <- function(filepath){
    #explicit package so that we don't have to preload
    library(knitr);
    
    knitcalls <- c(
      "library(knitr)",
      "library(tools)",
      paste("texfile <- knit('", filepath, "')", sep=""),
      "texi2pdf(texfile)"
    );
    
    knitcall <- paste(knitcalls, collapse="\n")
    session$eval(knitcall);
  }    
  
  #alternative: single call
  httppost_knittex2 <- function(filepath){
    #explicit package so that we don't have to preload
    knitcall <- as.call(list(quote(tools::texi2pdf), as.call(list(quote(knitr::knit), filepath))));
    session$eval(knitcall);
  }
  
  #Do both knit and pandoc
  httppost_knitpandoc <- function(filepath){
    #explicit package so that we don't have to preload
    library(knitr);
    args <- lapply(req$post(), parse_arg_prim);
    if(is.null(args$format)){
      args$format <- c("html", "docx", "odt")
    }
    
    knitcalls <- c(
      "library(knitr)",
      paste("mdfile <- knit('", filepath, "')", sep=""),   
      paste("mapply(pandoc, input=mdfile, format =", deparse(args$format), ")"),
      "rm(mdfile)"
    );

    knitcall <- paste(knitcalls, collapse="\n")
    session$eval(knitcall, args);
  }  
  
  #not used anymore. We use knitr instead.
  httppost_brew <- function(filepath){
    library(brew);
    output <- parse_arg_prim(req$post()$output); 
    if(is.null(output)){
      output <- quote(stdout())
    }
    brewcall <- as.call(list(quote(brew::brew), file=filepath, output=output));
    session$eval(brewcall);    
  }
  
  #Compile a latex doc.
  #Need to copy the file otherwise latex writes files to orriginal location
  httppost_latex <- function(filepath){
    library(tools);
    filename <- basename(filepath);
    
    knitcalls <- c(
      "library(tools)",
      paste("file.copy(", deparse(filepath), ",", deparse(filename), ")"),
      paste("texi2pdf(", deparse(filename), ", texinputs=", deparse(dirname(filepath)), ")")
    );

    knitcall <- paste(knitcalls, collapse="\n")
    session$eval(knitcall);      
  }

  #note: by default, pandoc puts new files in same dir as old files
  httppost_pandoc <- function(filepath){
    library(knitr);
    filename <- basename(filepath);    
    args <- lapply(req$post(), parse_arg_prim);
    if(is.null(args$format)){
      args$format <- c("html", "docx", "odt")
    }
    
    knitcalls <- c(
      "library(knitr)",
      paste("file.copy(", deparse(filepath), ",", deparse(filename), ")"),
      paste("mapply(pandoc, input=", deparse(filename), ", format =", deparse(args$format), ")")
    );
    
    knitcall <- paste(knitcalls, collapse="\n")
    session$eval(knitcall, args);
  }  
  
  main
});