\dontrun{
  # generate some CTMC parameters
  tp = gen_true_param(K_class = 3, M_state = 3)

  # use the given CTMC parameters to generate Q matrix
  x1 = 1
  x2 = 2
  x_covariate = c(1,2)
  Q = LCTMC.simulate:::gen_Qmat(r0 = tp$r0,
                                beta = tp$beta,
                                x = x_covariate,
                                z = 1,
                                M_state = 3,
                                K_class = 3)

  # generate a transition
  gen_transition(from_state = 2, Q = Q, M_state = 3)
}
