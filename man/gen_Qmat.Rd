% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gen_Qmat.R
\name{gen_Qmat}
\alias{gen_Qmat}
\title{Computes the Transition Rate Matrix, \eqn{Q}}
\usage{
gen_Qmat(r0, beta, x, z, M_state, K_class)
}
\arguments{
\item{r0}{a nested list obtained from \code{gen_true_param()}}

\item{beta}{a nested list obtained from \code{gen_true_param()}}

\item{x}{a numeric vector containing the covariates that affect the Q matrix}

\item{z}{an integer indicating the latent class to compute the Q matrix for}

\item{M_state}{number of CTMC states (currently only support 2 state or 3 state models)}

\item{K_class}{number of latent classes (currently only support 3 latent classes)}
}
\value{
a matrix object that satisfies the form of a infinitesimal transition rate matrix
}
\description{
\eqn{Q_{(k)}} is an \eqn{M \times M} matrix containing the transition rates from state \eqn{r} to state \eqn{s}.
Each transition rate has the form
\deqn{
  q_{rs(k)} = r0_{rs(k)} \cdot exp(\beta_{rs(k)} X)
}
Therefore, this function takes some given values for \code{r0}, \code{beta}, \code{x}, and latent variable \code{z} and computes the \eqn{Q} matrix.
User must specify \code{M} for number of states and \code{K} for number of latent classes
}
\examples{
\dontrun{
  # generate some CTMC parameters
  tp = gen_true_param(K_class = 3, M_state = 3)

  # use the given CTMC parameters to generate Q matrix
  x1 = 1
  x2 = 2
  x_covariate = c(1,2)
  gen_Qmat(
    r0 = tp$r0,
    beta = tp$beta,
    x = x_covariate,
    z = 1,
    M_state = 3,
    K_class = 3
  )
}
}
\seealso{
\code{\link[=gen_true_param]{gen_true_param()}}
}
