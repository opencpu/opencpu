evaluate_input <- function(input, args = NULL, storeval = FALSE) {

  #setup handler
  error_object <- NULL
  cur_env <- rlang::current_env()
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
    if (isTRUE(config("error.backtrace"))) {
      e$trace <- rlang::trace_back(top=cur_env)
    }
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


  if(length(error_object) && length(error_object$call) && isTRUE(config("error.backtrace"))){
    error_object <- clean_trace(error_object)
  }

  # return both
  list (
    res = res,
    sessionenv = sessionenv,
    error = error_object
  )
}

clean_trace <- function(err){
  if (!is.null(err$trace)) {
    tr <- err$trace
    n <- nrow(tr)

    isErrorHandler <- vapply(tr$call,
                             function(x) identical(x[[1]], quote(.handleSimpleError)), logical(1))
    errorHandlerIndex <- min(c(length(isErrorHandler)+1, which(isErrorHandler)))

    isOverheadCall <- tr$namespace[seq_len(errorHandlerIndex - 1)] %in% c("evaluate", "opencpu") # only check before handler
    lastOverheadIndex <- max(c(0, which(isOverheadCall)))

    trIdx <- rlang::seq2(lastOverheadIndex + 1, errorHandlerIndex-1)

    err$trace <- rlang_trace_slice(tr, trIdx)
  }
  return(err)
}

# Copied from rlang:::trace_slice
rlang_trace_slice <- function (trace, i) {
  i <- vctrs::vec_as_location(i, nrow(trace))
  parent <- match(trace$parent, i, nomatch = 0)
  out <- vctrs::vec_slice(trace, i)
  out$parent <- parent[i]
  out
}

# Copied from evaluate:::render
evaluate_render <- function(x){
  if (isS4(x)) methods::show(x) else print(x)
}
