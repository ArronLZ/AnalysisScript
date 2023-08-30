# GSVA between parterns
library(GSVA)
library(clusterProfiler)

# 自定义函数，将msigdb的gmt文件转换为gsva要求的格式
#gsva要求的基因集格式为：带名字的list
#如：
#$REGULATION_OF_MITOTIC_RECOMBINATION
# [1] "RAD50"  "ANKLE1" "ZSCAN4" "ERCC2"  "MLH1"   "MRE11"  "TERF2" 
#$MITOTIC_SPINDLE_ELONGATION
#   [1] "KIF4A"   "KIF4B"   "RACGAP1" "BIRC5"   "INCENP"  "NUMA1"  
#   [7] "MAP10"   "CDCA8"   "AURKC"   "PRC1"    "AURKB"   "KIF23" 
#msigdb的格式为，2列的datafame
#                                                                term         gene
#REGULATION_OF_MITOTIC_RECOMBINATION      RAD50
#REGULATION_OF_MITOTIC_RECOMBINATION      ANKLE1
#REGULATION_OF_MITOTIC_RECOMBINATION      ZSCAN4
#.....                                                                           .......
#MITOTIC_SPINDLE_ELONGATION                           KIF4A
#MITOTIC_SPINDLE_ELONGATION                           KIF4B
msigdbGMTtoGSVAset <- function(gmt, rename = T) {
  gmt.l <- pivot_wider(gmt, names_from = "term", values_from = "gene") %>% 
    apply(., 2, function(x) x[[1]])
  # 因为gmt的名称前面都有一个相同的标记，如 KEGG_
  if (rename) {
    names(gmt.l) <- str_extract(names(gmt.l), "\\_(.*)") %>% sub("_", "", .)
  }
  return(gmt.l)
}


c2.kegg <- read.gmt("E:/JGYUN/PublicData/msigdb_sub/c2.cp.kegg.v2023.1.Hs.symbols.gmt")
c2.kegg.wider <- msigdbGMTtoGSVAset(c2.kegg)
names(c2.kegg.wider)
c5.bp <- read.gmt("E:/JGYUN/PublicData/msigdb_sub/c5.go.bp.v2023.1.Hs.symbols.gmt")
c5.bp.wider <- msigdbGMTtoGSVAset(c5.bp)
names(c5.bp.wider)
c5.bp.wider %>% head()

eset[1:4,1:8]   # 行名为基因，列名为样本名
eset %>% range()
eset.os <- read.csv("new/consensus_cluster/eset_os&class.csv", row.names = 1)
eset <- eset %>% dplyr::select(rownames(eset.os))
eset <- as.matrix(eset)  # 需要为matrix

# 基因集需要是 matrix 和 list对象。
# 默认情况下，kcdf="Gaussian"，适用于输入表达式值连续的情况，
##   如对数尺度的微阵列荧光单元、RNA-seq log-CPMs、log-RPKMs或log-TPMs。
# 当输入表达式值是整数计数时，比如那些从RNA-seq实验中得到的值，
##   那么这个参数应该设置为kcdf="Poisson"
gsva.re <- gsva(eset, c2.kegg.wider, method='gsva', kcdf='Poisson',
                          parallel.sz=8)
