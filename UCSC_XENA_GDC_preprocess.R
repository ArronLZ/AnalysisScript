# ==================================================
# TCGA UCSC XENA GDC 标准counts表达谱数据预处理脚本
# 结果：list
#       1. 三大差异算法后的差异分析总表
#       2. 三大差异算法的标准化表达矩阵
# ==================================================
rm(list = ls());gc()

# 文件及文件夹设置
# 输入文件夹
source_dir <- "~/Public_data/xena/eset"
eset_file <- "TCGA-LUSC.htseq_counts.tsv.gz"
# 输出文件夹
resultdir <- "./LUSC/01.diff"
rda_filename <- paste0(resultdir, "/LUSC_RESLIST3.Rdata")

# 参数设置
# 需要设置的部分
n = 12
pval = 0.05
fdr = 0.1
fc = 2
os = "linux" # "win" or "linux" or "mac"


# ========================================= begin
library(LZ)
library(YZ)
library(DESeq2)
library(parallel)
library(BiocParallel)
library(edgeR)
library(limma)
library(tibble)
library(dplyr)
library(ggplot2)
library(clusterProfiler)
setwd(source_dir)

# eset <- data.table::fread("./TCGA-LUAD.htseq_counts.tsv.gz", data.table = F)
# names(eset)[1]
# str_sub(names(eset), 14, 16) %>% table

# 0. 参数设置 -------------# 0. 参数设置 table()-------------
# 无需修改部分，在文本开头设置好各项参数即可。
logfc = log2(fc)
mark = paste0("p", pval, "q", fdr, "fc", logfc)
resultdir.sub <- paste0(dirclean(resultdir), "/", mark)
resultdir.sub
# 多线程设置，此处不需要修改，在文本开头设置好os参数即可
if (os == "win") {
  register(SnowParam(n)) # windows电脑使用这句
} else {
  register(MulticoreParam(n)) # 苹果和linux电脑使用这句
}


# 1. 读入数据 -------------(按实际情况修改参数，如是xena的表达谱数据则无需修改)
DEeset <- DEG_prepareData(eset_file = eset_file, 
                          eset.islog = T,
                          id_dot = T, col.by = "Ensembl_ID",
                          col.del=NULL, auto.del.character=T,
                          annot_trans=T, f_mark=mark,
                          oop = T,
                          oop.group.suffix1 = "01A",
                          oop.group.suffix2 = "11A",
                          oop.group.endT = "Tumor",
                          oop.group.endF = "Normal")
# 2. 差异分析 -------------
DEres <- DEeset$runDEG(outdir = resultdir, f_mark = mark, 
                       pval = pval, fdr = fdr, logfc = logfc)
DEres.e <- DEeset$runDEG(outdir = resultdir, f_mark = paste0(mark, ".e"), 
                         pval = pval, fdr = fdr, logfc = logfc, 
                         method = "edger")
DEres.v <- DEeset$runDEG(outdir = resultdir, f_mark = paste0(mark, ".v"),
                         pval = pval, fdr = fdr, logfc = logfc, 
                         method = "voom")
# help("DEeset")
# help("DEres")
# 保存标准化后数据
resdfTOlist <- function(resdf, list_mark){
  reslist <- list(resdf[, c(1, 8:ncol(resdf))], 
                  resdf[, c(1:7, ncol(resdf))])
  names(reslist) <- c(paste0("NORM.ESET.", list_mark),
                      paste0("SIG.INFO.", list_mark))
  return(reslist)
}
##
reslist <- resdfTOlist(DEres$resdf, "DESeq2")
reslist.e <- resdfTOlist(DEres.e$resdf, "edgeR")
reslist.v <- resdfTOlist(DEres.v$resdf, "voom")
reslist <- list(
  deseq2 = reslist,
  edger = reslist.e,
  voom = reslist.v
)

save(reslist, file = rda_filename, compress = "xz")
