# op_download_summary

### [OP_download_summary.R](https://github.com/TBNworkGroup/op_download_summary/blob/main/OP_download_summary.R) 說明

2024 CABE 海報分析資料清理與轉換，以下為處理步驟:
#### 1. initialization
* 相對路徑 & packcge設定
* 輸入opdownloadlog.csv檔案，從TBN後台下載"下載紀錄"資料
#### 2. data cleaning
* 觀察資料欄位內容，重新命名 & 刪除列
*  user cleaning: 相同使用者若於多次下載時填寫不同的所屬單位，則不採用該使用者的下載資料問卷
*  select last record: 相同使用者若於一小時內下載多次，只採納最後一次填寫的問卷資料

#### 3. 重新命名與分類"用途"欄位
**對照表**
|重新分類後新用途名稱|含括舊用途選項|
|---|---|
|生態環境評估|生態檢核+環評|
|永續指標|SDG+ESG|
|各類研究|生態研究+各類研究+棲地復育+生態系服務評估+資料應用競賽|
|教育推廣|生態旅遊+環境教育+寫作|
|其他|其他+多選|

#### 4. 重新命名與分類"用途"欄位
* 使用split拆解條件字串，儲存成list後再重新合併成table
* 篩選與清理條件字串，並根據下面對照表重新分類
* 重新合併字串與命名條件選項
* 資料輸出存檔

**對照表**
|重新分類後新用途名稱|含括舊用途選項|
|---|---|
|分類群|分類群+類群+分類群屬性(原生性、特有性、保育等級...)+生物地圖|
|空間|自訂空間(邊界、空間範圍、海拔、網格編號)+預設空間(行政區、保護區...)|
|時間|觀測時間+月份|
|資料集|資料集|
|全部資料|全部資料|

**呈現條件選項**\
(1) 單條件
* 分類群
* 空間
* 時間
* 資料集
* 全部資料

(2) 多條件
* 分類群+空間
* 空間+時間
* 分類群+空間+時間
* 其他


#### 5. Sankey plot繪製

(1) R繪製出圖
* data.table轉換各所屬單位、用途、類型和條件下，所擁有的下載筆數
* re-order: 重新排序欄位內容
* (alpha 參數調整: 根據筆數數量，調整Sankey plot各bar透明度調整)
* ggplot: Sankey plot參數調整&繪製

**輸出完成圖**

![Rplot19](https://github.com/TBNworkGroup/op_download_summary/assets/46275621/0501be5d-195a-40bd-be52-1cee5d99d74e)
