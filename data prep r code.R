## read in data and check to make sure merge worked
options(stringsAsFactors = F)
subnets.raw.t <- read.csv(file.choose()##, check.names = F)
)


## CRITICAL ISSUE:  double entries in the raw data will have ".1" added to their column names here, which is preserved following the re-transpose.
## Easist place to fix this is likely Excel.  Fix in exported files
## issue should be fixed by addition of 'check.names = F' syntax.  tests so far confirm:  check this!!

## the check.names = F , I think, works.  However, there is still an issue around Beck Pond and its 'NA.' acronym
##  since Beck Pond is not on the list and was added erroneously in the first survey
## look at filtering options, so that I can remove lines with 'NA.' acronyms...dplyr's filter() should work

## NOPE; the check.names = F doesn't work; it succeeds in not changing the names, but fails in the left_join()

name.key <- read.csv(file.choose())
library(dplyr)
subnets.all.t <- left_join(subnets.raw.t, name.key, by = "org.name")
View(subnets.all.t)
check.1 <- subnets.all.t[, -(3:96)]
View(check.1)
check.2 <- filter(subnets.all.t, int.acronym != "")
rm(check.1, check.2)
## iterate merging and cleaning lists for the merger until merger works properly
## failed merge lines will be output as system missing/NA
##...but couldn't find a way to limit to just seeing those that didn't work and then, resort back to readable order


## building info share...working out process; process improved in subsequent subnets
info.share.t.name <- filter(subnets.all.t, subnet == "Info Sharing")
info.share.t <- info.share.t.name[,-c(2,97)]
info.share.t[,1] <- info.share.t.name[,97]
info.share.2015.nsq <- data.frame(t(info.share.t))

## building TA subnet
ta.t.name <- filter(subnets.all.t, subnet == "TA")
ta.t <- ta.t.name[,-c(2,97)]
ta.t[, 1] <- ta.t.name[,97]
ta.2015.nsq <- data.frame(t(ta.t))

## building reporting subnet
report.to.t.name <- filter(subnets.all.t, subnet == "Accountability")
report.to.t <- report.to.t.name[, -c(2, 97)]
report.to.t[,1] <- report.to.t.name[,97]
report.to.2015.nsq <- data.frame(t(report.to.t))

## building financial resource sharing subnet
fin.res.share.t.name <- filter(subnets.all.t, subnet == "Resources")
fin.res.share.t <- fin.res.share.t.name[, -c(2, 97)]
fin.res.share.t[,1] <- fin.res.share.t.name[, 97]
fin.res.share.2015.nsq <- data.frame(t(fin.res.share.t))

## building project coordination and collaboration subnet
pc.c.t.name <- filter(subnets.all.t, subnet == "Coordination")
pc.c.t <- pc.c.t.name[, -c(2, 97)]
pc.c.t[,1] <- pc.c.t.name[,97]
pc.c.2015.nsq <- data.frame(t(pc.c.t))

## saving
save.image("C:/Users/Steve/ownCloud/implementation networks/data/Yr 2 2015/data prep in R.RData")

##**************************************************************************************
## export matrices now and clean out 'NA.' and '.1''s and '.2' added for double names  *
## exported matrices are for cleaning and record keeping                               *
## reimport and proceed with newly cleaned matrices                                    *
##**************************************************************************************

write.csv(info.share.2015.nsq, "info share 2015 prep.csv")
write.csv(ta.2015.nsq, "tech assist 2015 prep.csv")
write.csv(report.to.2015.nsq, "reporting 2015 prep.csv")
write.csv(fin.res.share.2015.nsq, "fin res share 2015 prep.csv")
write.csv(pc.c.2015.nsq, "pc-c 2015 prep.csv")

## prep matrices for running through edge list transform
## fin.res.share.2015.nsq.prep <- cbind(rownames(fin.res.share.2015.nsq), fin.res.share.2015.nsq)
## info.share.2015.nsq.prep <- cbind(rownames(info.share.2015.nsq), info.share.2015.nsq)
## pc.c.2015.nsq.prep <- cbind(rownames(pc.c.2015.nsq), pc.c.2015.nsq)
## report.to.2015.nsq.prep <- cbind(rownames(report.to.2015.nsq), report.to.2015.nsq)
## ta.2015.nsq.prep <- cbind(rownames(ta.2015.nsq), ta.2015.nsq)

## read in fixed matrices
fin.res.share.2015.nsq.prep <- read.csv(file.choose(), header = F)
info.share.2015.nsq.prep <- read.csv(file.choose(), header = F)
pc.c.2015.nsq.prep <- read.csv(file.choose(), header = F)
report.to.2015.nsq.prep <- read.csv(file.choose(), header = F)
ta.2015.nsq.prep <- read.csv(file.choose(), header = F)

## load in edge list transform code here:  function stored under OwnCloud\Literature\Methodology\
fin.res.share.2015.el <- survey.mat.convert(fin.res.share.2015.nsq.prep)
info.share.2015.el <- survey.mat.convert(info.share.2015.nsq.prep)
pc.c.2015.el <- survey.mat.convert(pc.c.2015.nsq.prep)
report.to.2015.el <- survey.mat.convert(report.to.2015.nsq.prep)
ta.2015.el <- survey.mat.convert(ta.2015.nsq.prep)

## save out the data; export for record keeping
write.csv(fin.res.share.2015.el, "FinResShare 2015 edgelist.csv")
write.csv(info.share.2015.el, "InfoShare 2015 edgelist.csv")
write.csv(pc.c.2015.el, "PC-C 2015 edgelist.csv")
write.csv(report.to.2015.el, "Reporting 2015 edgelist.csv")
write.csv(ta.2015.el, "TechAssist 2015 edgelist.csv")

write.csv(fin.res.share.2015.nsq.prep, "FinResShare 2015 NSQ .csv")
write.csv(info.share.2015.nsq.prep, "InfoShare 2015 NSQ.csv")
write.csv(pc.c.2015.nsq.prep, "PC-C 2015 NSQ.csv")
write.csv(report.to.2015.nsq.prep, "Reporting 2015 NSQ.csv")
write.csv(ta.2015.nsq.prep, "TechAssist 2015 NSQ.csv")
