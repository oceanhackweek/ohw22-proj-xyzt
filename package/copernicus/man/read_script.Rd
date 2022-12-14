% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/script.R
\name{read_script}
\alias{read_script}
\title{Read shell script into a characater array}
\usage{
read_script(
  name = "global-analysis-forecast-phy-001-024",
  path = system.file("scripts", package = "copernicus")
)
}
\arguments{
\item{name}{character, the name of the script file}

\item{path}{character, the path to the script}
}
\value{
named character vector with 'app' and 'param'
}
\description{
Read shell script into a characater array
}
