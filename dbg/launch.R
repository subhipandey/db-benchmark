#!/usr/bin/env Rscript

library(data.table)
d = data.table("b","e","n","c","h")
system(sprintf("./%s.R", d[, paste(.SD, collapse="")])) # do some DT stuff here
q("no")
