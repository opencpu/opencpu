evaluate_input <- function(input, args = NULL, storeval = FALSE) {

  #setup handler
  rlang:::poke_last_error(NULL) # reset all previous errors if any
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
  }, error = rlang::entrace)

  #create session for output objects
  if(!length(args)){
    args <- new.env(parent = globalenv())
  } else {
    args <- as.environment(args)
    parent.env(args) <- globalenv()
  }

  #initiate environment
  #sessionenv <- new.env(parent = args)
  sessionenv <- args
  if(is.call(input) && utils::packageVersion('evaluate') < "0.10.2"){
    input <- deparse(input)
    Encoding(input) = 'UTF-8'
  }
  res <- evaluate::evaluate(input = input, envir = sessionenv, stop_on_error = 1, output_handler = myhandler)

  error_object <- rlang:::peek_last_error()

  if (!is.null(error_object$trace)) {
    tr <- error_object$trace
    n <- nrow(tr)

    isErrorHandler <- vapply(tr$call,
                             function(x) identical(x[[1]], quote(.handleSimpleError)), logical(1))
    errorHandlerIndex <- min(c(length(isErrorHandler)+1, which(isErrorHandler)))

    isOverheadCall <- tr$namespace %in% c("evaluate", "opencpu")
    lastOverheadIndex <- max(c(0, which(isOverheadCall)))

    trIdx <- seq2(lastOverheadIndex + 1, errorHandlerIndex-1)

    error_object$trace <- rlang:::trace_slice(tr, trIdx)

  }


  # return both
  list (
    res = res,
    sessionenv = sessionenv,
    error = error_object
  )
}
