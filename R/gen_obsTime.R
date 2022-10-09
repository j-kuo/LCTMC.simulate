#' @title Generate known observation times
#'
#' @description One key aspect of a CTMC process is that observations are made only between the exact transition times which are unknown. \cr
#' This function's purpose is to generate those observation times which are independent of the times when transition occurs.
#'
#' @param N.obs_times number of observation to be made
#' @param min_t the smallest possible time value an observation can be made
#' @param max_t the largest possible time value an observation can be made
#'
#' @return a numeric vector in ascending order which are the observation times for the CTMC process, with zero appended as the first element to indicate time of origin.
#'
#' @note this function essentially simulates uniform random variables and sorting them in ascending order.
#'
#' @example inst/examples/ex_gen_obsTime.R

gen_obsTime = function(N.obs_times, min_t, max_t){
  # generate random times
  obs_t = c(0, stats::runif(n = N.obs_times, min = min_t, max = max_t))

  # this is needed if `min_t` happens to be less than 0
  obs_t = obs_t - min(obs_t)

  # return
  obs_t[order(obs_t)]
}
