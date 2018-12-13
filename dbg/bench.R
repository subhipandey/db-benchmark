#!/usr/bin/env Rscript

require(data.table)
N=1e7; K=100
timestamp = as.integer(Sys.time())
if (interactive()) Sys.setenv("DBG_ENV" = "repl")
set.seed(1)
DT <- data.table(
  id1 = sample(sprintf("id%03d",1:K), N, TRUE),      # large groups (char)
  id2 = sample(sprintf("id%03d",1:K), N, TRUE),      # large groups (char)
  id3 = sample(sprintf("id%010d",1:(N/K)), N, TRUE), # small groups (char)
  id4 = sample(K, N, TRUE),                          # large groups (int)
  id5 = sample(K, N, TRUE),                          # large groups (int)
  id6 = sample(N/K, N, TRUE),                        # small groups (int)
  v1 =  sample(5, N, TRUE),                          # int in range [1,5]
  v2 =  sample(5, N, TRUE),                          # int in range [1,5]
  v3 =  sample(round(runif(100,max=100),4), N, TRUE) # numeric e.g. 23.5749
)
#cat("GB =", round(sum(gc()[,2])/1024, 3), "\n")
l = list()
l[["1_1"]] = system.time( DT[, sum(v1), keyby=id1] )[["elapsed"]]
l[["1_2"]] = system.time( DT[, sum(v1), keyby=id1] )[["elapsed"]]
l[["2_1"]] = system.time( DT[, sum(v1), keyby="id1,id2"] )[["elapsed"]]
l[["2_2"]] = system.time( DT[, sum(v1), keyby="id1,id2"] )[["elapsed"]]
l[["3_1"]] = system.time( DT[, list(sum(v1),mean(v3)), keyby=id3] )[["elapsed"]]
l[["3_2"]] = system.time( DT[, list(sum(v1),mean(v3)), keyby=id3] )[["elapsed"]]
l[["4_1"]] = system.time( DT[, lapply(.SD, mean), keyby=id4, .SDcols=7:9] )[["elapsed"]]
l[["4_2"]] = system.time( DT[, lapply(.SD, mean), keyby=id4, .SDcols=7:9] )[["elapsed"]]
l[["5_1"]] = system.time( DT[, lapply(.SD, sum), keyby=id6, .SDcols=7:9] )[["elapsed"]]
l[["5_2"]] = system.time( DT[, lapply(.SD, sum), keyby=id6, .SDcols=7:9] )[["elapsed"]]

d = rbindlist(lapply(strsplit(names(l), "_", fixed=TRUE), as.list))[, .(machine=Sys.info()[["nodename"]], env=Sys.getenv("DBG_ENV", NA_character_), ts=timestamp, n=N, k=K, q=V1, r=V2, s=round(unlist(l), 3))]
fwrite(d, "dbg.csv", append=TRUE)

q("no")
