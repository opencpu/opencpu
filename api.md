OpenCPU specification, revised
==============================

The root mount is relative. E.g. on rapache it is /ocpu/, on Rook it is /custom/ocpu/.

Top level interfaces
--------------------

/ocpu/pages                     Documentation
/ocpu/library/package           Packages from site library 
/ocpu/apps/package              Apps from site library
/ocpu/tmp/x3763c83              Temporary project
/ocpu/user/jeroen/lib/package   Packages from jeroen's home library
/ocpu/user/jeroen/apps/package  Apps from jeroen's home library
/ocpu/user/jeroen/proj/adv      Projects (~/foo/foo.Rproj) from jeroen's home.
/ocpu/user/jeroen/tmp           Alias for /tmp. Tmp projects.
/ocpu/gist/jeroen/123456        Scripts/docs from gist 
/ocpu/gist/123456               Idem
/ocpu/doc                       Mimics R help. 


Package / Apps sub-interfaces
-----------------------------

/NEWS                      ..
/DESCRIPTION               ..
/html/*                    GET mimics R help. 
/R/obj/format              Renders R objects. POST calls functions.
/man/obj/format            Renders dynamic manuals. GET only.
/www                       GET serves files. POST executes doc/script.
/doc                       GET mimics R help. POST executes doc/script.
/demo                      GET mimics R help. POST executes doc/script.

Project sub-interfaces
----------------------

/zip                      Exports project dir
/dpu                      DPU scripts dir
/R/value/json             Renders object. POST loads .Rdata and calls function.
/graphics/3/png           Renders plots from .Revaluation.
/report                   Renders basic report from .Revaluation.
/history                  Renders source history from .Revaluation.
/console                  Renders stdout from .Revaluation.
/conditions               Renders messages, warnings and errors from .Revaluation.
/files                    GET serves files. POST loads .RData and executes doc/script.


Directory (e.g. GIST) interfaces
--------------------------------

/R                        Calls function inside script in /R/. Uses devtools::load_all.
/dpu                      Executes the DPU script.
/*                        Executes scripts/docs in new project.


Methods and Arguments
---------------------

HTTP requests follow a two step procedure:

 1) POST: Calls function or executes doc/script. 
 2) GET:  Retrieves output. Mostly static files. Basic on-line rendering for /R and /graphics.

Dirlist is machine readable, uses index.html when available.
 
When the POST request included no output format, a successfull response will be HTTP 201 with location header. 
When the POST request did include an output format, a successfull response will be HTTP 303 (PRG) to simulate the one step DPU. 
 
=== POST Args:

Dynamic parameters: 
 * [tex/md/Rnw/Rmd] Pandoc/Latex parameters.
 * [Function call] Function arguments.
 * [script] Rscript [args]
 * [dpu] dpu arguments (x-www-form-urlencoded) and pipe stream (http request body)
 
Static parameters:
 * filename [brew] - main output filename
 * redirect: true/false - Redirect to output instead of index 
 * code [^/R$] - Custom R code.
 

=== GET Args:
 * Rendering parameters to be mapped to png(), pdf(), tojson(), print(), etc.
 

HTTP POST Output
----------------

Functions, docs and scripts are evaluated using the evaluate package. 
Outputs are stored in temporary project directory containing:

 *  any files written to the working dir during evaluation
 * .Rdata (serialized environment with objects stored by evaluate())
 * .Rhistory (text, extracted from evaluation)
 * .Revaluation (returned by evaluate)
 
See the project api above for how to continue. GET results are cacheable.


Data Processing Units
---------------------

Data processing units are shebang ascii scripts that can be called through the unix pipeline.
OpenCPU identifies shebang scripts by the .dpu file extension.
The POST body is piped to stdin, response body is stdout. Request and response have identical content-type.
DPU arguments are set using standard x-www-form-urlencoded.
When streaming text, client sets content-type: "text/plain". 
When streaming json, client sets content-type: "application/json". 
The DPU R package helps with running R based DPUs, similar to knit() or brew(). 

One way of implementing text dpu's is using brew.
The script itself has to specify somehow which content-type(s) it supports.
We could define some I/O schema, similar to protocol buffer definitions.
If the input and output types are the same type, we could use support map/reduce.

 
File Types
----------

The following files can be called using HTTP POST.
In the case of brew, this only affects the file extension.


File extension | Handler function         | Output 
---------------------------------------------------------------
 * none (fun)  | evaluate(args=POST)      | [all]
 * test.R      | evaluate(file(test.R"))  | [all] (render standard report with /report/pdf or /report/html)
 * file.Rnw    | knitr + texi2dvi         | [all] + file.tex + file.pdf
 * file.Rmd    | knitr + pandoc           | [all] + file.md + file_html
 * file.brew   | brew                     | [all] + file.txt (unless otherwise specified)
 * file.pbrew  | pander.pbrew + pandoc    | [all] + file.md + file_html
 * file.tex    | texi2dvi                 | file.pdf
 * file.md     | pandoc                   | file_html
 * file.dpu    | shell (shebang)          | console only 
 
Apps repository
---------------

Apps are R packages containing R functions (no src), demos, docs, and web pages that interface them.

By default, they are installed from the official opencpu repo using install.apps() 
Apps are installed to a separate library, i.e. ~/R/apps/myapplib/myapp/ and /usr/local/lib/opencpu/apps/myapplib/myapp/
Packages in the official OpenCPU repository contain LIBRARY files that point to user repositories and dependencies.
When apps are installed locally, LIBRARY files are not needed.

Apps and Dependency versioning
---------------------

Due to limited dependency versioning currently in R, the official repositories require you to specify the full lib.
The OpenCPU repository contains for every app, every version: [URL,LIBRARY,SHA]. One version is called 'latest'.
By default dependencies are taken from CRAN, but also github urls can be specified.
On install, create separate library for each packages. E.g. /usr/local/lib/opencpu/apps/myapplib/myapp/.
To be considered for the OpenCPU repository, the full dependency tree should be declared in LIBRARY. 

Reports
-------

* Execution of R functions or scripts results stores the .Revaluation file.
* The GET /report api converts the .Revaluation to a document using latex or pandoc.
* We could do this for knitr as well.

Documents
---------

Both R scripts/functions and tex/md files are special cases of knitr reports.

* POST example.Rmd or example.Rnw creates a new session with a new session which includes output files.
* By default output is generated for several formats. E.g. PDF, html, slidify, etc. 
* HTTP 303 redirects to the default output.  
* POST myfile.tex or myfile.md are simply special cases of myfiles.Rnw and myfile.Rmd. 
* Basic static GET is used to browse output.


Resources
---------

A resource is a container with files, scripts, functions, plots, data, etc.
There are at least 3 types of containers currently supported:

 * package (includes app-packages): R (objects/functions), manuals, files(www, docs, scripts)
 * session: temporary projects. Include R (objects/functions in .Rdata), plots (in .Rplots), files(www, docs, scripts).
 * gist: Either project (if .Rdata or .Rplots are available) or files(www, docs, scripts) only
 
 
Tmp session store
---------

The /tmp sessions hosts temporary projects. Any call to an R script or function results in a new project. 
Automatically generated project id's are only known to the client and should not be indexable.
Each project contains R objects (stored in .Rdata), plots (stored in .Rplots) 
The directory is browsable in order to support HTML output. 
The /R and /graphics subdirectories of a project are smarter interfaces to .Rdata and .Rplots


 
Protocol Buffers
----------------

Protocol buffers define a binary RPC based I/O stream. They are more formally defined than DPUs. 
They use "content-type" : "application/x-protobuf" and have the rpc in the path instead of a file.
We need to map protobuf RPC to R functions somehow.
OpenCPU makes all .proto files available when loading a package.

GET  /library/package/proto
POST /library/package/proto/[pb_package]/[pb_service]/[pb_rpc]


EXAMPLES
========





Stateless HTTP APIs
--------------------

Public library (if enabled): all packages available in a regular user session. 
Library preference order: home-apps, home-library, site-apps, site-library.
RApache OpenCPU does not have home libraries, and can be configured to only host apps, not packages.

 * /pub/mypackage/R
 * /pub/mypackage/www
 * /pub/mypackage/data
 * /pub/mypackage/doc
 * /pub/mypackage/man
 

Shared apps and scripts (if enabled, and public readable). Username is UNIX login
 * /user/jeroen/library/mypackage/R (interfaces ~/R/library/)
 * /user/jeroen/share/myproject (static host ~/R/share/)
 

Gist files 
 * /gist/username/gist_id/script.R
 * /gist/username/gist_id/document.Rnw
 * /gist/anonymous/gist_id/document.Rnw
 * /gist/gist_id/script.R (shorthand syntax)


Tmp sessions for serialized R objects. Uses smart default for output (png for graphics, summary for objects).  
 * /session/x9b37ca84b/R/object/ascii (workspace)
 * /session/x9b37ca84b/plots/1/png
 * /session/x9b37ca84b/something.csv (static file server outputs) 

 
Authenticated API's:
 * /home/mypackage (list, install or remove apps, packages or projects in home lib)
 
Function chaining
-----------------

For the stateless API, any function can be called with an argument x254178965 which refers to
the output object of a previous function call.
  

Files, scripts and documents
----------------------------
 * GET on scripts/files is simple fileservers. We use redirect where appropriate (avoid proxying)
 * POST on a script is sort of like hashbang, or dblclick. We try to "run" the script, however appropriate.
 * For R scripts and documents, the POST body can be piped to R stdin.

Run Code
--------

Calling /session allows for running code directly. The output is the same as calling anything else.

POST /session/new?code=rnorm(1)  HTTP 307 /session/x846bc834 (run code in new session)
POST /session/x846bc834?code=rnorm(1)  (run code in new session)
POST /session/x846bc834/somefile.tex
GET  /session/main/R/iris (ROOK/RSTUDIO ONLY)


Scripts
-------

A script is a function body without any parameters.
An exception is when the script contains a function main(). 
In that case, after running the scripts, the main() function is called with posted arguments.

GET  /pub/pfadata/scripts/ (static fileserver)
POST /pub/pfadata/scripts/somescript.R (runs script, store in /session)
GET  /gist/3239667/somescript.R (HTTP 301 redirect)
POST /gist/3239667/somescript.R (runs script)


Sweave/knitr
------------

GET  /pub/pfadata/docs/ (static fileserver)
POST /pub/pfadata/docs/somedoc.Rnw/ (runs knitr, save all)
POST /pub/pfadata/docs/somedoc.Rnw/pdf (runs knitr, pdflatex)
POST /pub/pfadata/docs/somedoc.Rnw/tex
POST /pub/pfadata/docs/somedoc.Rnw/tgz
POST /pub/pfadata/docs/somedoc.Rnw/zip
POST /pub/pfadata/docs/somedoc.Rnw/tmp (default, store all in tmp)

POST /gist/3239667/somedoc.Rnw (runs knitr, saves pdf)
POST /gist/3239667/somedoc.Rnw/tgz (compiles to pdf)

Markdown
--------

GET  /pub/pfadata/docs/ (static fileserver)
POST /pub/pfadata/docs/somedoc.Rmd (runs knitr, return markdown)
POST /pub/pfadata/docs/somedoc.Rmd/html
POST /pub/pfadata/docs/somedoc.Rmd/slidify (pandoc html slides)
POST /pub/pfadata/docs/somedoc.Rmd/tgz
POST /pub/pfadata/docs/somedoc.Rmd/zip
POST /pub/pfadata/docs/somedoc.Rmd/docx (pandoc word)
POST /pub/pfadata/docs/somedoc.Rmd/save (default, store all in tmp)

POST /gist/3239667/somedoc.Rnw (runs knitr, saves pdf)
POST /gist/3239667/somedoc.Rnw/tgz (compiles to pdf)


Brew (brew itself can return text, markdown or html) 
----

GET  /pub/pfadata/docs/ (static fileserver)
POST /pub/pfadata/docs/something.brew (runs Pandoc.brew, save all)
POST /pub/pfadata/docs/something.brew/html (Pandoc.brew, return html)
POST /pub/pfadata/docs/something.brew/docx (Pandoc.brew, return docx)
POST /pub/pfadata/docs/something.brew/tgz (Pandoc.brew, return tgz)
POST /gist/3239667/something.brew (runs knitr, saves pdf)
POST /gist/3239667/something.brew/tgz (compiles to pdf)

Non R stuff
-----------

POST /pub/pfadata/docs/something.tex (runs latex, output pdf)
POST /pub/pfadata/docs/something.tex (runs latex, oputput dvi)
POST /pub/pfadata/docs/something.md (runs pandoc)
POST /gist/3239667/something.tex (runs knitr, saves pdf)
POST /gist/3239667/something.md (pandoc)
