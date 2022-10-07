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
#' @param beta.incldue a logical scalar. If set to FALSE then the CTMC model will not have covariate effects
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
#' @importFrom dplyr case_when
#'
#' @export
#'
#' @note Once simulation is complete, use `convert_sim_data_2df(...)` to format the data into a "data.frame" object.
#'
#' @example inst/examples/ex_simulate_LCTMC.R

simulate_LCTMC = function(
    N.indiv = integer(),
    N.obs_times = integer(),
    max.obs_times = numeric(),
    fix.obs_times = logical(),
    true_param = list(),
    alpha.include = logical(),
    beta.incldue = logical(),
    K = integer(),
    M = integer(),
    p1 = integer(),
    p2 = integer(),
    initS_p = c(),
    death = integer()
){
  ## checks `true_param` list object
  if(length(true_param) !=3 || !all(c('r0', 'beta', "pi") %in% names(true_param))) stop("`true_param` should be a list object of 3 elements: 'r0' , 'beta' , 'pi'")

  ## check specifications: true_param$r0
  if(length(true_param$r0) != K) stop("`true_param$r0` must have length K, where each element is a list with M*(M-1) elements")
  if(length(unlist(true_param$r0)) != M*(M-1)*K) stop("`true_param$r0` should have a total of M*(M-1)*K parameters")
  ## check specifications: true_param$beta
  if(length(true_param$beta) != K) stop("`true_param$beta` must have length K, where each element is a list with M*(M-1)*p1 elements")
  if(length(unlist(true_param$beta)) != M*(M-1)*K*p1) stop("`true_param$beta` should have a total of M*(M-1)*p*K parameters")

  ## check specifications: intial state & latent class params
  if(length(initS_p) != M || sum(initS_p) != 1) stop("initS_p must be of length M and must sum to 1")
  if(length(true_param$pi) != (K-1)) stop("`true_param$pi` must be of have `K-1` components")
  if(length(unlist(true_param$pi)) != (p2+1)*(K-1)) stop("Number of alpha parameters do not match with specified `p2`")
  ## check specifications: other
  if(!is.logical(fix.obs_times) || length(fix.obs_times) != 1) stop("only supply the `fix.obs_times` parameter with either T/F, and it must be length '1'")
  if(!is.logical(beta.incldue) || length(beta.incldue) != 1) stop("only supply the `beta.incldue` parameter with either T/F, and it must be length '1'")

  ## check death state must be between 1 and M, and q_(death)(death) must equal 0
  if(is.null(death)){
    if(any(sapply(true_param$r0, function(x) any(sapply(0:(M-1), function(i) all(x[i*(M-1) + (1:(M-1))] == 0)))))) stop("when `death` is NULL, there should NOT be any absorbing states (i.e., `r0` should have some > 0 values for all states in 1 to `M`)")
  }else{
    if(!(death %in% 1:M)) stop("when `death` is not NULL, it must be an element of c(1, ..., `M`)")
    if(all(sapply(true_param$r0, function(x) any(x[(M-1)*(death-1) + 1:(M-1)] > 0)))) stop("when `death` is not NULL, `r0` for the `death` state should be all 0's")
  }

  ## generate individual level data frame (contains id, x1, ..., xp)
  IDlist = gen_IDlist()
  df_person = data.frame(
    # ID
    id = IDlist[1:N.indiv],
    intercept = 1,
    # transition rate covariates
    x1 = stats::rnorm(n = N.indiv, mean = 0.5, sd = 1.5),
    x2 = sample(x = 0:1, size = N.indiv, prob = c(0.40, 0.60), replace = TRUE),
    # latent class assignment covariates
    w1 = stats::rnorm(n = N.indiv, mean = 0.0, sd = 2.0),
    w2 = sample(x = 0:1, size = N.indiv, prob = c(0.55, 0.45), replace = TRUE)
  )

  ## alpha and beta (if they should be forced to zero, i.e., excluded or not), using `<<-` to modify `true_param` in global environment
  for(b.i in 1:length(true_param$beta)){
    for(b.j in 1:length(true_param$beta[[b.i]])){
      true_param$beta[[b.i]][[b.j]] = true_param$beta[[b.i]][[b.j]] * (1*beta.incldue) # `b.j` start at 1 because intercept is within `r0`
      true_param$beta[[b.i]][[b.j]] = true_param$beta[[b.i]][[b.j]] * (1*beta.incldue)
    }
  }
  for(a.i in 1:length(true_param$pi)){
    for(a.j in 2:length(true_param$pi[[a.i]])){
      true_param$pi[[a.i]][[a.j]] = true_param$pi[[a.i]][[a.j]] * (1*alpha.include) # `a.j` start a 2 because excluding intercept term
      true_param$pi[[a.i]][[a.j]] = true_param$pi[[a.i]][[a.j]] * (1*alpha.include)
    }
  }

  ## latent class probability
  a1 = unlist(true_param$pi$pi.Z1)
  a2 = unlist(true_param$pi$pi.Z2)
  e1 = exp(as.numeric(as.matrix(df_person[, c("intercept", 'w1', 'w2')]) %*% a1))
  e2 = exp(as.numeric(as.matrix(df_person[, c("intercept", 'w1', 'w2')]) %*% a2))
  p3 = 1 / (1 + e1 + e2)
  p2 = e2 * p3
  p1 = e1 * p3
  ## assign latent class
  r = stats::runif(n = N.indiv)
  df_person$p1 = p1
  df_person$p2 = p1+p2
  df_person$p3 = 1
  df_person$z = dplyr::case_when(r < df_person$p1 ~ 1, r < df_person$p2 ~ 2, TRUE ~ 3)
  ## generate each person's initial state
  initS = sample(1:M, size = N.indiv, prob = initS_p, replace = TRUE)
  ## if `death` is NULL, turn it into -99, so it will never be reached
  if(is.null(death)) death = -99

  ## simulation: each iteration is ONE person ... up to `N.indiv` persons
  sim_data = vector("list", length = N.indiv)
  names(sim_data) = IDlist[1:N.indiv]
  for(i in 1:N.indiv){
    # ID number
    id = df_person$id[i]
    # covariates
    xi1 = df_person$x1[i]
    xi2 = df_person$x2[i]
    wi1 = df_person$w1[i]
    wi2 = df_person$w2[i]
    xi = c(xi1, xi2)
    wi = c(wi1, wi2)
    # latent class
    zi = df_person$z[i]

    # space for true transition time and respective state
    transTime = c(0)
    state_at_transTime = c(initS[i])
    # space for Obs time and respective state
    state_at_obsTime = c()
    obsTime = gen_obsTime(N.obs_times = N.obs_times, min_t = 0, max_t = max.obs_times) # assume uniform random times
    if(fix.obs_times){obsTime = seq(0, max.obs_times, by = max.obs_times/N.obs_times)} # assume evenly spaced times

    # simulate true transition times
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

    # make observation at pre-determined times
    for(t in obsTime){
      temp = names((which(transTime <= t)))
      state_at_obsTime = c(state_at_obsTime, temp[length(temp)])
    }
    state_at_obsTime = as.numeric(state_at_obsTime)

    # if death is a state reached, cut all trailing observations
    if(death %in% state_at_obsTime){
      death_index = which(state_at_obsTime == death)
      # remove all trailing death states & correpsponding observe times
      obsTime = obsTime[-death_index]
      state_at_obsTime = state_at_obsTime[-death_index]
      # append true deaht time and death state to vector
      obsTime = c(obsTime, transTime[length(transTime)])
      state_at_obsTime = c(state_at_obsTime, death)
    }

    # append
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

  ## output
  list(
    sim_data = sim_data,
    true_param = true_param
  )
}
