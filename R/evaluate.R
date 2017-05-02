evaluate_input <- function(input, args = NULL, storeval = FALSE) {

  #setup handler
  myhandler <- evaluate::new_output_handler(value = function(myval, visible = TRUE){
    if(isTRUE(storeval)){
      assign(".val", myval, sessionenv);
    }
    if(isTRUE(visible)){
      #note: print can be really, really slow
      if(identical(class(myval), "list")){
        cat("List of length ", length(myval), "\n");
        cat(paste("[", names(myval), "]", sep="", collapse="\n"));
      } else {
        from("evaluate", "render")(myval);
      }
    }
    invisible()
  });

  #create session for output objects
  if(!length(args)){
    args <- new.env(parent = globalenv())
  } else {
    args <- as.environment(args)
    parent.env(args) <- globalenv()
  }

  #initiate environment
  sessionenv <- new.env(parent = args)
  res <- evaluate::evaluate(input = input, envir = sessionenv, stop_on_error = 2, output_handler = myhandler)

  # return both
  list (
    res = res,
    sessionenv = sessionenv
  )
}
