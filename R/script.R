run_rscript <- function(cmd, stop_on_error = TRUE){
  # Some weird bug when methods is not attached
  eval(call("library", "methods"))

  # add pre commands
  full_script <- c(
    paste0("environment(.libPaths)$.lib.loc <- ", deparse(.libPaths(), 500), ";"),
    paste0("options(repos = ", deparse(getOption('repos'), 500), ");"),
    paste0("options(configure.vars = ", deparse(getOption('configure.vars'), 500), ");"),
    paste0("options(rapache = ", deparse(getOption('rapache')), ");"),
    cmd
  )

  # create the R script
  scriptfile <- tempfile()
  on.exit(unlink(scriptfile))
  writeLines(full_script, scriptfile)
  rscript <- file.path(R.home("bin"), "Rscript")

  # run the system command
  buf <- rawConnection(raw(0), "r+")
  on.exit(close(buf), add = TRUE)
  status <- sys::exec_wait(rscript, scriptfile, std_out = buf, std_err = buf)
  output <- rawToChar(rawConnectionValue(buf))
  if(stop_on_error && status > 0){
    prettycmd <- paste(c("", cmd), collapse = "\n  ")
    stop(sprintf("Rscript failed: %sIn R script: %s\n", output, prettycmd))
  }
  structure(output, status = status)
}
