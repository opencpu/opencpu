rapache <- local({
  state <- FALSE;
  function(enable = FALSE){
    if(isTRUE(enable)){
      state <<- TRUE
    }
    state
  }
})

apparmor <- local({
  state <- FALSE;
  function(enable = FALSE){
    if(isTRUE(enable)){
      state <<- TRUE
    }
    state
  }
})
