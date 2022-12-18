# 2022_Spring_NYCU_ICLAB

紀錄一下每一次Lab的code，但大部分lab的pattern都已經遺失了...   
原始成績 : 99.175  
Rank : 1/92   ( 我的排名 / 原始成績60分以上人數)  
  
前四次的Lab寫得並不是特別好，coding style 還有蠻多可以進步的空間  
Lab5之後才慢慢掌握好的coding的技巧  
所以看Lab5之後的比較有學習及參考價值 XD

我們這學期比較特殊，每個Lab有大約10天的時間可以完成，但一樣每周三會出新的lab，時間變長的同時，難度也跟著提升...  
但一周會有兩個lab 時程overlap。 靠近期中的時候有 兩個lab、Midterm exam、 Midterm project OAO  
  
(以下 Rank : 我的排名/通過Lab的總人數)    

#Lab1  
  單純只有combinational的電路，學習如何用硬體的想法去做架構上的設計(合併重複使用的比較器)。  
  另外，減少bit數也是一個很好降低面積的方式。    
    
#Lab2  
  這次的Lab加入了clk，可以利用sequential電路來存儲資料。但在這次的Lab，我使用的方式並不是特別好，單純把各種情況條列出來，且沒有針對每種情況進行優化，所以cycle數以及面積都比較大一些。  
  
#Lab3  
  主要學習自己打pattern，大部分其實也都照著助教前幾次Lab的pattern修改，學會善用task，搞懂@negedge clk 、程式是照著順序執行的，應該就蠻容易完成這次作業  
  Design Rank : 7/108  
  Pattern Rank : 1/108  
  
#Lab4  
  學會使用IP來計算浮點數。在這次的優化目標應該以cycle time 跟 cycle為主，當初我設計的想法是少用一點IP來讓面積縮小，但實際上得到的performance沒有想像中來得好，但用太多IP就需要注意可能導致合成時間太長。
  
#Lab5  
  這次的Lab學習使用sram，必須在設計架構時就先想好要用多大的SRAM、幾個SRAM。而這次的Lab比較靠近期中，所以通過的人數也較少。
  Rank : 5/72   
  
#Lab6  
  學習自己寫一個簡易版的IP，主要也是學著如何使用generate來產生重複的電路。design的部分則需要搭配pipeline來提高performance
  Rank : 4/113
  
#Lab7  
  主要在介紹一個design中有兩個clock的情況，該如何做資料的傳遞，這次是使用AFIFO，利用他內部的flag來知道存儲空間為空的或者是滿的狀態
  Rank : 7/112

#Lab8  
  Lab8通常會是power的設計，但我們那學期調整到了Lab10，因此Lab8變成了system verilog。  
  System verilog的題目在設計上似乎都不會太難，只是條件比較多，看起來會比較複雜。  
  主要我認為可以節省的是面積的部分，可以將某些特定的變數提取出來(通常是combinational的變數)，會讓你的整個程式變得比較簡潔、易懂。  
  (詳細可以看我PPT內容) 
  因為前面的人抄襲，所以意外撿到了bestcode XD
  Rank : 4/96

#Lab9  
  寫assertion、checker、以及Lab8的pattern，而為了驗證Lab8的design是否正確，我換了一個想法來計算golden_answer，稍微冗長了一些。  
  而這次的performance計算也相對比較沒有意義，看誰時間比較多去把pattern數壓到400個 0.0  
  
#Lab10  
  用clock gating來達成low power的設計，在我的設計中，因為是做圖片的convolution，所以我為每一個convolution的點都設計了一個clock gating。  
  另外，如果02跑不過的話，可以考慮把clock gated寫的條件都放到design的if-else當中。  
  Rank : 5/98

#Lab11  
  第一個APR Lab，照著pdf檔按按鈕，在排pad的時候，盡量把input擺在一個區塊，output擺在一個區塊，相似的input、output要擺放在一起，比較不會有錯。  
  另外，面積差一點點，performance 就差很多...
  
#Lab12  
  同上一個lab，相似的input、output放在一起，沒有performance分！  
  
#Midterm project  
  學習用DRAM，DRAM可以邊讀邊寫，而每次去跟DRAM拿值會花很多cycle，但design依舊是要去省cycle數，省area達到的效益不大
  
#Final project  
  因為Midterm project寫得並不是特別好，排名在22名，因此Final就把整個架構全部改掉，雖然花了不少時間，但因為內容跟midterm很像，所以改起來還算是沒那麼痛苦。 最後area*cycle 的 Rank 是 2/90
  
  



