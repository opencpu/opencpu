makelock <- function()({
  state = FALSE
  this <- environment();
  function(set){
    if(!missing(set)){
      state <<- set;
      lockEnvironment(this, bindings = TRUE)
    }
    state
  }
})


is_rapache <- makelock()
use_apparmor <- makelock()
