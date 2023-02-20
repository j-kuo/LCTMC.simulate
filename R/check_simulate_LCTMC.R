#' @title Checks `simulate_LCTMC()` specification
#'
#' @description Takes the exact same arguments as [simulate_LCTMC()] and checks if there any issues with specifications.
#'
#' @param N.indiv See documentation for `simulate_LCTMC()`
#' @param N.obs_times See documentation for `simulate_LCTMC()`
#' @param max.obs_times See documentation for `simulate_LCTMC()`
#' @param fix.obs_times See documentation for `simulate_LCTMC()`
#' @param true_param See documentation for `simulate_LCTMC()`
#' @param alpha.include See documentation for `simulate_LCTMC()`
#' @param beta.include See documentation for `simulate_LCTMC()`
#' @param K See documentation for `simulate_LCTMC()`
#' @param M See documentation for `simulate_LCTMC()`
#' @param p1 See documentation for `simulate_LCTMC()`
#' @param p2 See documentation for `simulate_LCTMC()`
#' @param initS_p See documentation for `simulate_LCTMC()`
#' @param death See documentation for `simulate_LCTMC()`
#' @param sojourn.shape See documentation for `simulate_LCTMC()`
#'
#' @return if checks passes without issue then function returns NULL
#'
#' @seealso [simulate_LCTMC()]

check_simulate_LCTMC = function(N.indiv = integer(),
                                N.obs_times = integer(),
                                max.obs_times = numeric(),
                                fix.obs_times = logical(),
                                true_param = list(),
                                alpha.include = logical(),
                                beta.include = logical(),
                                K = integer(),
                                M = integer(),
                                p1 = integer(),
                                p2 = integer(),
                                initS_p = c(),
                                death = integer(),
                                sojourn.shape = numeric()) {
  ## checks `true_param` list object
  if (length(true_param) != 3 || !all(c('r0', 'beta', "pi") %in% names(true_param))) {
    stop("`true_param` should be a list object of 3 elements: 'r0' , 'beta' , 'pi'")
  }

  ## check specifications: true_param$r0
  if (length(true_param$r0) != K) {
    stop("`true_param$r0` must have length K, where each element is a list with M*(M-1) elements")
  }
  if (length(unlist(true_param$r0)) != (M*(M-1)*K)) {
    stop("`true_param$r0` should have a total of M*(M-1)*K parameters")
  }

  ## check specifications: true_param$beta
  if (length(true_param$beta) != K) {
    stop("`true_param$beta` must have length K, where each element is a list with M*(M-1)*p1 elements")
  }
  if (length(unlist(true_param$beta)) != (M*(M-1)*K*p1)) {
    stop("`true_param$beta` should have a total of M*(M-1)*p*K parameters")
  }

  ## check specifications: intial state & latent class params
  if (length(initS_p) != M || sum(initS_p) != 1) {
    stop("initS_p must be of length M and must sum to 1")
  }
  if (length(true_param$pi) != (K-1)) {
    stop("`true_param$pi` must be of have `K-1` components")
  }
  if (length(unlist(true_param$pi)) != (p2+1)*(K-1)) {
    stop("Number of alpha parameters do not match with specified `p2`")
  }

  ## check specifications: other
  if (!is.logical(fix.obs_times) || length(fix.obs_times) != 1) {
    stop("only supply the `fix.obs_times` parameter with either T/F, and it must be length '1'")
  }
  if (!is.logical(beta.include) || length(beta.include) != 1) {
    stop("only supply the `beta.include` parameter with either T/F, and it must be length '1'")
  }

  ## check `death` when it is NULL ~ cannot have any `true_param$r0` set to 0
  if (is.null(death)) {
    temp1 = NULL
    for (x in true_param$r0) {
      temp2 = NULL
      for (i in 0:(M-1)) {
        temp2 = c(temp2, all(x[i*(M-1) + (1:(M-1))] == 0))
      }
      temp1 = c(temp1, any(temp2))
    }
    if (any(temp1)) {
      stop("`true_param$r0` should be > 0 for all states (1, ..., M), when `death` is NULL")
    }
  }

  ## check `death` when it is not NULL ~
  if (!is.null(death)) {
    # must be a whole number from between 1 to M
    if (!(death %in% 1:M)) {
      stop("when `death` is not NULL, it must be an integer between 1 to M")
    }

    # cannot have `true_param$r0` set to non-zero value
    temp2 = NULL
    for (x in true_param$r0) {
      temp2 = c(temp2, any(x[(M-1)*(death-1) + 1:(M-1)] > 0))
    }
    if (all(temp2)) {
      stop("when `death` is not NULL, `true_param$r0` for the `death` state should be all 0's")
    }
  }

  ## check shape parameter, must be > 0
  if (sojourn.shape <= 0) {
    stop("`sojourn.shape` must be strictly greater than 0")
  }
}
