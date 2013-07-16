loadsessioninfo <- function(filepath){
  
  #load data
  myinfo <- readRDS(filepath);
  
  #load base pkgs
  lapply(as.list(myinfo$basePkgs), require, character.only=TRUE);
  
  #load other pkgs
  lapply(as.list(names(myinfo$otherPkgs)), require, character.only=TRUE);  
}