#' @title Constrains the model parameter values
#'
#' @description Forces the some of the model parameters to 0, namely the alpha coefficients and the beta coefficients. \cr
#' By setting those to zero, we essentially tells program to not include any covariate effects when performing the simulation.
#'
#' @param true_param a list object obtained from `gen_true_param(...)`
#' @param alpha.include a logical scalar. See documentation in `simulate_LCTMC(...)`
#' @param beta.include a logical scalar. See documentation in `simulate_LCTMC(...)`
#'
#' @return a list object similar in structure to in the input argument `true_param`. \cr
#' `true_param$pi` and `true_parma$beta` either remain the same or forced to 0 (depending on `alpha.include` and `beta.include`)
#'
#' @note for most use cases, this function will only be used within `simulate_LCTMC(...)`
#'
#' @seealso [gen_true_param()], [simulate_LCTMC()]
#'
#' @example inst/examples/ex_force0_true_param.R

force0_true_param = function(true_param, alpha.include, beta.include){
  ## should covariates be allowed to affect the latent class multinomial model (?)
  for(a.i in 1:length(true_param$pi)){
    for(a.j in 2:length(true_param$pi[[a.i]])){
      # `a.j` start a 2 because excluding intercept term
      true_param$pi[[a.i]][[a.j]] = true_param$pi[[a.i]][[a.j]] * (1*alpha.include)
      true_param$pi[[a.i]][[a.j]] = true_param$pi[[a.i]][[a.j]] * (1*alpha.include)
    }
  }

  ## should covariates be allowed to affect the CTMC rates (?)
  for(b.i in 1:length(true_param$beta)){
    for(b.j in 1:length(true_param$beta[[b.i]])){
      # `b.j` start at 1 because intercept is within `r0`
      true_param$beta[[b.i]][[b.j]] = true_param$beta[[b.i]][[b.j]] * (1*beta.include)
      true_param$beta[[b.i]][[b.j]] = true_param$beta[[b.i]][[b.j]] * (1*beta.include)
    }
  }

  return(true_param)
}
