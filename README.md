# opencpu

##### *A System for Embedded Scientific Computing and Reproducible Research with R*

[![Build Status](https://travis-ci.org/jeroenooms/opencpu.svg?branch=master)](https://travis-ci.org/jeroenooms/opencpu)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/jeroenooms/opencpu?branch=master&svg=true)](https://ci.appveyor.com/project/jeroenooms/opencpu)
[![Coverage Status](https://codecov.io/github/jeroenooms/opencpu/coverage.svg?branch=master)](https://codecov.io/github/jeroenooms/opencpu?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/opencpu)](http://cran.r-project.org/package=opencpu)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/opencpu)](http://cran.r-project.org/web/packages/opencpu/index.html)
[![Github Stars](https://img.shields.io/github/stars/jeroenooms/opencpu.svg?style=social&label=Github)](https://github.com/jeroenooms/opencpu)

> The OpenCPU system exposes an http API for embedded scientific
  computing with R. The server can run either as a single-user development
  server within the interactive R session, or as a multi-user linux stack
  based on rApache and NGINX. The current R package implements the core of
  the system. When loaded in R, it automatically initiates the single-user
  server and displays the web address in the console. The OpenCPU website 
  has more detailed API documentation.

## Documentation

 - Official [API documentation](https://www.opencpu.org/api.html)
 - Paper: [Towards a Universal Interface for Scientific Computing through Separation of Concerns](http://arxiv.org/abs/1406.4806) 
 - Example [apps](https://www.opencpu.org/apps.html)
 - JavaScript client: [opencpu.js](https://github.com/jeroenooms/opencpu.js)
 - Server manual: [PDF](http://jeroenooms.github.com/opencpu-manual/opencpu-server.pdf)

## Cloud Server

To install the cloud server in Ubuntu 14.04 or Ubuntu 16.04

```sh
#requires ubuntu 14.04 (Trusty) or 16.04 (Xenial)
sudo add-apt-repository -y ppa:opencpu/opencpu-1.5
sudo apt-get update 
sudo apt-get upgrade

#install opencpu server
sudo apt-get install -y opencpu

#optional
sudo apt-get install -y rstudio-server 
```

See the opencpu [website](https://www.opencpu.org/download.html) for details how to install on other platforms.

## Local Development server

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
