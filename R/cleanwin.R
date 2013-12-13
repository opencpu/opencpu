#On windows, orphaned procs never time out
#This function kills all Rscript procs.
#Use with care
cleanwin <- function(){
  if(identical(.Platform$OS.type, "windows")){
    suppressWarnings(try(system("taskkill /IM Rscript.exe /f", ignore.stdout=TRUE, ignore.stderr=TRUE, show.output.on.console=FALSE), silent=TRUE))
  }
}
