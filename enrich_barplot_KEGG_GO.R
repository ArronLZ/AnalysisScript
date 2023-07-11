### 富集分析 条形图 脚本【图形特性: 大到小排列，Ontology分类】
### 数据要求，表格需要至少有PATHWAY, Ontology, DEG, Qvalue这四列（KEGG数据不需要Ontology列）
library(xlsx)
library(dplyr)
library(ggplot2)

# 1. KEGG (PATHWAY, DEG, Qvalue)
data <- read.xlsx("D:/Users/earth/Downloads/enrichment.xlsx", sheetIndex = 1)
data$GenePercent <- round(data$DEG / data$DEGF, 2)
data <- data[data$Qvalue < 0.4,]

p <- ggplot(data, aes(x = reorder(PATHWAY, DEG), y = DEG, fill = Qvalue)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_continuous(expand = c(0.04, 0)) +
  #scale_x_continuous(limits = c(0, 70)) +
  xlab("Pathway") +
  ylab("Gene Counts") +
  ggtitle("KEGG Pathway") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(color = "black", size = 1),
        text = element_text(size = 14))

pdf("D:/Users/earth/Downloads/KEGG.pdf", width = 8, height = 10)
p
dev.off()


# 2. GO (PATHWAY, Ontology, DEG, Qvalue)
go <- read.table("D:/Users/earth/Downloads/go.txt", sep = "\t", header =T)
go <- go %>% filter(Qvalue < 0.25)
go <- go %>% arrange(desc(Ontology), DEG)
go$sx <- 1:nrow(go)

# 按大小顺序排序，不含Ont分类
p <- ggplot(go, aes(x = reorder(PATHWAY, DEG), y = DEG, fill = Qvalue)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_discrete(expand = c(0.04, 0)) +
  xlab("Pathway") +
  ylab("Gene Counts") +
  ggtitle("GO Pathway") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(color = "black", size = 1),
        text = element_text(size = 14))
p

# 按大小顺序排序，含Ont分类,含Ont边框
p <- ggplot(go, aes(x = reorder(PATHWAY, sx), y = DEG, 
                    fill = Qvalue, color=Ontology)) +
  geom_bar(stat = "identity", linewidth = 0.3) +
  coord_flip() +
  scale_x_discrete(expand = c(0.02, 0)) +
  scale_y_continuous(expand = c(0.02,0)) +
  xlab("Pathway") +
  ylab("Gene Counts") +
  ggtitle("GO Pathway") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(color = "black", size = 1),
        text = element_text(size = 14)) +
  scale_color_manual(values = c("red", "green", "yellow"))
p
pdf("D:/Users/earth/Downloads/GO_kuang.pdf", width = 12, height = 12)
p
dev.off()

# 按大小顺序排序，含Ont分类，不含Ont边框
p <- ggplot(go, aes(x = reorder(PATHWAY, sx), y = DEG, 
                    fill = Qvalue)) +
  geom_bar(stat = "identity", linewidth = 0.3) +
  coord_flip() +
  scale_x_discrete(expand = c(0.02, 0)) +
  scale_y_continuous(expand = c(0.02,0)) +
  xlab("Pathway") +
  ylab("Gene Counts") +
  ggtitle("GO Pathway") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(color = "black", size = 1),
        text = element_text(size = 14)) +
  scale_color_manual(values = c("red", "green", "yellow"))
p
pdf("D:/Users/earth/Downloads/GO.pdf", width = 12, height = 12)
p
dev.off()
