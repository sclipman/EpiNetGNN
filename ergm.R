library(tidyverse)
library(ergm.ego)
library(lubridate)
library(igraph)
library(intergraph)
library(matrixStats)
library(mice)

data <- readRDS("baseline_data.rds")
data <- data[which(data$redcap_event_name=="baseline_arm_1"),]
data$elig_date <- ymd(data$dg_date)
data$elig_age[is.na(data$elig_age)] <- data$elig_age2[is.na(data$elig_age)]

el <- read.csv("EdgeList_Sociometric.csv")


# Observed sociometric network --------------------------------------------

g <- as.network(el, directed=FALSE)

cols <- c("density", "distance", "diameter",  "transitivity", 
          "degree5", "degree25", "degree50", "degree75", "degree95")
out <- matrix(NA, 1, length(cols))
colnames(out) <- cols
out <- as.data.frame(out)

for (ii in 1:1){
  nw <- asIgraph(g)
  out$density[ii] <- graph.density(nw) 
  dist <- distances(nw)
  dist[dist == Inf] <- NA
  out$distance[ii] <- mean(as.vector(dist), na.rm=T)
  out$diameter[ii] <- diameter(nw) 
  out$transitivity[ii] <- transitivity(nw)
  out[ii, 5:9] <- quantile(degree(nw), probs = c(0.01, 0.25, 0.5, 0.75, 0.99)) %>% unname()
}

out_observed <- unlist(out[1,])


# Egocentric ERGM ---------------------------------------------------------

attr <- data.frame(
   id = data$record_id,
   m0f1 = ifelse(data$dg2 > 2, NA, data$dg2) - 1,
   marstat = ifelse(data$dg5 != 1, 0, data$dg5), # 1 = married, 0 = currently not married 
   age = data$elig_age,
   inj30d = data$rsu10a * data$rsu11a / 6,
   noninj = ifelse(data$rsu12 > 1, NA, data$rsu12),
   heroin = ifelse(data$rsu2a > 1, NA, data$rsu2a),
   cocaine = ifelse(data$rsu3a > 1, NA, data$rsu3a),
   stimulant = ifelse(data$rsu4a > 1, NA, data$rsu4a),
   bup = ifelse(data$rsu5a > 1, NA, data$rsu5a),
   allergy_med = ifelse(data$rsu6a > 1, NA, data$rsu6a),
   painkiller = ifelse(data$rsu7a > 1, NA, data$rsu7a),
   sedative = ifelse(data$rsu8a > 1, NA, data$rsu8a),
   needle_share = ifelse(data$su28 > 1, NA, data$su28),
   venue_40 = data$spat_jb1___40
)

colSums(is.na(attr))


## Multiple imputation for missing values
imp <- mice(attr, maxit = 4, print = T)
attr <- complete(imp)

## Convert complete network to egocentric network
g <- as.network(el, directed=FALSE)
attr <- attr[match(get.node.attr(g, "vertex.names"), attr$id), ]
attr <- attr[ ,colnames(attr) != "id"]

for (col in names(attr)) {
  g %v% col <- attr[[col]]
}

g_ego <- as.egor(g)


## ERGM terms
nmatch <- paste0('nodematch("', names(attr), '")', collapse = " + ")
nfactor <- paste0('nodefactor("', c("venue_40", "needle_share"), '")', collapse = " + ")
ncov <- paste0('nodecov("', c("age", "inj30d"), '")', collapse = " + ")

formula <- as.formula(paste("g_ego ~ edges + degree(0) + concurrent + transitiveties +", 
                            nmatch, "+", nfactor, "+", ncov))

fit <- ergm.ego(formula = formula)
sim <- simulate(fit, nsim = 500)


## Summary stats

cols <- c("density", "distance", "diameter",  "transitivity", 
          "degree5", "degree25", "degree50", "degree75", "degree95")
out <- matrix(NA, 500, length(cols))
colnames(out) <- cols
out <- as.data.frame(out)

for (ii in 1:500){
  cat("\n", ii)
  nw <- asIgraph(sim[[ii]])
  out$density[ii] <- graph.density(nw) 
  dist <- distances(nw)
  dist[dist == Inf] <- NA
  out$distance[ii] <- mean(as.vector(dist), na.rm=T)
  out$diameter[ii] <- diameter(nw) 
  out$transitivity[ii] <- transitivity(nw)
  out[ii, 5:9] <- quantile(degree(nw), probs = c(0.01, 0.25, 0.5, 0.75, 0.99)) %>% unname()
}

out_egocentric <- colMeans(out)
out_egocentric[5:9] <- colMedians(as.matrix(out[,5:9]))

ci_95 <- function(x) {
  test <- t.test(x) 
  c(lower = test$conf.int[1], upper = test$conf.int[2])
}
ci_egocentric <- as.data.frame(t(apply(out[,1:4], 2, ci_95)))



# Erdos Renyi model -------------------------------------------------------

fit <- ergm.ego(g_ego ~ edges)
sim <- simulate(fit, nsim = 500)

## Summary stats

cols <- c("density", "distance", "diameter",  "transitivity", 
          "degree5", "degree25", "degree50", "degree75", "degree95")
out <- matrix(NA, 500, length(cols))
colnames(out) <- cols
out <- as.data.frame(out)

for (ii in 1:500){
  cat("\n", ii)
  nw <- asIgraph(sim[[ii]])
  out$density[ii] <- graph.density(nw) 
  dist <- distances(nw)
  dist[dist == Inf] <- NA
  out$distance[ii] <- mean(as.vector(dist), na.rm=T)
  out$diameter[ii] <- diameter(nw) 
  out$transitivity[ii] <- transitivity(nw)
  out[ii, 5:9] <- quantile(degree(nw), probs = c(0.01, 0.25, 0.5, 0.75, 0.99)) %>% unname()
}

out_simple <- colMeans(out)
out_simple[5:9] <- colMedians(as.matrix(out[,5:9]))

ci_simple <- as.data.frame(t(apply(out[,1:4], 2, ci_95)))

