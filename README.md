OpenCPU
=======

[![Build Status](https://travis-ci.org/jeroenooms/opencpu.png?branch=master)](https://travis-ci.org/jeroenooms/opencpu)

The OpenCPU framework exposes a web API interfacing R, Latex and Pandoc. This API is used for example to integrate statistical functionality into systems, share and execute scripts or reports on centralized servers, and build R based "apps". The OpenCPU server can run either as a single-user server inside the interactive R session (using httpuv), or as a cloud server that builds on Linux and rApache. The current R package forms the core of the framework. When loaded in R, it automatically initiates the single-user server and displays the web address in the console. For more information, visit the [OpenCPU website](http://www.opencpu.org).

Install Single User Server
--------------------------

Latest stable version (recommended):

    install.packages('opencpu')
    library(opencpu)

Bleeding edge from rforge:
  
    #update existing packages first
    update.packages(ask = FALSE, repos = 'http://cran.rstudio.org')
    install.packages('opencpu', repos = c('http://rforge.net', 'http://cran.rstudio.org'),
      type = 'source')
      

