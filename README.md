# opencpu

> Producing and Reproducing Results

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/opencpu)](http://cran.r-project.org/package=opencpu)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/opencpu)](http://cran.r-project.org/web/packages/opencpu/index.html)

A system for embedded scientific computing and reproducible research with R.
The OpenCPU server exposes a simple but powerful HTTP api for RPC and data interchange
with R. This provides a reliable and scalable foundation for statistical services or 
building R web applications. The OpenCPU server runs either as a single-user development
server within the interactive R session, or as a multi-user Linux stack based on Apache2. 
The entire system is fully open source and permissively licensed. The OpenCPU website
has detailed documentation and example apps.

## Documentation

 - Official [API documentation](https://www.opencpu.org/api.html)
 - Paper: [Towards a Universal Interface for Scientific Computing through Separation of Concerns](http://arxiv.org/abs/1406.4806) 
 - Example [apps](https://www.opencpu.org/apps.html)
 - JavaScript client: [opencpu.js](https://github.com/opencpu/opencpu.js)
 - Server manual: [PDF](http://opencpu.github.io/server-manual/opencpu-server.pdf)

## Cloud Server

To install the cloud server on Ubuntu Server:

```sh
#requires Ubuntu 22.04 (Jammy) or 20.04 (Focal)
sudo add-apt-repository -y ppa:opencpu/opencpu-2.2
sudo apt-get update 
sudo apt-get upgrade

#install opencpu server
sudo apt-get install -y opencpu-server

#optional
sudo apt-get install -y rstudio-server 
```

See the opencpu [website](https://www.opencpu.org/download.html) for details how to install on other platforms.

## Local Development server

To start the single-user development server in R:

```r
library(opencpu)
ocpu_start_server()
```

Or to start an App:

```r
ocpu_start_app("rwebapps/stockapp")
```
