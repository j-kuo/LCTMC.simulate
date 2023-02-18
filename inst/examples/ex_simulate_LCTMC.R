# set seed
set.seed(123)

# simulate
d = LCTMC.simulate::simulate_LCTMC(
   N.indiv = 10,
   N.obs_times = 10,

   max.obs_times = 50,
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
   sojourn = 'exp'
)

# output is a list containing two elements:
length(d)
names(d)

# `sim_data` is the simulated data, here we print the simulation for person #1
d$sim_data[[1]]
