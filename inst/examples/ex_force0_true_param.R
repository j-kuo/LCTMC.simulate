\dontrun{
  ### create model parameter values
  true_param = LCTMC.simulate::gen_true_param(M_state = 2, K_class = 3)

  ### force coefficient to 0
  true_param_new = LCTMC.simulate::force0_true_param(
    true_param = true_param,
    alpha.include = F,
    beta.include = F
  )


  ### print comparison ~ `r0`
  cat(
    "\n",
    "Original `r0`: (", paste(unlist(true_param$r0), collapse = ", "), ") \n",
    "     New `r0`: (", paste(unlist(true_param_new$r0), collapse = ", "), ") \n",
    sep = ""
  )

  ### print comparison ~ `beta`
  cat(
    "\n",
    "Original `beta`: (", paste(unlist(true_param$beta), collapse = ", "), ") \n",
    "     New `beta`: (", paste(unlist(true_param_new$beta), collapse = ", "), ") \n",
    sep = ""
  )

  ### print comparison ~ `pi` ~ notice intercept terms are NOT forced to 0
  cat(
    "\n",
    "Original `pi`: (", paste(unlist(true_param$pi), collapse = ", "), ") \n",
    "     New `pi`: (", paste(unlist(true_param_new$pi), collapse = ", "), ") \n",
    sep = ""
  )
}
