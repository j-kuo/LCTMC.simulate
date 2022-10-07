#' @title Simulate a data from a latent CTMC model
#'
#' @description Given some underlying parameter values that dictate the latent class assignment process, the CTMC process, and observation times.
#' simulates a latent CTMC process and outputs the result to a list object.
#'
#' @param df a list object obtained from `convert_sim_data_2df(...)`. This list object should hold two data frame objects `obs` and `exact`. \cr
#' See `?convert_sim_data_2df` for more details
#' @param id a character scalar to indicate which person (ID number) should be plotted
#'
#' @return This function generates a plot and returns `NULL`
#'
#' @export
#'
#' @example inst/examples/ex_plot_transitions.R

plot_transitions = function(df, id){
  ## subset into observed data & exact data
  df_obs.sub = df$obs[df$obs$id == id, ]
  df_exact.sub = df$exact[df$exact$id == id, ]

  ## plotting parameters
  xlim1 = 0
  xlim2 = max(c(max(df_obs.sub$obsTime), max(df_exact.sub$transTime)))
  xlim_by = round((xlim2 - xlim1) / 10)

  ylim1.labs = min(min(df_obs.sub$state_at_obsTime), min(df_exact.sub$state_at_transTime))
  ylim2.labs = max(max(df_obs.sub$state_at_obsTime), max(df_exact.sub$state_at_transTime))
  ylim1.range = ylim1.labs - 0.15
  ylim2.range = ylim2.labs + 0.15
  ylim_by = 1

  ## plot layout (2x1 figure)
  graphics::layout(matrix(c(1,2,3,4), ncol=2, byrow=TRUE), heights=c(4, 1))
  graphics::par(mai=rep(0.75, 4))

  ## Exact Process ~ plot (1) ~ main
  plot(
    x = df_exact.sub$transTime,
    y = df_exact.sub$state_at_transTime,
    type = 's',
    xlim = c(xlim1, xlim2),
    ylim = c(ylim1.range, ylim2.range),
    xaxt = 'n', yaxt = 'n',
    main = paste("[Person ID: ", id, "]\nActual transition of disease state", sep = ""),
    xlab = "Time",
    ylab = "Disease States",
    lwd = 2
  )
  graphics::points(x = df_obs.sub$obsTime, y = df_obs.sub$state_at_obsTime, pch = 19, col = "#8B0000", cex = 1.5)

  ## Exact Process ~ plot (1) ~ X-axis ticks
  graphics::axis(side=1, at = seq(xlim1, xlim2, by = xlim_by), labels = FALSE)
  graphics::text(
    pos = 1,
    x = seq(xlim1, xlim2, by = xlim_by),
    y = graphics::par("usr")[3],
    labels = seq(xlim1, xlim2, by = xlim_by),
    offset = c(0.75),
    xpd = TRUE
  )

  ## Exact Process ~ plot (1) ~ Y-axis ticks
  graphics::axis(side=2, at = seq(ylim1.labs, ylim2.labs, by = ylim_by), labels = FALSE)
  graphics::text(
    pos = 2,
    x = graphics::par("usr")[1],
    y = seq(ylim1.labs, ylim2.labs, by = ylim_by),
    labels = seq(ylim1.labs, ylim2.labs, by = ylim_by),
    offset = c(0.75),
    xpd = TRUE
  )

  ## Observed data plot (2) ~ main
  plot(
    x = df_obs.sub$obsTime,
    y = df_obs.sub$state_at_obsTime,
    type = 's',
    xlim = c(xlim1, xlim2),
    ylim = c(ylim1.range, ylim2.range),
    xaxt = 'n', yaxt = 'n',
    main = paste("[Person ID: ", id, "]\nIf we treat the observed data \n as the actual transition process", sep = ""),
    xlab = "Time",
    ylab = "Disease States",
    lwd = 2,
    lty = 3,
    col = "#2C7DB5"
  )
  graphics::points(x = df_obs.sub$obsTime, y = df_obs.sub$state_at_obsTime, pch = 19, col = "#8B0000", cex = 1.5)

  ## Observed data plot (2) ~ X-axis ticks
  graphics::axis(side=1, at = seq(xlim1, xlim2, by = xlim_by), labels = FALSE)
  graphics::text(
    pos = 1,
    x = seq(xlim1, xlim2, by = xlim_by),
    y = graphics::par("usr")[3],
    labels = seq(xlim1, xlim2, by = xlim_by),
    offset = c(0.75),
    xpd = TRUE
  )

  ## Observed data plot (2) ~ Y-axis ticks
  graphics::axis(side=2, at = seq(ylim1.labs, ylim2.labs, by = ylim_by), labels = FALSE)
  graphics::text(
    pos = 2,
    x = graphics::par("usr")[1],
    y = seq(ylim1.labs, ylim2.labs, by = ylim_by),
    labels = seq(ylim1.labs, ylim2.labs, by = ylim_by),
    offset = c(0.75),
    xpd = TRUE
  )

  ## draw legends
  graphics::par(mai=rep(0.3, 4))

  graphics::plot.new()
  graphics::legend("left", inset = c(0.33, 0),
                   lty = c(1, 3), lwd = c(2, 2), col = c('black', "#2C7DB5"),
                   legend = c("Actual disease dynamic over time", "Incorrect disease dynamic over time"),
                   bty = "n",
                   ncol = 1,
                   pt.cex = 1, cex = 1.4)

  graphics::plot.new()
  graphics::legend("left",
                   fill = c("#8B0000"),
                   legend = "Observations (e.g., doctor's visit)",
                   bty = "n",
                   ncol = 1,
                   pt.cex = 1, cex = 1.4)
}
