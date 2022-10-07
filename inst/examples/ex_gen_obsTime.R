\dontrun{
  # min time = 0, max time = 10. Make 10 observations
  set1 = gen_obsTime(N.obs_times = 10, min_t = 0, max_t = 10)
  set1

  # min time = 0, max time = 1000. Make 10 observations
  # notice the INCREASE in change in time, compare to set1
  gen_obsTime(N.obs_times = 10, min_t = 0, max_t = 1000)

  # min time = 0, max time = 1. Make 100 observations
  # notice the DECREASE in change in time, compare to set1
  gen_obsTime(N.obs_times = 100, min_t = 0, max_t = 1)
}
