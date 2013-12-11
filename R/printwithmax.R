printwithmax <- function(..., max.print = getOption("max.print")){
  oldopt <- options(max.print=max.print);
  print(...);
  options(max.print=oldopt$max.print)
}