# This function is never called
# It only suprresses the "Namespaces in Imports field not imported from:" check
stub <- function(){
  devtools::install_github()
  brew::brew()
  httpuv::runServer()
  knitr::knit()
}