#' @title Generates a list of ID numbers
#'
#' @description Generate a list of character class IDs to be used for the CTMC simulation.
#' The format is "AAxxx" where "AA" are two capital letters and "xxx" are three digit numbers (leading zeroes are allowed, e.g., FX001)
#'
#' @return a character vector containing unique IDs
#'
#' @example inst/examples/ex_gen_IDlist.R

gen_IDlist = function(){
  IDs = expand.grid(apply(expand.grid(LETTERS, LETTERS), 1, FUN = function(x) paste(x, collapse = "")), 0:999)
  IDs$Var2 = unname(sapply(IDs$Var2, function(x) paste(c(rep(0, 3-nchar(x)), x), collapse = "")))
  IDs$x = paste(IDs$Var1, IDs$Var2, sep = "")

  return(IDs$x)
}
