#' @title Simulates a transition with exponentially distributed sojourn time
#'
#' @description Generates the process of state transitioning. This is done by following 2 steps: \cr
#' (1) generate the time at which transition actually occurs \cr
#' (2) generate which what state is transitioned to
#'
#' @param from_state the current state to transition out of
#' @param Q transition rate matrix obtained from `gen_Qmat(...)`
#' @param M_state number of CTMC states (currently only support 2 states or 3 states)
#'
#' @return a list contaiing two elements
#' \enumerate{
#'   \item **t** a numeric scalar. The exponentially distributed sojourn time it took to transition out of `from_state`
#'   \item **to_state** a numeric scalar. This is the state which the random process transitioned to
#' }
#'
#' @seealso [gen_Qmat()]
#'
#' @example inst/examples/ex_gen_transition.R

gen_transition = function(
    from_state, Q, M_state
){
  # set diagonal to 0 for convenience
  diag(Q) = 0

  # search for the correct "from" state
  for(m in 1:M_state){
    if(from_state == m){
      q = Q[m, ]
      r = sum(q)
      if(r > 0){
        t = stats::rexp(n = 1, rate = r)
        to_state = sample(1:M_state, size = 1, replace = TRUE, prob = q / sum(q))
      }else{
        t = NA
        to_state = NA
      }

    }
  }

  return(list(t = t, to_state = to_state))
}
