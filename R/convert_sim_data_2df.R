#' @title Data tidying for the simulation output
#'
#' @description Converts the output of `simulate_LCTMC(...)` to a "data.frame" object
#'
#' @param my_list a list object obtained from the `simulate_LCTMC(...)` function
#' @param type a character scalar of either "obs", "exact", or "both"
#'
#' @return if `type = "both"` then a a list object with **2** elements is returned:
#' \enumerate{
#'   \item **obs** this data contains the disease status at some pre-defined observed times. This essentially means that all outcomes are interval-censored.
#'   \item **exact** this data contains the exact time of disease status transitioning to a different state (i.e., non-censored data)
#' }
#' If `type` is equal to either "obs" or "exact" then a data.frame object is returned. The data frames corresponds to the either censored data or exactly-observed data
#'
#' @importFrom tibble tibble
#' @importFrom purrr imap_dfr
#' @importFrom tidyr unnest
#' @importFrom dplyr select
#'
#' @export
#'
#' @example inst/examples/ex_convert_sim_data_2df.R

convert_sim_data_2df = function(my_list, type){
  if(!any(c("obs", "exact", "both") %in% tolower(type))) stop("`type` must be either 'obs' or 'exact'")
  if(length(type) != 1) stop("`type` must be of length 1")

  # place holder
  Obs = Exact = NULL

  # if extract only the observed data
  if(tolower(type) == 'obs'){
    # a function specifically for `imap_dfr()`
    tidy = function(l, idx){
      tibble::tibble(
        id = idx,
        Obs = list(tibble::tibble(obsTime = l$obsTime, state_at_obsTime = l$state_at_obsTime,
                                  x1 = l$xi[1], x2 = l$xi[2],
                                  w1 = l$wi[1], w2 = l$wi[2])),
        latent_class = l$zi
      )
    }

    df = purrr::imap_dfr(.x = my_list, .f = tidy)
    df = tidyr::unnest(data = df, cols = "Obs")
  }

  # if extract only the exact transition data
  if(tolower(type) == 'exact'){
    tidy = function(l, idx){
      tibble::tibble(
        id = idx,
        Exact = list(tibble::tibble(transTime = l$transTime, state_at_transTime = l$state_at_transTime,
                                    x1 = l$xi[1], x2 = l$xi[2],
                                    w1 = l$wi[1], w2 = l$wi[2])),
        latent_class = l$zi
      )
    }

    df = purrr::imap_dfr(.x = my_list, .f = tidy)
    df = tidyr::unnest(data = df, cols = "Exact")
  }

  # if extract both the observed and exact data
  if(tolower(type) == 'both'){
    tidy = function(l, idx){
      tibble::tibble(
        id = idx,
        Obs = list(tibble::tibble(obsTime = l$obsTime, state_at_obsTime = l$state_at_obsTime,
                                  x1 = l$xi[1], x2 = l$xi[2],
                                  w1 = l$wi[1], w2 = l$wi[2])),
        Exact = list(tibble::tibble(transTime = l$transTime, state_at_transTime = l$state_at_transTime,
                                    x1 = l$xi[1], x2 = l$xi[2],
                                    w1 = l$wi[1], w2 = l$wi[2])),
        latent_class = l$zi
      )
    }

    df = purrr::imap_dfr(.x = my_list, .f = tidy)
    df1 = dplyr::select(df, cols = -Exact)
    df2 = dplyr::select(df, cols = -Obs)
    df = list(
      obs = tidyr::unnest(data = df1, cols = "Obs"),
      exact = tidyr::unnest(data = df2, cols = "Exact")
    )
  }

  return(df)
}
