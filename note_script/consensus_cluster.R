library(ConsensusClusterPlus)

eset.age[1:3,1:3]
#                TCGA-50-6594-01A   TCGA-67-6217-01A   TCGA-50-5942-01A
#IGF2BP1          5.0836881              -3.7070963                -2.5339806
#HOXD13         0.0000000               0.0000000                 0.0000000
#HOXA13        -0.8997773              -0.8997773               -0.8997773

# 数据转换、归一化
eset.age <- log2(eset.age + 1)
eset.age <- sweep(eset.age, 1, apply(eset.age, 1, median, na.rm=T))
eset.age <- as.matrix(eset.age)   # ConsensusClusterPlus数据必须时matrix

results <- ConsensusClusterPlus(
  eset.age, maxK=7, reps=1000, pItem=0.8, pFeature=1, 
  clusterAlg="hc", distance="pearson", seed=12345, 
  plot="pdf", writeTable = TRUE, title = "consensus_cluster")
