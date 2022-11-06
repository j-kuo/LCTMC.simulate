#' @title Generates true model parameters
#'
#' @description Generates the true model parameters values for simulating synthetic data.
#'
#' @param K_class an integer scalar. The number of latent classes (currently only supports 3 class). \cr Default is 3
#' @param M_state an integer scalar. The number CTMC states (currently only supports 2 or 3 states). \cr Default is 2
#' @param pi.Z1,pi.Z2 a list object containing 3 elements for the multinomial logistic model: `alpha0`, `alpha1`, `alpha2`. \cr
#' `pi.Z1` will be used for class1's coefficient. `pi.Z2` for class2. And class3 is the referent. \cr
#' For example: `pi.Z1 = list(alpha0 = 0.7123, alpha1 = 0.8678, alpha2 = 1.1234)`
#' @param r0.Z1,r0.Z2,r0.Z3 a list object containing 2 elements for a two-state model, and 6 elements for a 3-state model. \cr
#' These parameters are used to specified the intercept terms of the transition rates (see sections below for the model formulation).
#' Each list object is assigned to the respective latent class.
#' For example: `r0.Z3 = list(q12 = 1.05, q21 = 1.10)`
#' @param beta.Z1,beta.Z2,beta.Z3 a list object containing 2 elements for a two-state model, and 6 elements for a 3-state model. \cr
#' These parameters are used to specified the coefficient terms of the transition rates (see sections below for the model formulation).
#' Each list object is assigned to the respective latent class. \cr
#' For example: `beta.Z1 = list(q12 = c(1.32, -0.29), q21 = c(-0.45, 0.65))`
#'
#' @return A nested list object containing three elements: `r0`, `beta`, and `pi`
#' \describe{
#'   \item{r0}{a nested list, one element for each \eqn{k} class, containing the `r0` component of the formula: \cr
#'         \deqn{
#'           q_{rs(k)} = r0_{rs(k)} \cdot exp(\beta_{rs(k)}X)
#'         }}
#'   \item{beta}{a nested list, one element for each \eqn{k} class, containing the `beta` component of the formula: \cr
#'         \deqn{
#'           q_{rs(k)} = r0_{rs(k)} \cdot exp(\beta_{rs(k)}X)
#'         }}
#'   \item{pi}{a nested list of \eqn{K-1} elements because the last class is the referent group. These parameters are the coefficients of the multinomial logistic model:
#'         \deqn{
#'           log(\frac{\pi_{(k)}}{\pi_{K}}) = \alpha_{(k)}W
#'         }}
#' }
#'
#' @export
#'
#' @note For the beta arguments, each element within the list is a numeric vector of length 2. This is because we allow the simulation to
#' take up to two covariates for the CTMC model. If these model parameter arguments are set to `NULL` then the function will internally supply some default values.
#'
#' @example inst/examples/ex_gen_true_param.R

gen_true_param = function(K_class = integer(),
                          M_state = integer(),
                          pi.Z1 = NULL,
                          pi.Z2 = NULL,
                          r0.Z1 = NULL,
                          r0.Z2 = NULL,
                          r0.Z3 = NULL,
                          beta.Z1 = NULL,
                          beta.Z2 = NULL,
                          beta.Z3 = NULL) {
  ## checks
  if (length(K_class) != 1 || length(M_state) != 1) {
    stop("`K_class` and `M_state` must be numeric length 1")
  }
  if (!(K_class %in% 3) || !(M_state %in% 2:3)) {
    stop("Current only support combinations of `K_class` = 3 & `M_state` = 2 or 3")
  }

  ## if unspecified, use default values (1) ~ pi
  if (is.null(pi.Z1)) {
    pi.Z1 = list(alpha0 = 0.30, alpha1 = -0.87, alpha2 = -1.15)
  }
  if (is.null(pi.Z2)) {
    pi.Z2 = list(alpha0 = 0.26, alpha1 = -1.11, alpha2 = -0.77)
  }

  ## if unspecified, use default values (2) ~ r0
  if (is.null(r0.Z1)) {
    if (M_state == 2) {
      r0.Z1 = list(q12 = 0.030, q21 = 0.183)
    }
    if (M_state == 3) {
      r0.Z1 = list(
        q12 = 0.0130, q13 = 0.0000,
        q21 = 0.1930, q23 = 0.0011,
        q31 = 0.0000, q32 = 0.0000
      )
    }
  }
  if (is.null(r0.Z2)) {
    if (M_state == 2) {
      r0.Z2 = list(q12 = 0.164, q21 = 0.035)
    }
    if (M_state == 3) {
      r0.Z2 = list(
        q12 = 0.1740, q13 = 0.0000,
        q21 = 0.0330, q23 = 0.0028,
        q31 = 0.0000, q32 = 0.0000
      )
    }
  }
  if (is.null(r0.Z3)) {
    if (M_state == 2) {
      r0.Z3 = list(q12 = 0.105, q21 = 0.110)
    }
    if (M_state == 3) {
      r0.Z3 = list(
        q12 = 0.0811, q13 = 0.0000,
        q21 = 0.1100, q23 = 0.0065,
        q31 = 0.0000, q32 = 0.0000
      )
    }
  }

  ## if unspecified, use default values (3) ~ beta
  if (is.null(beta.Z1)) {
    if (M_state == 2) {
      beta.Z1 = list(q12 = c(-1.32, 0.15), q21 = c(0.45, -0.33))
    }
    if (M_state == 3) {
      beta.Z1 = list(
        q12 = c(-0.85, 0.25), q13 = c(0.00, 0.00),
        q21 = c(-0.42, -0.30), q23 = c(-0.26, 0.25),
        q31 = c(0.00, 0.00), q32 = c(0.00, 0.00)
      )
    }
  }
  if (is.null(beta.Z2)) {
    if (M_state == 2) {
      beta.Z2 = list(q12 = c(-0.62, 0.35), q21 = c(0.16, -0.15))
    }
    if (M_state == 3) {
      beta.Z2 = list(
        q12 = c(-0.40, 0.47), q13 = c(0.00, 0.00),
        q21 = c(0.24, -0.22), q23 = c(0.31, -0.42),
        q31 = c(0.00, 0.00), q32 = c(0.00, 0.00)
      )
    }
  }
  if (is.null(beta.Z3)) {
    if (M_state == 2) {
      beta.Z3 = list(q12 = c(-0.19, -0.20), q21 = c(-0.55, 0.11))
    }
    if (M_state == 3) {
      beta.Z3 = list(
        q12 = c(0.26, -0.24), q13 = c(0.00, 0.00),
        q21 = c(-0.25, 0.16), q23 = c(0.17, -0.32),
        q31 = c(0.00, 0.00), q32 = c(0.00, 0.00)
      )
    }
  }

  ## tidy..
  pi = list(pi.Z1 = pi.Z1, pi.Z2 = pi.Z2)
  r0 = list(r0.Z1 = r0.Z1, r0.Z2 = r0.Z2, r0.Z3 = r0.Z3)
  beta = list(beta.Z1 = beta.Z1, beta.Z2 = beta.Z2, beta.Z3 = beta.Z3)

  ## return
  list(r0 = r0, beta = beta, pi = pi)
}
