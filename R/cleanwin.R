#On windows, orphaned procs never time out
#This function kills all Rscript procs.
#Use with care
cleanwin <- function(){
  if(identical(.Platform$OS.type, "windows")){
    try(system("taskkill /IM Rscript.exe /f", show.output.on.console=FALSE), silent=TRUE)
  }
}
