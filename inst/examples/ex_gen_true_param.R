# 3 latent class , general 2x2 case
gen_true_param(K_class = 3, M_state = 2)

# 3 latent class , special 3x3 case , where q13, q31, q32 are equal to zero
gen_true_param(K_class = 3, M_state = 3)

# an example where user specifies their own parameter values
# note: the ones not specified take default values
gen_true_param(
  K_class = 3, M_state = 3,
  pi.Z1 = list(alph0 = 1, alpha1 = 1, alpha2 = 1),
  r0.Z2 = list(q12 = 9, q21 = 9, q21 = 9, q23 = 9, q31 = 9, q32 = 9),
  beta.Z3 = list(q12 = c(0,1), q21 = c(0,1), q21 = c(0,1), q23 = c(0,1), q31 = c(0,1), q32 = c(0,1))
)
