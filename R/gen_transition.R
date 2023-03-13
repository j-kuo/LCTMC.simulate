#' @title Simulates a transition with the specified sojourn time distribution
#'
#' @description Generates the process of state transitioning. This is done by following 2 steps: \cr
#' (1) generate the time at which transition actually occurs \cr
#' (2) generate which what state is transitioned to
#'
#' @param from_state the current state to transition out of
#' @param Q transition rate matrix obtained from `gen_Qmat()`
#' @param M_state number of states (currently only support 2 or 3 states)
#' @param sojourn a list containing `dist` as an element specifying the distribution.
#' Other arguments for the specified distribution should also be included:
#' \itemize{
#'   \item if `dist` is "gamma" then, `gamma.shape`, a numeric scalar > 0 is also needed (shape = 1 is the exponential distribution).
#'   \item if `dist` is "lnorm" then, `lnorm.sdlog`, a numeric scalar > 0 is also needed.
#' }
#'
#' @return a list containing two elements
#' \enumerate{
#'   \item **t** a numeric scalar. The sojourn time it took to transition out of `from_state`.
#'   \item **to_state** a numeric scalar. This is the state which the random process transitioned to.
#'   \item if something went wrong then NA values are returned.
#' }
#'
#' @seealso [gen_Qmat()]
#'
#' @example inst/examples/ex_gen_transition.R

gen_transition = function(from_state, Q, M_state, sojourn) {
  # set diagonal to 0 for convenience
  diag(Q) = 0

  # get transition rates
  q = Q[from_state, ]
  r = sum(q)

  # error catching, `r` here should always be greater than 0
  if (r > 0) {
    if (sojourn$dist == "gamma") {
      t = stats::rgamma(n = 1, shape = sojourn$gamma.shape, rate = r)
      to_state = sample(1:M_state, size = 1, replace = TRUE, prob = q / r)
    } else if (sojourn$dist == "lnorm") {
      t = stats::rlnorm(n = 1, meanlog = log(1/r) - (sojourn$lnorm.sdlog^2)/2, sdlog = sojourn$lnorm.sdlog)
      to_state = sample(1:M_state, size = 1, replace = TRUE, prob = q / r)
    }

  } else {
    t = NA
    to_state = NA
  }

  # return
  list(t = t, to_state = to_state)
}
