    library(tools)
    try(startDynamicHelp(TRUE), silent=TRUE);
    
    assign(
      "test", 
      function(reqpath, reqquery, reqbody, reqheaders){
        out <- paste(sep="\n",
                     "[path]", reqpath, "",
                     "[query]", paste("", names(reqquery), ":", reqquery, collapse="\n"), "",
                     "[body]", reqbody, "",
                     "[headers]",rawToChar(reqheaders), ""
        );
        
        list(
          "payload" = out,
          "content-type" = "text/plain",
          "headers" = "yippie: yay",
          "status code" = 201
        );
      }, 
      tools:::.httpd.handlers.env
    )
    
    browseURL(paste("http://localhost:", tools:::httpdPort, "/custom/test?foo=123&bar=456", sep=""))
