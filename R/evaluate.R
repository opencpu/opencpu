evaluate_input <- function(input, args = NULL, storeval = FALSE) {

  #setup handler
  error_object <- NULL
  myhandler <- evaluate::new_output_handler(value = function(myval, visible = TRUE){
    if(isTRUE(storeval) && is.null(error_object)){
      assign(".val", myval, sessionenv);
    }
    if(isTRUE(visible)){
      #note: print can be really, really slow
      if(identical(class(myval), "list")){
        cat("List of length ", length(myval), "\n")
        cat(paste("[", names(myval), "]", sep="", collapse="\n"))
      } else {
        getFromNamespace("render", "evaluate")(myval)
      }
    }
    invisible()
  }, error = function(e){
    error_object <<- e
  })

  #create session for output objects
  if(!length(args)){
    args <- new.env(parent = globalenv())
  } else {
    args <- as.environment(args)
    parent.env(args) <- globalenv()
  }

  #initiate environment
  sessionenv <- new.env(parent = args)
  res <- evaluate::evaluate(input = input, envir = sessionenv, stop_on_error = 1, output_handler = myhandler)

  # return both
  list (
    res = res,
    sessionenv = sessionenv,
    error = error_object
  )
}
