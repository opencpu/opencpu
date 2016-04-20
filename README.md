# opencpu

##### *A System for Embedded Scientific Computing and Reproducible Research with R*

[![Build Status](https://travis-ci.org/jeroenooms/opencpu.svg?branch=master)](https://travis-ci.org/jeroenooms/opencpu)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/jeroenooms/opencpu?branch=master&svg=true)](https://ci.appveyor.com/project/jeroenooms/opencpu)
[![Coverage Status](https://codecov.io/github/jeroenooms/opencpu/coverage.svg?branch=master)](https://codecov.io/github/jeroenooms/opencpu?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/opencpu)](http://cran.r-project.org/package=opencpu)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/opencpu)](http://cran.r-project.org/web/packages/opencpu/index.html)
[![Github Stars](https://img.shields.io/github/stars/jeroenooms/opencpu.svg?style=social&label=Github)](https://github.com/jeroenooms/opencpu)

> The OpenCPU system exposes an HTTP API for embedded scientific
  computing with R. This provides scalable foundations for integrating R
  based analysis and visualization modules into pipelines, web applications
  or big data infrastructures. The OpenCPU server can run either as a
  single-user development server within the interactive R session, or as a
  high performance multi-user cloud server that builds on Linux, Nginx and
  rApache. The current R package forms the core of the system. When loaded
  in R, it automatically initiates the single-user server and displays the
  web address in the console. Visit the OpenCPU website for detailed
  information and documentation on the API.

## Documentation

 - OpenCPU [API documentation](https://www.opencpu.org/api.html)
 - Paper: [The OpenCPU System: Towards a Universal Interface for Scientific Computing through Separation of Concerns](http://arxiv.org/abs/1406.4806) 
 - Example [apps](https://www.opencpu.org/apps.html)
 - JavaScript client: [opencpu.js](https://github.com/jeroenooms/opencpu.js)
 - [Server manual PDF](http://jeroenooms.github.com/opencpu-manual/opencpu-server.pdf)

## Quick Start

The single-user development server will automatically start when the package is loaded in R:

```r
> library(opencpu)
Initiating OpenCPU server...
Using config: /Users/jeroen/.opencpu.conf
OpenCPU started.
[httpuv] http://localhost:7722/ocpu
OpenCPU single-user server ready.
```

Use `opencpu$browse()` to open the testing page in a browser.
