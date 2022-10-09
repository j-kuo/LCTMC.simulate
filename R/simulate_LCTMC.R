#' @title Simulate a data from a latent CTMC model
#'
#' @description Given some underlying parameter values that dictate the latent class assignment process, the CTMC process, and observation times.
#' simulates a latent CTMC process and outputs the result to a list object.
#'
#' @param N.indiv an integer scalar indicating the number of individuals/study participants/subjects
#' @param N.obs_times an integer scalar indicating the number of observations per individual
#' @param max.obs_times a numeric scalar for the maximum possible value for observation time
#' @param fix.obs_times a logical scalar. If FALSE then uses ordered uniform random variables are created as the observation times.
#' If TRUE then make observation at set to be equal length intervals
#' @param true_param a list object holding the true model parameters to perform the simulation. This list object should contain 3 elements:
#' \itemize{
#'   \item **r0** this is the exponential of the intercept term for the transition rates \eqn{q_{rs}}
#'   \item **beta** this is the exponential of the coefficient terms for the transition rates \eqn{q_{rs}}
#'   \item **pi** this is the intercept & coefficient terms for the latent class model (multinomial logistic)
#' }
#' @param alpha.include a logical scalar. If set to FALSE then the latent class model will not have covariate effects
#' @param beta.include a logical scalar. If set to FALSE then the CTMC model will not have covariate effects
#' @param K an integer scalar indicating the number of latent classes (only supports K = 3L at the moment)
#' @param M an integer scalar indicating number of CTMC states (only supports M = 2L or M = 3L at the moment)
#' @param p1 an integer scalar. This is the number of covariates allowed to affect the transition rates (only supports p1 = 2L at the moment)
#' @param p2 an integer scalar. This is the  number of covariates allowed to affect the latent class componenent of the model (only supports p1 = 2L at the moment)
#' @param initS_p probability of initial states. \cr
#' For example, with `M = 3L` and `initS_p = c(1/2, 1/2, 0)`, then 50% of the individuals will start in state 1 of the CTMC process, and the other 50% will start in state 2.
#' @param death if death is a possible state, then use this argument to specify it. \cr
#' Death state is treated as an absorbing state. Observations will be truncated after death occurs. In addition, death occurrence is assumed to be known exactly. \cr
#'
#' @return a list object containing two sub list objects. The first is, `sim_data`, the simulated data where each element is one person.
#' Within each is a list containing the following elements:
#' \itemize{
#'   \item **obsTime**: a vector of numeric times when the observations are made
#'   \item **state_at_obsTime**: the CTMC state at the observation times
#'   \item **transTime**: the simulated exact time of transitions
#'   \item **state_at_transTime**: the CTMC state at the exact time of observation
#'   \item **xi**: a numeric vector for covariates that affects the transition rates (X)
#'   \item **wi**: a numeric vector for covariates that affects the latent multinomial model (W)
#'   \item **zi**: the randomly assigned latent class. It can only be integer values from 1 to `K`
#' }
#' The second item returns by this function is, `true_param`, a list object containing the true model parameter values used to simulate the data.
#' Note that this may not be equivalent to the input argument `true_param` depending on whether `alpha.include` and `beta.include` are set to TRUE or FALSE.
#'
#' @export
#'
#' @note Once simulation is complete, use `convert_sim_data_2df()` to format the data into a "data.frame" object.
#'
#' @seealso [gen_Qmat()], [gen_transition()], [gen_true_param()], [force0_true_param()]
#'
#' @example inst/examples/ex_simulate_LCTMC.R

simulate_LCTMC = function(
    N.indiv = integer(),
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
    death = integer()
){
  ### checks function specification
  check_f = match.call()
  check_f[[1]] = as.name("check_simulate_LCTMC")
  eval(check_f)

  ### generate data frame for covariates
  IDlist = gen_IDlist()
  df_person = data.frame(
    id = IDlist[1:N.indiv],

    intercept = 1,

    x1 = stats::rnorm(n = N.indiv, mean = 0.5, sd = 1.5),
    x2 = sample(x = 0:1, size = N.indiv, prob = c(0.40, 0.60), replace = TRUE),

    w1 = stats::rnorm(n = N.indiv, mean = 0.0, sd = 2.0),
    w2 = sample(x = 0:1, size = N.indiv, prob = c(0.55, 0.45), replace = TRUE)
  )

  ### alpha and beta (if they should be forced to 0 --> i.e., include or exclude covariate effects
  true_param = force0_true_param(
    true_param = true_param,
    alpha.include = alpha.include,
    beta.include = beta.include
  )

  ### latent class ~ computes probability
  a1 = unlist(true_param$pi$pi.Z1)
  a2 = unlist(true_param$pi$pi.Z2)
  e1 = exp(as.numeric(as.matrix(df_person[, c("intercept", 'w1', 'w2')]) %*% a1))
  e2 = exp(as.numeric(as.matrix(df_person[, c("intercept", 'w1', 'w2')]) %*% a2))
  z.p3 = 1 / (1 + e1 + e2)
  z.p2 = e2 * z.p3
  z.p1 = e1 * z.p3

  ### latent class ~ assign classes
  r = stats::runif(n = N.indiv)
  df_person$p1 = z.p1
  df_person$p2 = z.p1 + z.p2
  df_person$p3 = 1
  df_person$z = ifelse(r < df_person$p1, 1, ifelse(r < df_person$p2, 2, 3))

  ### CTMC specs ~ generate each person's initial state
  initS = sample(1:M, size = N.indiv, prob = initS_p, replace = TRUE)

  ### CTMC specs ~ absorbing state ---> if `death = NULL` then turn it into '-99' so it will never be reached
  if(is.null(death)) death = -99

  ### simulation ~ a list object holding the output data
  sim_data = vector("list", length = N.indiv)
  names(sim_data) = IDlist[1:N.indiv]

  ### simulation ~ for-loop for each person
  for(i in 1:N.indiv){
    ## known data ~ ID number
    id = df_person$id[i]

    ## known data ~  covariates
    xi1 = df_person$x1[i]
    xi2 = df_person$x2[i]
    wi1 = df_person$w1[i]
    wi2 = df_person$w2[i]
    xi = c(xi1, xi2)
    wi = c(wi1, wi2)

    ## unknown data ~ latent class
    zi = df_person$z[i]

    ## unknown data ~ vector of true transitions and respective event time
    transTime = c(0)
    state_at_transTime = c(initS[i])

    ## known data ~ vector of observed state & time of observation
    state_at_obsTime = c()
    if(fix.obs_times){
      obsTime = seq(0, max.obs_times, by = max.obs_times/N.obs_times) # fixed observation interval
    }else{
      obsTime = gen_obsTime(N.obs_times = N.obs_times, min_t = 0, max_t = max.obs_times) # random observation time
    }

    ## simulation ~ true transition times
    cond1 = max(transTime) < max.obs_times
    cond2 = state_at_transTime[length(state_at_transTime)] != death
    while(cond1 && cond2){
      # generate Q
      temp_Q = gen_Qmat(
        r0 = true_param$r0, beta = true_param$beta,
        z = zi, x = xi,
        M_state = M, K_class = K
      )
      # perform transition from current-state according to Q
      temp = gen_transition(from_state = state_at_transTime[length(state_at_transTime)], Q = temp_Q, M_state = M)
      # append result to time & state vector
      transTime = c(transTime, transTime[length(transTime)] + temp$t)
      state_at_transTime = c(state_at_transTime, temp$to_state)
      # update while-loop condition
      cond1 = max(transTime) < max.obs_times
      cond2 = state_at_transTime[length(state_at_transTime)] != death
    }
    names(transTime) = state_at_transTime

    ## simulation ~ make observation at predetermined times
    for(t in obsTime){
      temp = names((which(transTime <= t)))
      state_at_obsTime = c(state_at_obsTime, temp[length(temp)])
    }
    state_at_obsTime = as.numeric(state_at_obsTime)

    ## simulation ~ if death is a state reached, cut all trailing observations
    if(death %in% state_at_obsTime){
      death_index = which(state_at_obsTime == death)
      # remove all trailing death states & correpsponding observe times
      obsTime = obsTime[-death_index]
      state_at_obsTime = state_at_obsTime[-death_index]
      # append true deaht time and death state to vector
      obsTime = c(obsTime, transTime[length(transTime)])
      state_at_obsTime = c(state_at_obsTime, death)
    }

    ## append
    sim_data[[id]] = list(
      obsTime = as.numeric(obsTime),
      state_at_obsTime = as.numeric(state_at_obsTime),
      transTime = as.numeric(transTime),
      state_at_transTime = as.numeric(state_at_transTime),
      xi = as.numeric(xi),
      wi = as.numeric(wi),
      zi = as.numeric(zi)
    )
  }

  ### output
  list(sim_data = sim_data, true_param = true_param)
}
