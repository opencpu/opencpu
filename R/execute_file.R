execute_file <- local({
  main <- function(filepath){
    res$checkfile(filepath);
    ext <- tolower(utils::tail(strsplit(filepath, ".", fixed=TRUE)[[1]], 1));

    switch(ext,
      "r" = httppost_rscript(filepath),
      "rnw" = httppost_knittex(filepath),
      "rtex" = httppost_knittex(filepath),
      "rmd" = httppost_knitpandoc(filepath),
      "rrst" = httppost_knitpandoc(filepath),
      "rhtml" = httppost_knit(filepath),
      "brew" = httppost_brew(filepath),
      "md" = httppost_pandoc(filepath),
      "rst" = httppost_pandoc(filepath),
      "tex" = httppost_latex(filepath),
      stop("Unsupported script type: ", ext)
    );
  }

  #Evaluate Rscript using evaluate
  httppost_rscript <- function(filepath){
    rcode <- readLines(filepath);
    session_eval(rcode);
  }

  #Standard knit
  httppost_knit <- function(filepath){
    #we are importing knitr now
    #library(knitr);

    knitcalls <- c(
      "stopifnot(require(knitr))",
      paste("knit(", deparse(filepath), ")", sep="")
    );

    knitcall <- paste(knitcalls, collapse="\n")
    session_eval(knitcall);
  }

  #Does both knitr and pdflatex
  httppost_knittex <- function(filepath){
    #we are importing knitr now
    #library(knitr);

    knitcalls <- c(
      "stopifnot(require(knitr))",
      "library(tools)",
      paste("texfile <- knit(", deparse(filepath), ")", sep=""),
      "texi2pdf(texfile)"
    );

    knitcall <- paste(knitcalls, collapse="\n")
    session_eval(knitcall);
  }

  #alternative: single call
  httppost_knittex2 <- function(filepath){
    #explicit package so that we don't have to preload
    knitcall <- as.call(list(quote(tools::texi2pdf), as.call(list(quote(knitr::knit), filepath))));
    session_eval(knitcall);
  }

  #Do both knit and pandoc
  httppost_knitpandoc <- function(filepath){
    #we are importing knitr now
    #library(knitr);

    args <- lapply(req$post(), parse_arg_prim);
    if(is.null(args$format)){
      args$format <- c("html", "docx", "odt")
    }

    knitcalls <- c(
      "stopifnot(require(knitr))",
      paste("mdfile <- knit(", deparse(filepath), ")", sep=""),
      paste("mapply(knitr::pandoc, input=mdfile, format =", deparse(args$format), ")"),
      "rm(mdfile)"
    );

    knitcall <- paste(knitcalls, collapse="\n")
    session_eval(knitcall, args);
  }

  #not used anymore. We use knitr instead.
  httppost_brew <- function(filepath){
    #we are importing brew now
    #library(brew);

    output <- parse_arg_prim(req$post()$output);
    if(is.null(output)){
      output <- quote(stdout())
    }

    brewcall <- as.call(list(quote(brew::brew), file=filepath, output=output));
    session_eval(brewcall);
  }

  #Compile a latex doc.
  #Need to copy the file otherwise latex writes files to orriginal location
  httppost_latex <- function(filepath){
    filename <- basename(filepath);

    knitcalls <- c(
      "stopifnot(require(knitr))",
      "library(tools)",
      paste("file.copy(", deparse(filepath), ",", deparse(filename), ")"),
      paste("texi2pdf(", deparse(filename), ", texinputs=", deparse(dirname(filepath)), ")")
    );

    knitcall <- paste(knitcalls, collapse="\n")
    session_eval(knitcall);
  }

  #note: by default, pandoc puts new files in same dir as old files
  httppost_pandoc <- function(filepath){
    #we are importing knitr now
    #library(knitr);
    filename <- basename(filepath);
    args <- lapply(req$post(), parse_arg_prim);
    if(is.null(args$format)){
      args$format <- c("html", "docx", "odt")
    }

    knitcalls <- c(
      "stopifnot(require(knitr))",
      paste("file.copy(", deparse(filepath), ",", deparse(filename), ")"),
      paste("mapply(pandoc, input=", deparse(filename), ", format =", deparse(args$format), ")")
    );

    knitcall <- paste(knitcalls, collapse="\n")
    session_eval(knitcall, args);
  }

  main
})
