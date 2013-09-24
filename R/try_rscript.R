try_rscript <- function(cmd){
  tryCatch({
    cmd <- c(
      paste0("environment(.libPaths)$.lib.loc <- ", deparse(.libPaths(), 500), ";"),
      paste0("options(repos = ", deparse(getOption('repos'), 500), ");"),
      paste0("options(configure.vars = ", deparse(getOption('configure.vars'), 500), ");"),
      cmd
    );
    
    scriptfile <- tempfile();
    on.exit(unlink(scriptfile))
    writeLines(cmd, scriptfile);      
    output <- system2(file.path(R.home("bin"), "Rscript"), shQuote(scriptfile), stdout=TRUE, stderr=TRUE);
  }, error = function(e){
    stop("Command failed: ", cmd, ".\n\n", paste(output, collapse="\n"))
  });
}
