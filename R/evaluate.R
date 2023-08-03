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
        evaluate_render(myval)
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
  #sessionenv <- new.env(parent = args)
  sessionenv <- args
  if(is.call(input) && utils::packageVersion('evaluate') < "0.10.2"){
    input <- deparse(input)
    Encoding(input) = 'UTF-8'
  }
  res <- evaluate::evaluate(input = input, envir = sessionenv, stop_on_error = 1, output_handler = myhandler)

  if(length(error_object) && length(error_object$call)){
    error_object <- add_rlang_trace(error_object)
  }

  # return both
  list (
    res = res,
    sessionenv = sessionenv,
    error = error_object
  )
}

# Copied from evaluate:::render
evaluate_render <- function(x){
  if (isS4(x)) methods::show(x) else print(x)
}

add_rlang_trace <- function(error_object){
  err <- rlang::cnd_entrace(error_object)

  if (!is.null(err$trace)) {
    tr <- err$trace
    n <- nrow(tr)

    isErrorHandler <- vapply(tr$call,
                             function(x) identical(x[[1]], quote(.handleSimpleError)), logical(1))
    errorHandlerIndex <- min(c(length(isErrorHandler)+1, which(isErrorHandler)))

    isOverheadCall <- tr$namespace %in% c("evaluate", "opencpu")
    lastOverheadIndex <- max(c(0, which(isOverheadCall)))

    trIdx <- rlang::seq2(lastOverheadIndex + 1, errorHandlerIndex-1)

    err$trace <- rlang:::trace_slice(tr, trIdx)

  }
  return(err)
}
