% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cleanNames.R
\name{cleanNames}
\alias{cleanNames}
\title{Clean Up Character String}
\usage{
cleanNames(x)
}
\arguments{
\item{x}{Character. String to clean up.}
}
\value{
A cleaned up character string.
}
\description{
Often the names, particularly within \code{soma_adat} objects,
are messy due to varying inputs, this function attempts to remedy this by
removing the following:
\itemize{
\item trailing/leading/internal whitespace
\item non-alphanumeric strings (except underscores)
\item duplicated internal dots (\code{..}), (\code{...}), etc.
\item SomaScan normalization scale factor format
}
}
\examples{
cleanNames("    sdkfj...sdlkfj.sdfii4994### ")

cleanNames("Hyb..Scale")
}
\seealso{
\code{\link[=trimws]{trimws()}}, \code{\link[=gsub]{gsub()}}, \code{\link[=sub]{sub()}}
}
\author{
Stu Field
}
