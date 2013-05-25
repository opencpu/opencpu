execute_file <- local({
  main <- function(filepath){
    res$checkfile(filepath);
    ext <- tolower(tail(strsplit(filepath, ".", fixed=TRUE)[[1]], 1));
    
    switch(ext,
      "r" = httppost_rscript(filepath),
      "rnw" = httppost_rnw(filepath),
      "rmd" = httppost_rmd(filepath),
      "brew" = httppost_brew(filepath),
      "pdr" = httppost_pander(filepath),
      "tex" = httppost_latex(filepath),     
      stop("Unsupported script type: ", ext)
    );
  }
  
  httppost_rscript <- function(filepath){
    mycon <- file(filepath);
    eval_session(mycon);
  } 
  
  httppost_rnw <- function(filepath){
    #explicit package so that we don't have to preload
    knitcall <- as.call(list(quote(tools::texi2pdf), as.call(list(quote(knitr::knit), filepath))));
    eval_session(knitcall);
  }
  
  httppost_rmd <- function(filepath){
    #explicit package so that we don't have to preload
    #knitcall <- as.call(list(quote(tools::texi2pdf), as.call(list(quote(knitr::knit), filepath))));
    knitcalls <- c(
      "library(knitr)",
      paste("mdfile <- knit('", filepath, "')", sep=""),
      "pandoc(mdfile, format='html')",
      "pandoc(mdfile, format='docx')",     
      "pandoc(mdfile, format='odt')"
    );
    knitcall <- paste(knitcalls, collapse="\n")
    eval_session(knitcall);
  }  
  
  httppost_brew <- function(filepath){
    brewcall <- as.call(list(quote(brew::brew), file=filepath));
    eval_session(brewcall);    
  }
  
  httppost_latex <- function(filepath){
    brewcall <- as.call(list(quote(tools::texi2pdf), file=filepath));
    eval_session(brewcall);      
  }

  main
});