% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/finalfit_coxph.R
\name{finalfit.coxph}
\alias{finalfit.coxph}
\title{Final output tables for common regression models}
\usage{
finalfit.coxph(.data, dependent, explanatory, explanatory_multi = NULL,
  random_effect = NULL, metrics = FALSE, add_dependent_label = TRUE,
  dependent_label_prefix = "Dependent: ", dependent_label_suffix = "", ...)
}
\arguments{
\item{.data}{Dataframe.}

\item{dependent}{Character vector of length 1:  quoted name of depdendent
variable. Can be continuous, a binary factor, or a survival object of form
\code{Surv(time, status)}}

\item{explanatory}{Character vector of any length: quoted name(s) of
explanatory variables.}

\item{explanatory_multi}{Character vector of any length: quoted name(s) of a
subset of explanatory variables for multivariable analysis only (must only
contain variables contained in \code{explanatory})}

\item{random_effect}{Character vector of length 1: quoted name of random
effects variable. When included mixed effects model generated
(\code{lme4::glmer lme4::lmer}).}

\item{metrics}{Logical: include useful model metrics in output in
publication format.}

\item{add_dependent_label}{Add the name of the dependent label to the top
left of table}

\item{dependent_label_prefix}{Add text before dependent label}

\item{dependent_label_suffix}{Add text after dependent label}

\item{...}{Other arguments to pass to \code{\link{fit2df}}: estimate_name,
p_name, digits, confint_sep}
}
\value{
Returns a dataframe with the final model table.
}
\description{
Internal function, not called directly. Method for \code{finalfit} generic.
}
\seealso{
Other \code{finalfit} all-in-one functions: \code{\link{finalfit.glm}},
  \code{\link{finalfit.lm}}, \code{\link{finalfit}}
}
\keyword{internal}
