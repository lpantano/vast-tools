#!/usr/bin/env Rscript

# Author: Tim Sterne-Weiler, 2014
# tim.sterne.weiler@utoronto.ca

argv <- commandArgs(trailingOnly = F)
scriptPath <- dirname(sub("--file=","",argv[grep("--file",argv)]))

joinStr <- function(x,y) {
  return(paste(c(as.character(x), as.character(y)), collapse=""))
}

writeLines(joinStr("Using ", R.Version()$version.string));

# Source Rlib.
source(paste(c(scriptPath,"/R/Rlib/include.R"), collapse=""))

downloadDb <- function(speUrl, speFile) {
   if(system(joinStr("wget ", speUrl)) > 0) {
     stop(joinStr("Cannot download ", speUrl))
   }
   if(system(joinStr("tar xzvf ", speFile)) > 0) {
     stop(joinStr("Cannot tar xzvf ", speFile))
   }
   if(system(joinStr("rm ", speFile)) > 0) {
     stop(joinStr("Cannot rm ", speFile))
   }
}

humanDbFile <- "vastdb.hsa.7.3.14.tar.gz"
mouseDbFile <- "vastdb.mmu.7.3.14.tar.gz"

humanUrl <- joinStr("http://vastdb.crg.eu/libs/", humanDbFile)
mouseUrl <- joinStr("http://vastdb.crg.eu/libs/", mouseDbFile)
#

writeLines("Looking for VAST Database [VASTDB]")
if(!file.exists("VASTDB")) {
  writeLines("Cannot find 'VASTDB'.. Do you want me to download it for you? [y/n]")
  auto <- readLines(file("stdin"),1)
  close(file("stdin"))
  if(as.character(auto) == 'y') {
    writeLines("OK I will try... Please choose database [hg19/mm9/both] [h/m/b]")
    db <- readLines(file("stdin"),1)
    db <- as.character(db)
    close(file("stdin"))
    if(db == 'h' || db == 'b') {
      downloadDb(humanUrl, humanDbFile)
    }
    if(db == 'm' || db == 'b') {
      downloadDb(mouseUrl, mouseDbFile)
    }
  }
} else {
  writeLines("Found what appears to be VASTDB.. OK")
}

# custom install from include.R
loadPackages(c("getopt", "optparse", "RColorBrewer", "reshape2", "ggplot2", "grid", "parallel", "devtools"), local.lib=paste(c(scriptPath,"/R/Rlib"), collapse=""))

# install github packages
if (!require('psiplot', character.only=T)) {
  with_lib(new=paste(c(scriptPath,"/R/Rlib"), collapse=""), install_github('kcha/psiplot'))
  writeLines(sprintf("psiplot has been installed locally in R/Rlib!"), stderr())
}

if(Sys.chmod(paste(c(scriptPath, "/vast-tools"), collapse=""), mode = "755")) {
  writeLines("Setting vast-tools permissions... success!", stderr());
}

if(system("which bowtie") > 0) {
  stop("Cannot find 'bowtie' in path!!!  Please install this properly (e.x. /usr/bin/ ) or supply -bowtieProg flag to vast-tools!");
} else {
  writeLines("Found bowtie... Everything looks --OK");
}

q(status=0)
