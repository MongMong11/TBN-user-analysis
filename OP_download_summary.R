#1. initialization ####
#path
setwd("D:/Mong Chen/240123_CABE")

#library
library(data.table)
library(ggplot2)
library(dplyr)
#library(ggalluvial)
#library(showtext)
#showtext_auto()
#font_add("Microsoft_JhengHei", regular = "C:/Windows/Fonts/msjh.ttc")
#font_add("Microsoft_JhengHei_bold", regular = "C:/Windows/Fonts/msjhbd.ttc")

#fread
op_download_dt<-fread("opdownloadlog.csv", encoding = "UTF-8", colClasses = "character")

#2. data cleaning ####
#select Date range
op_download_dt<-op_download_dt %>% 
  mutate(Date = as.Date(substr(`下載時間`,1,10)))%>% 
  filter(Date >= as.Date('2023-08-01') & Date <= as.Date('2023-11-30')) %>%
  subset(., select = -c(Date))

#Delete
op_download_dt<-op_download_dt %>%
  slice(-which(op_download_dt$`狀態`=="錯誤")) %>%
  subset(., select = -c(`狀態`)) %>%
  slice(-which(op_download_dt$`所屬單位`=="其他：TBN")) %>%
  slice(-which(op_download_dt$`用途`=="其他：測試")) %>%
  slice(-which(op_download_dt$`用途`=="其他：資料檢查")) %>%  
  slice(-which(op_download_dt$`用途`=="其他：檢測系統對應多物種的下載正確性")) %>%  
  slice(-which(op_download_dt$`用途`=="其他：幫小柯徵人")) %>%
  slice(-which(op_download_dt$`用途`=="其他：好奇")) %>%
  slice(-which(op_download_dt$`用途`=="其他：test")) %>%
  slice(-which(op_download_dt$`用途`=="其他：一直沒有下載成功"))

#re-name
op_download_dt<-op_download_dt %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：中研院GIS研究中心", "學術單位及大專院校", `所屬單位`)) %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：個人", "其他", `所屬單位`)) %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：沒有", "其他", `所屬單位`)) %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：台化公司", "民間公司", `所屬單位`)) %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：忠寮社區", "其他", `所屬單位`)) %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：羅東社大植物班", "其他", `所屬單位`)) %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：個人藝術家", "其他", `所屬單位`)) %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：興趣", "其他", `所屬單位`)) %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：家庭", "其他", `所屬單位`)) %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：無", "其他", `所屬單位`)) %>%  
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：走讀原生植物", "其他", `所屬單位`)) %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：民享環境生態調查公司", "民間公司", `所屬單位`)) %>%
  mutate(., `所屬單位`= ifelse(`所屬單位`=="其他：陽明山國家公園解說志工+荒野保護協會環教推廣講師志工", "NGO", `所屬單位`))

#user cleaning
vec<-unique(op_download_dt$email)
user_ls<-list()
for (i in 1:length(vec)) {
  table<-op_download_dt[which(op_download_dt$email==vec[i])]
  user_department<-unique(table$所屬單位)
  if (length(user_department) != 1) {
    user_ls[[i]]<-NA
  } else {
    user_ls[[i]]<-data.frame(table)
  }
}

op_download_dt<-do.call(rbind,user_ls)
op_download_dt<-op_download_dt %>%
  slice(-which(is.na(op_download_dt$email))) %>%
  as.data.table()

#select last hour record
op_download_dt<-op_download_dt %>%
  mutate(time = substr(.$`下載時間`,1,13)) %>%
  arrange(email, desc(time)) %>%
  distinct(., time, email, `類型`, `用途`, .keep_all = TRUE) %>%
  subset(., select = -c(time))

#re-name
op_download_dt$`類型`<-ifelse(op_download_dt$`類型` != "空間(網格)" & op_download_dt$`類型` !=  "名錄" & op_download_dt$`類型` !=  "觀測紀錄",
                            "其他", op_download_dt$`類型`)

#3. user re-name & category####

#table
table<-data.frame(matrix(NA,nrow(op_download_dt),6))
colnames(table)<-c("下載時間", "類型", "email", "所屬單位", "用途", "條件")



for (i in 1:nrow(op_download_dt)) {
  #sp_split
  usage<-as.character(op_download_dt[i,5])
  use_split<-strsplit(usage, split = ";")
  use_split<-unlist(use_split)
  use_split<-recode(use_split,
                    "生態檢核/環社檢核" = "生態環境評估",
                    "環境影響評估/監測" = "生態環境評估",
                    "永續發展指標 SDGs" = "永續指標",
                    "企業永續指標 ESG" = "永續指標",
                    "其他領域研究" = "各類研究",
                    "專題報告等作業繳交" = "各類研究",
                    "生態相關領域研究" = "各類研究",
                    "棲地復育" = "各類研究",
                    "生態系服務評估" = "各類研究",
                    "資料應用競賽" = "各類研究",
                    "生態旅遊" = "教育推廣",
                    "環境教育教材" = "教育推廣",
                    "寫作（推廣／媒體）" = "教育推廣",
                    "其他" = "其他")
  use_split<-unique(use_split)
  table[i,1]<-as.character(op_download_dt[i,1])
  table[i,2]<-as.character(op_download_dt[i,2])
  table[i,3]<-as.character(op_download_dt[i,3])
  table[i,4]<-as.character(op_download_dt[i,4])
  table[i,6]<-as.character(op_download_dt[i,6])
  if (length(use_split)==1) {
    table[i,5]<-use_split
  } else {
    table[i,5]<-"其他" 
  }
}

vec<-grep("^其他：", table$用途)
table[vec,5]<-"其他"
op_download_dt<-table

#4. conditions####
#拆解條件字串
ls<-list()
for (i in 1:nrow(op_download_dt)) {
  #sp_split
  condition<-as.character(op_download_dt[i,6])
  condition_split<-strsplit(condition, "[=+]")
  condition_split<-unlist(condition_split)
  
  #table
  table<-data.frame(matrix(NA,length(condition_split),6))
  colnames(table)<-c("下載時間", "類型", "email", "所屬單位", "用途", "條件")
  
  table$`下載時間`<-as.character(op_download_dt[i,1])
  table$`類型`<-as.character(op_download_dt[i,2])
  table$`email`<-as.character(op_download_dt[i,3])
  table$`所屬單位`<-as.character(op_download_dt[i,4])
  table$`用途`<-as.character(op_download_dt[i,5])
  table$`條件`<-condition_split
  
  ls[[i]]<-table
}

#篩選條件字串
DT<-do.call(rbind,ls)
vec<-c("全部資料",
       "分類群（含所有子分類群）",
       "類群",
       " 行政區（含所有子行政區）",
       " 觀測時間",
       "空間範圍",
       " 網格編號",
       " 分類群（含所有子分類群）",
       "資料集",
       "生物地圖",
       " 資料集",
       "行政區（含所有子行政區）",
       "地區",
       " 類群",
       "國內紅皮書",
       " 保育類",
       " 國際紅皮書",
       " 國內紅皮書",
       " 原生性",
       " 敏感狀態",
       " 生物地圖",
       "網格編號",
       " 地區",
       " 海拔",
       " 特有性",
       "保育類",
       " 月份",
       "邊界",
       "觀測時間",
       " 觀測時間")

ls2<-list()
for (i in 1:length(vec)) {
  #table
  table<-DT[which(DT$`條件`==vec[i]),]
  ls2[[i]]<-table
}

#重新命名條件字串
DT2<-do.call(rbind,ls2)
library(stringr)
DT2$`條件`<-str_trim(DT2$`條件`, side = c("both"))
DT2 <- DT2 %>% mutate(`條件`= recode(`條件`,
                                   "分類群（含所有子分類群）"="分類群",
                                   "類群"="分類群",
                                   "邊界"="空間",
                                   "月份"="時間",
                                   "觀測時間"="時間",
                                   "國內紅皮書"="分類群",
                                   "網格編號"="空間",
                                   "國際紅皮書"="分類群",
                                   "行政區（含所有子行政區）"="空間",
                                   "地區"="空間",
                                   "原生性"="分類群",
                                   "特有性"="分類群",
                                   "敏感狀態"="分類群",
                                   "保育類"="分類群",
                                   "資料集"="資料集",
                                   "生物地圖"="空間",
                                   "海拔"="空間",
                                   "空間範圍"="空間"
                                   )) %>% as.data.table()

#重新合併命名&填入條件字串
DT3<-op_download_dt
for (i in 1:nrow(DT3)){
  time<-DT3[i,1]
  user_email<-DT3[i,3]  
  table<-DT2[下載時間==time & email == user_email]
  str_condition<-unique(table$條件)
  
  if (length(str_condition)==1) {
    DT3[i,6]<-str_condition
  } else {
    str_condition<-paste(str_condition, collapse = '+')
    DT3[i,6]<-str_condition
  }
}
DT3$條件<-ifelse(DT3$條件=="空間" | DT3$條件=="分類群" | DT3$條件=="時間" |  DT3$條件=="資料集" |  DT3$條件=="全部資料" | DT3$條件=="分類群+空間" | DT3$條件=="時間+空間" | DT3$條件=="空間+時間+分類群", DT3$條件, "其他")

#save file
fwrite(DT3, "output\\OP_download_summary.csv")

#5. alluvia####
op_download_dt<-as.data.table(DT3)
op_download_dt<-op_download_dt[,.N, by=.(`所屬單位`, `用途`, `類型`, `條件`)]

#re-order
op_download_dt$`所屬單位` <- factor(op_download_dt$`所屬單位`, levels=c("其他",
                                                                "NGO",
                                                                "民間公司",
                                                                "國高中及小學",
                                                                "政府單位",
                                                                "學術單位及大專院校"))

op_download_dt$`用途` <- factor(op_download_dt$`用途`, levels=c("其他",
                                                            "教育推廣",
                                                            "各類研究",                                                            
                                                            "永續指標",
                                                            "生態環境評估"))

op_download_dt$`類型` <- factor(op_download_dt$`類型`, levels=c("其他",
                                                            "空間(網格)",
                                                            "名錄",
                                                            "觀測紀錄"))

op_download_dt$`條件` <- factor(op_download_dt$`條件`, levels=c("其他",
                                                            "空間+時間+分類群",
                                                            "時間+空間",
                                                            "分類群+空間",
                                                            "全部資料",
                                                            "資料集",
                                                            "時間",
                                                            "空間",
                                                            "分類群"))

op_download_dt<-op_download_dt %>% slice(-which(is.na(op_download_dt$所屬單位)))

#plot alpha參數調整
#op_download_dt$N<-as.numeric(op_download_dt$N)
#op_download_dt$light<-log10(sqrt(op_download_dt$N))*10
#op_download_dt$light<-ifelse(op_download_dt$N>5, op_download_dt$light, 0.0000001)

#Sankey plot
ggplot(data = op_download_dt,
       aes(axis1 = `所屬單位`, axis2 = factor(`用途`), axis3 = factor(`類型`), axis4 = factor(`條件`),
           y = N)) +
  scale_x_discrete(limits = c("所屬單位", "用途", "類型", "條件"), expand = c(.05, .05)) +
  scale_y_reverse() +
  xlab("Demographic") +
  ylab("Count") +
  geom_alluvium(aes(fill = `所屬單位`), width = 1/4) +
#  geom_alluvium(aes(fill = `所屬單位`, alpha = light), width = 1/4) +
  geom_stratum(width = 1/4) +
  geom_text(stat = "stratum", aes(label = after_stat(stratum)), size = 3) +
  scale_fill_manual(values = c("#DDEBF0","#FFDCE2","#F2A488", "#B7CA79", "#B9B3C7", "#C59BB0"))+
#  scale_alpha_continuous(range = c(.25, .75), guide = "none")+
  theme_minimal(base_size = 20)

