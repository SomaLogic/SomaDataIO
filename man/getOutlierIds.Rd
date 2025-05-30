% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getOutlierIds.R
\name{getOutlierIds}
\alias{getOutlierIds}
\title{Get Flagged Ids From MAD Outlier Map}
\usage{
getOutlierIds(x, flags = 0.05, data = NULL, include = NULL)
}
\arguments{
\item{x}{An object of class:
\itemize{
\item \code{outlier_map} - from \code{\link[=calcOutlierMap]{calcOutlierMap()}}
}}

\item{flags}{Numeric in \verb{[0, 1]}.
For an \code{"outlier_map"}, the proportion of the analytes (columns)
for a given sample that must be outliers for a flag to be placed at the right-axis,
right-axis, thus flagging that sample.
If \code{NULL} (default), \code{0.05} (5\%) is selected.}

\item{data}{Optional. The data originally used to create the map \code{x}. If
omitted, a single column data frame is returned.}

\item{include}{Optional. Character vector of column name(s) in \code{data} to
include in the resulting data frame. Ignored if \code{data = NULL}.}
}
\value{
A \code{data.frame} of the indices (\code{idx}) of flagged samples, along
with any additional variables as specified by \code{include}.
}
\description{
Return the IDs of flagged samples for objects of the \code{outlier_map} class.
Samples are flagged based on the percent analytes (RFU columns) for a given
sample that were identified as outliers using the median absolute
deviation (MAD).
}
\examples{
# flagged outliers
# create a single sample outlier (12)
out_adat <- example_data
apts     <- getAnalytes(out_adat)
out_adat[12, apts] <- out_adat[12, apts] * 10

om <- calcOutlierMap(out_adat)
getOutlierIds(om, out_adat, flags = 0.05, include = c("Sex", "Subarray"))
}
\seealso{
Other Calc Map: 
\code{\link{calcOutlierMap}()},
\code{\link{plot.Map}()}
}
\author{
Caleb Scheidel
}
\concept{Calc Map}
