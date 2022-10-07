# simulation parameters
my_N = 20
my_N.obs_times = 15
my_max.obs_times = 90
my_fix.obs_times = FALSE

my_beta.include = TRUE
my_M = 2
my_p1 = 2

my_alpha.include = TRUE
my_K = 3
my_p2 = 2

my_initS_p = c(1/2, 1/2)
my_death = NULL # for a two-stage process we do not have death state, set to NULL

set.seed(123)

# first generate true parameters
my_true_param = gen_true_param(K_class = 3, M_state = 2)

# simulate
d = simulate_LCTMC(
   N.indiv = my_N,
   N.obs_times = my_N.obs_times,

   max.obs_times = my_max.obs_times,
   fix.obs_times = my_fix.obs_times,

   true_param = my_true_param,
   alpha.include = my_alpha.include,
   beta.incldue = my_beta.include,

   K = my_K,
   M = my_M,
   p1 = my_p1,
   p2 = my_p2,

   initS_p = my_initS_p,
   death = my_death
)

# output is a list containing two elements:
length(d)
names(d)

# `sim_data` is the simulated data, here we print the simulation for person #1
d$sim_data[[1]]
