#' @title Simulates a transition with exponentially distributed sojourn time
#'
#' @description Generates the process of state transitioning. This is done by following 2 steps: \cr
#' (1) generate the time at which transition actually occurs \cr
#' (2) generate which what state is transitioned to
#'
#' @param from_state the current state to transition out of
#' @param Q transition rate matrix obtained from `gen_Qmat()`
#' @param M_state number of CTMC states (currently only support 2 or 3 states)
#' @param sojourn.shape a numeric scalar > 0. This is the shape parameter for the gamma distribution. \cr
#' Set to 1 if exponential (i.e., CTMC) is desired.
#'
#' @return a list containing two elements
#' \enumerate{
#'   \item **t** a numeric scalar. The exponentially distributed sojourn time it took to transition out of `from_state`
#'   \item **to_state** a numeric scalar. This is the state which the random process transitioned to
#'   \item if something went wrong then NA values are returned
#' }
#'
#' @seealso [gen_Qmat()]
#'
#' @example inst/examples/ex_gen_transition.R

gen_transition = function(from_state, Q, M_state, sojourn.shape) {
  # set diagonal to 0 for convenience
  diag(Q) = 0

  # get transition rates
  q = Q[from_state, ]
  r = sum(q)

  # error catching, `r` here should always be greater than 0
  if (r > 0) {
    t = stats::rgamma(n = 1, shape = sojourn.shape, rate = r) # time to transition
    to_state = sample(1:M_state, size = 1, replace = TRUE, prob = q / sum(q)) # which state to jump to
  } else {
    t = NA
    to_state = NA
  }

  # return
  list(t = t, to_state = to_state)
}
