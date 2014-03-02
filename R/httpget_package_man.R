httpget_package_man <- local({
  main <- function(pkgpath, requri){
    #only GET allowed
    res$checkmethod("GET")
    
    #extract names
    reqpackage <- basename(pkgpath);
    reqlib <- dirname(pkgpath);  
    reqobject <- requri[1];
    reqformat <- requri[2];
    
    #show a list of objects
    if(is.na(reqobject)){
      res$checktrail();
      manlist <- names(from("tools", "fetchRdDB")(file.path(pkgpath, "help", reqpackage)))
      res$sendlist(manlist);
    }
    
    #get the help file
    rdfile <- getrd(topic=reqobject, package=reqpackage,lib.loc=reqlib);
    
    #default format is text
    if(is.na(reqformat)){
      res$redirectpath("/text")
      reqformat <- "text";
    }
    
    #output
    switch(reqformat,
       "html" = man_html(rdfile, package=reqpackage, pkgpath=pkgpath),
       "text" = man_text(rdfile, package=reqpackage),
       "tex" = man_tex(rdfile),
       "pdf" = man_pdf(topic=reqobject, package=reqpackage,lib.loc=reqlib),
       "R.css" = res$sendfile(system.file("test/R.css", package=packagename)),
       stop("Unknown man format: /", reqformat)
    )
  }
  
  getrd <- function(topic, package, lib.loc){
    #read the help file
    helppath <- eval(call('help', topic, package=package, lib.loc=lib.loc, help_type="text"));
    if(!length(helppath)){
      stop(capture.output(print(helppath)));
    }
    from("utils", ".getHelpFile")(helppath);
  }
  
  man_html <- function(rdfile, package, pkgpath){
    #mylinks <- tools::findHTMLlinks(pkgpath);
    #mylinks <- sub("../../", "../../../", mylinks, fixed=TRUE);
    #mylinks <- sub("/html/", "/man/", mylinks, fixed=TRUE);
    #mylinks <- sub(".html$", "/html", mylinks);
    #tools::Rd2HTML(rdfile, out=mytmp, package=package, Links=mylinks, stylesheet="R.css");
    mytmp <- tempfile(fileext=".html");
    Rd2HTML(rdfile, out=mytmp, package=package, stylesheet="R.css");
    res$sendfile(mytmp); 
  }
  
  man_tex <- function(rdfile){
    mytmp <- tempfile(fileext=".txt"); #.tex results in weird content-type
    tools::Rd2latex(rdfile, out=mytmp, outputEncoding="UTF-8");
    res$sendfile(mytmp);
  }
  
  man_text <- function(rdfile, package){
    mytmp <- tempfile(fileext=".txt")
    tools::Rd2txt(rdfile, out=mytmp, package=package, outputEncoding="UTF-8", options=list(underline_titles=FALSE, code_quote=FALSE));
    res$sendfile(mytmp);
  }
  
  #Note: R needs a whole bunch of latex dependencies to compile PDF files.
  #texlive-base texlive-latex-base texlive-generic-recommended
  #texinfo texinfo-doc-nonfree
  #texlive-latex-recommended texlive-latex-extra 
  #texlive-fonts-extra texlive-fonts-recommended
  man_pdf <- function(topic, package, lib.loc){
    print(eval(call('help', topic=topic, package=package, lib.loc=lib.loc, help_type="pdf")));
    pdffile <- file.path(getwd(), paste(topic, ".pdf", sep=""));
    if(!file.exists(pdffile)){
      stop("PDF file was not created. Make sure Latex is set up correctly.")
    }
    res$setbody(file=pdffile);
    res$setheader("Content-Type", "application/pdf");
    res$setheader("Content-Disposition", paste('attachment; filename="', topic, '.pdf"', sep=""));
    res$finish();
  }  
  
  return(main);
});
