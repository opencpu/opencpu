#benchmarking stocks::listbyindustry()
library(evaluate)

test <- function(input){
  #setup evaluate
  sessionenv <- new.env()
  
  #setup handler
  myhandler <- evaluate::new_output_handler(value=function(myval, visible=TRUE){
    assign(".val", myval, sessionenv);
    if(isTRUE(visible)){
      #note: print can be really, really slow
      if(identical(class(myval), "list")){
        cat("List of length ", length(myval), "\n");
        cat(paste("[", names(myval), "]", sep="", collapse="\n"));
      } else {
         evaluate:::render(myval);
      }
    }
    invisible();
  });  
  
  output <- evaluate::evaluate(input=input, envir=sessionenv, stop_on_error=2, new_device=FALSE, output_handler=myhandler);
  mytmp <- tempfile()
  save(file=mytmp, envir=sessionenv, list=ls(sessionenv, all.names=TRUE));
  saveRDS(output, tempfile())
  saveRDS(sessionInfo(), tempfile())
  print(mytmp)
}

system.time(test("invisible(rnorm(1e7))"))


#benchmark in opencpu
detach("rapache")
rapache <- list(
  OK=200,
  GET=list(),
  POST=list(x="rnorm(1e7)"),
  FILES=list(),
  SERVER=list(
    internals=function(...){TRUE},
    HTTPS=TRUE,
    headers_in=list(HOST="localhost"),
    cmd_path="/ocpu",
    method="POST",
    path_info="/library/base/R/invisible"
  ),
  setStatus=function(...){},
  setHeader=function(...){},
  setContentType=function(...){},
  sendBin=function(x){cat(rawToChar(x))}
)

attach(rapache)
options(rapache=TRUE)
library(opencpu)
system.time(opencpu:::rapachehandler())

