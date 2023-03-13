# set seed
set.seed(456)

# simulate
d = LCTMC.simulate::simulate_LCTMC(
  N.indiv = 3,
  N.obs_times = 3,

  max.obs_times = 10,
  fix.obs_times = FALSE,

  true_param = LCTMC.simulate::gen_true_param(K_class = 3, M_state = 2),
  alpha.include = TRUE,
  beta.include = TRUE,

  K = 3,
  M = 2,
  p1 = 2,
  p2 = 2,

  initS_p = c(0.5, 0.5),
  death = NULL,
  sojourn = list(dist = "gamma", gamma.shape = 1)
)

# plot ~ S3 method for 'lctmc.sim' objects
plot(x = d, id = "BA000")
