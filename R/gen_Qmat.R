#' @title Computes the Transition Rate Matrix, \eqn{Q}
#'
#' @description \eqn{Q_{(k)}} is an \eqn{M \times M} matrix containing the transition rates from state \eqn{r} to state \eqn{s}.
#' Each transition rate has the form
#' \deqn{
#'   q_{rs(k)} = r0_{rs(k)} \cdot exp(\beta_{rs(k)} X)
#' }
#' Therefore, this function takes some given values for `r0`, `beta`, `x`, and latent variable `z` and computes the \eqn{Q} matrix.
#' User must specify `M` for number of states and `K` for number of latent classes
#'
#' @param r0 a nested list obtained from `gen_true_param()`
#' @param beta a nested list obtained from `gen_true_param()`
#' @param x a numeric vector containing the covariates that affect the Q matrix
#' @param z an integer indicating the latent class to compute the Q matrix for
#' @param M_state number of CTMC states (currently only support 2 state or 3 state models)
#' @param K_class number of latent classes (currently only support 3 latent classes)
#'
#' @return a matrix object that satisfies the form of a infinitesimal transition rate matrix
#'
#' @seealso [gen_true_param()]
#'
#' @example inst/examples/ex_gen_Qmat.R

gen_Qmat = function(
    r0, beta, x, z,
    M_state, K_class
){
  # allocate space
  Q = matrix(0, nrow = M_state, ncol = M_state)

  # search for the correct class `k`, from state `i`, to state `j`
  for(k in 1:K_class){ # (this k-for-loop is redundant but helps with parameter specification at catching potential error)
    if(z == k){
      # once k is found, compute q_rsk through a double loop
      for(i in 1:M_state){
        for(j in 1:M_state){
          if(i != j){
            qij = paste("q", i, j, sep = "")
            baseline = r0[[z]][[qij]] # "r0" in r0*exp(b'*X)
            b = beta[[z]][[qij]] # "b" in r0*exp(b'*X)
            x = x
            Q[i,j] = baseline * exp(as.numeric(b%*%x))
          }
        }
      }
    }
  }

  # set diagonal as q_rr = -sum(q_rs); r != s
  diag(Q) = -rowSums(Q)

  return(Q)
}



