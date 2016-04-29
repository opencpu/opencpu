tryCatch_capture_stack <- function(quoted_code, error) {
  capture_calls <- function(e) {
    # Capture call stack, removing last two calls from end (added by
    # withCallingHandlers), and first frame + 7 calls from start (added by
    # tryCatch etc)
    e$calls <- utils::head(sys.calls()[-seq_len(frame + 7)], -2)
    signalCondition(e)
  }
  frame <- sys.nframe()
  
  tryCatch(
    withCallingHandlers(eval(quoted_code), error = capture_calls),
    error = error
  )
}