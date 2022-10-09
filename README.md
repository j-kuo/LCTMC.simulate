## The 'LCTMC.simulate' package

### Overview
This R package simulates data from a latent class CTMC model

### Installation
Run the following commands in the R console to install:

    devtools::install_github("j-kuo/LCTMC.simulate")

Note that this package was built under **R version 4.2.1**, though it is likely to work with older versions of R as well.

### Usage
Here is a short example to demonstrate simulating a binary-state process:

    # set seed
    set.seed(456)
    
    # simulate
    d = LCTMC.simulate::simulate_LCTMC(
      N.indiv = 5, N.obs_times = 5,
      max.obs_times = 9, fix.obs_times = FALSE,
      true_param = LCTMC.simulate::gen_true_param(K_class = 3, M_state = 2),
      alpha.include = TRUE, beta.include = TRUE,
      K = 3, M = 2,
      p1 = 2, p2 = 2,
      initS_p = c(0.5, 0.5), death = NULL
    )
    
    # convert to data frames
    my_df = LCTMC.simulate::convert_sim_data_2df(my_list = d$sim_data, type = "both")

What happened here is that assuming a binary-state process where each individual could belong to one of 3 latent classes. We simulated 5 independent CTMC processes (one per person) with each person being observed at 5 random time points for a maximum 9 time units.

To visualize what's happening, here we plot person _EA000_'s multi-state process over time, 

    # plot
    LCTMC.simulate::plot_transitions(df = my_df, id = "EA000")

### Applications
The CTMC has several use cases in epidemiological studies, clinical trials, and public health surveillance. It is useful when researchers wish to study the dynamic of a multi-state process. It can also be extended in various of directions. For example, the [msm](https://cran.r-project.org/web/packages/msm/vignettes/msm-manual.pdf) package uses the CTMC in a hidden Markov model (HMM), or [semi-Markov models](https://en.wikipedia.org/wiki/Markov_renewal_process) where the distribution assumption on sojourn times are relaxed.

In our work, we extended the CTMC model by assuming individuals belong to one of $K$ latent clusters where each cluster is characterized by the differences in dynamic of the multi-state process (i.e., the state transition _speed_). The 'LCTMC.simulate' package allows users to specify a set of model parameters and simulates $N$ independent latent class CTMC processes. 

### Authors
* Jacky Kuo (creator, author)
* (advisor)

### Wiki Links
* [Latent Class Modelling](https://en.wikipedia.org/wiki/Latent_class_model)
* [Continuous-Time Markov Chain](https://en.wikipedia.org/wiki/Continuous-time_Markov_chain)

### Related Articles
Two papers are currently in preparation related to this work
