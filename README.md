# The 'LCTMC.simulate' package

  <!-- badges: start -->
  [![R-CMD-check](https://github.com/j-kuo/LCTMC.simulate/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/j-kuo/LCTMC.simulate/actions/workflows/R-CMD-check.yaml)
  [![](https://img.shields.io/badge/R%20version-4.2.2-steelblue.svg)](https://cran.r-project.org/bin/windows/base/old/4.2.2)
  <!-- badges: end -->

This R package provides an intuitive interface to simulate censored longitudinal multistate processes. The censored data are assumed to be observed at irregular time intervals (i.e., non-discrete time). The data generation is based on the continuous-time Markov/Semi-Markov chain framework.  

## Overview

The continuous-time Markov models have been studied for more than half of a century as of 2023. It has found many use cases in epidemiological studies, clinical trials, and public health surveillance. It is a useful tool to study the dynamic of a multistate process. It can also be extended in several directions. For example, the [msm](https://cran.r-project.org/web/packages/msm/vignettes/msm-manual.pdf) package has implementations of continous-time hidden Markov models (HMM), or the distribution assumptions can be relaxed to encompass more complex processes (e.g., [semi-Markov models](https://www.sciencedirect.com/topics/computer-science/semi-markov-process)).

This package allows for data simulation from our extension of the CTMC model, **[latent class CTMC](https://github.com/j-kuo/LCTMC)**. In our study, we assumed individuals belong to one of $K$ mutually exclusive unobservable clusters, where each cluster is characterized by their differences in the disease dynamic (i.e., progressive, regressive, or mixture of both). 

## Installation

```R
# use the 'devtools' package to directly install from GitHub
devtools::install_github("j-kuo/LCTMC.simulate")
```

## Usage
Here we demonstrate the simulation of a two-state process:

```R
# set seed
set.seed(456)

# simulate
d = LCTMC.simulate::simulate_LCTMC(
  N.indiv = 5,
  N.obs_times = 5,

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
  sojourn = list(dist = "gamma", gamma.shape = 2)
)
```

This code simulates a two-state process with 3 latent clusters. Using the `N.indiv = 5` argument, 5 independent CTMC processes were generated (one per person). Excluding the baseline, each person was observed at 5 irregular times (`N.obs_times = 5`).

The `as.data.frame()` function extracts/tidies the simulated data and returns the data as data.frame objects. In this example, we specify `id = "BA000"` to extract only this person's simulated data.

```R
# coerce the "observed" data into a data frame
as.data.frame(sim_data, type = "obs", id = "BA000")
     id  obsTime state_at_obsTime         x1 x2         w1 w2 latent_class
1 BA000 0.000000                1 0.04352429  1 -0.2349686  1            1
2 BA000 5.470254                2 0.04352429  1 -0.2349686  1            1
3 BA000 7.793661                1 0.04352429  1 -0.2349686  1            1
4 BA000 7.915950                1 0.04352429  1 -0.2349686  1            1
5 BA000 7.986747                1 0.04352429  1 -0.2349686  1            1
6 BA000 9.930836                1 0.04352429  1 -0.2349686  1            1

# coerce the "exact transition" data into a data frame
as.data.frame(sim_data, type = "exact", id = "BA000")
     id  transTime state_at_transTime         x1 x2         w1 w2 latent_class
1 BA000  0.0000000                  1 0.04352429  1 -0.2349686  1            1
2 BA000  0.6124992                  2 0.04352429  1 -0.2349686  1            1
3 BA000  5.8285964                  1 0.04352429  1 -0.2349686  1            1
4 BA000 12.6018292                  2 0.04352429  1 -0.2349686  1            1
```

## Visualizing CTMC
To visualize the longitudinal process, we plot person **BA000**'s data over time. **The figure on the left shows the _actual_ process**.

```R
# S3 method for plotting
plot(x = d, id = "BA000")
```

<img src="visuals/transition_example.png" width="850">

The left figure's interpretation is the following:

> 1. This person begins by being in state **1** at time = 0
> 2. The state then transitions to state **2** at approximately time = 0.6
> 3. At roughly time = 5.8, the state transitions back to state **1**
> 4. At last, the state then jumps back to state **2** at around time = 12.6

The red dots in the figures indicate the times at which the data are being collected on this person (e.g., at a clinic visit). If the model does not properly adjust for censoring, we would be assuming the longitudinal process is the figure on the right.

However, in time-to-event analyses, making this assumption will almost surely lead to biased estimates. Since any changes that occur between observations are not accounted for. The CTMC model or other Markov-based models handle these unobserved in-between-observation changes by making some assumptions on the sojourn time ([what is sojourn time](https://www.sciencedirect.com/topics/engineering/sojourn-time)). For more info see the Wiki section at the bottom of this page.


</br>

## More Info

### Authors
* **Jacky Kuo** - _author_, _maintainer_
* **Wenyaw Chan**, PhD - _dissertation advisor_

### Wiki
* [Latent Class Modeling](https://en.wikipedia.org/wiki/Latent_class_model)
* [Continuous-Time Markov Chain](https://en.wikipedia.org/wiki/Continuous-time_Markov_chain)