#' @title Data tidying for the simulation output
#'
#' @description Converts the output of [simulate_LCTMC()] to a "data.frame" object
#'
#' @param my_list a list object obtained from the `simulate_LCTMC()` function
#' @param type a character scalar of either "obs", "exact", or "both"
#'
#' @return if `type = "both"` then a a list object with **2** elements is returned:
#' \enumerate{
#'   \item **obs** this data contains the disease status at some pre-defined observed times. This essentially means that all outcomes are interval-censored.
#'   \item **exact** this data contains the exact time of disease status transitioning to a different state (i.e., non-censored data)
#' }
#' If `type` is equal to either "obs" or "exact" then a data.frame object is returned. The data frames corresponds to the either censored data or exactly-observed data
#'
#' @export
#'
#' @seealso [simulate_LCTMC()]
#'
#' @example inst/examples/ex_convert_sim_data_2df.R

convert_sim_data_2df = function(my_list, type) {
  if (!any(c("obs", "exact", "both") %in% tolower(type))) {
    stop("`type` must be either 'obs' or 'exact'")
  }
  if (length(type) != 1) {
    stop("`type` must be of length 1")
  }

  tidy.obs = function(i) {
    data.frame(
      id = NA,
      obsTime = i$obsTime, state_at_obsTime = i$state_at_obsTime,
      x1 = i$xi[1], x2 = i$xi[2],
      w1 = i$wi[1], w2 = i$wi[2],
      latent_class = i$zi
    )
  }
  tidy.exact = function(i) {
    data.frame(
      id = NA,
      transTime = i$transTime, state_at_transTime = i$state_at_transTime,
      x1 = i$xi[1], x2 = i$xi[2],
      w1 = i$wi[1], w2 = i$wi[2],
      latent_class = i$zi
    )
  }

  ## if only get observed data
  if (tolower(type) == 'obs') {
    # a list of data frames
    df.obs = Map(f = tidy.obs, my_list)
    n_each.obs = sapply(df.obs, function(x) nrow(x))
    # `rbind` entire list
    df.obs = do.call(`rbind`, df.obs)
    rownames(df.obs) = NULL
    # add ID column back
    df.obs$id = rep(names(n_each.obs), times = as.numeric(n_each.obs))
    # return
    df.obs
  }

  ## if only get exact data
  if (tolower(type) == 'exact') {
    # a list of data frames
    df.exact = Map(f = tidy.exact, my_list)
    n_each.exact = sapply(df.exact, function(x) nrow(x))
    # `rbind` entire list
    df.exact = do.call(`rbind`, df.exact)
    rownames(df.exact) = NULL
    # add ID column back
    df.exact$id = rep(names(n_each.exact), times = as.numeric(n_each.exact))
    # return
    df.exact
  }

  ## if get both
  if (tolower(type) == 'both') {
    # obs ~ a list of data frames
    df.obs = Map(f = tidy.obs, my_list)
    n_each.obs = sapply(df.obs, function(x) nrow(x))
    # obs ~ `rbind` entire list
    df.obs = do.call(`rbind`, df.obs)
    rownames(df.obs) = NULL
    # obs ~ add ID column back
    df.obs$id = rep(names(n_each.obs), times = as.numeric(n_each.obs))

    # exact ~ a list of data frames
    df.exact = Map(f = tidy.exact, my_list)
    n_each.exact = sapply(df.exact, function(x) nrow(x))
    # exact ~ `rbind` entire list
    df.exact = do.call(`rbind`, df.exact)
    rownames(df.exact) = NULL
    # exact ~ add ID column back
    df.exact$id = rep(names(n_each.exact), times = as.numeric(n_each.exact))

    # return
    list(obs = df.obs, exact = df.exact)
  }
}
