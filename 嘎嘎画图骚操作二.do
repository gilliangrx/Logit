*嘎嘎画图骚操作二
sysuse sp500.dta, replace
twoway rbar open close date in 1/50, barw(0.5)
** 黑白实体，阳线为白，阴线为黑
#delimit ;
    twoway (rspike high low date in 1/50, 
                lc(black))                              // 影线
           (rbar open close date in 1/50 if close>open, 
                barw(0.5) fcolor(gs16) lcolor(gs0))     // 阳线
           (rbar open close date in 1/50 if close<=open, 
                barw(0.5) fcolor(gs0)  lcolor(gs0)),    // 阴线
        xtitle("")
        ytitle("")
        legend(off)
        scheme(s1mono)
    ;
#delimit cr
** 彩色实体，阳线为红，阴线为绿
#delimit ;
    twoway (rspike high low date in 1/50, 
                lc(black))                              // 影线
           (rbar open close date in 1/50 if close>open, 
                barw(0.5) fcolor(red) lcolor(red))      // 阳线
           (rbar open close date in 1/50 if close<=open, 
                barw(0.5) fcolor(green) lcolor(green)), // 阴线
        xtitle("")
        ytitle("")
        legend(off)
        scheme(s1color)
    ;
#delimit cr

*人口金字塔 
sysuse pop2000, clear 
replace maletotal = -maletotal/1e+6 
replace femtotal = femtotal/1e+6 
gen zero = 0 
#delimit ; 
twoway bar maletotal agegrp, horizontal xvarlab(Males) || 
       bar femtotal agegrp, horizontal xvarlab(Females) || 
	   sc agegrp zero , mlabel(agegrp) mlabcolor(black) msymbol(i) || , 
	   xtitle("Population in millions") ytitle("") 
	   plotregion(style(none)) ysca(noline) ylabel(none) 
	   xsca(noline titlegap(-3.5)) 
	   xlabel(-12 "12" -10 "10" -8 "8" -6 "6" -4 "4" 4(2)12 , 
	   tlength(0) grid gmin gmax) legend(label(1 Males) label(2 Females)) 
	   legend(order(1 2)) title("US Male and Female Population by Age, 2000")
	   note("Source: U.S. Census Bureau, Census 2000, Tables 1, 2 and 3") ; 
	   #delimit cr

*折线穗式图 
sysuse sp500, clear 
#delimit ; 
twoway line close date, yaxis(1) || 
spike change date, yaxis(2) ||, 
yscale(axis(1) r(700 1400)) ylabel(1000(100)1400, 
axis(1)) yscale(axis(2) r(-50 300)) ylabel(-50 0 50, axis(2)) 
ytick(-50(25)50, axis(2) grid) legend(off) title("S&P 500") 
subtitle("January - December 2001") 
note("Source: Yahoo!Finance and Commodity Systems, Inc.") 
yline(950, axis(1) lstyle(foreground)) ; 
#delimit cr

*针式图 
sysuse lifeexp, clear 
keep if region==3 
gen lngnp = ln(gnppc) 
quietly regress le lngnp
predict r, resid 
twoway dropline r gnp, /// 
       yline(0, lstyle(foreground)) mlabel(country) mlabpos(9) /// 
	   ylab(-6(1)6) /// 
	   subtitle("Regression of life expectancy on ln(gnp)" "Residuals:" " ", pos(11)) /// 
	   note("Residuals in years; positive values indicate" "longer than predicted life expectancy")

*折线穗式条形复合图 
sysuse sp500, clear 
replace volume = volume/1000 
#delimit ; 
twoway rspike hi low date || 
line close date || bar volume date, barw(.25) yaxis(2) || 
in 1/57 , ysca(axis(1) r(900 1400)) ysca(axis(2) r( 9 45)) 
ylabel(, axis(2) grid) ytitle(" Price -- High, Low, Close") 
ytitle(" Volume (millions)", axis(2) bexpand just(left)) 
legend(off) subtitle("S&P 500", margin(b+2.5)) 
note("Source: Yahoo!Finance and Commodity Systems, Inc.") ; 
#delimit cr

*区间图 
sysuse sp500, clear 
gen month = month(date) 
sort month 
by month: egen lo = min(volume) 
by month: egen hi = max(volume) 
format lo hi %12.0gc 
by month: keep if _n==_N 
#delimit ; 
twoway rcap lo hi month, xlabel(1 "J" 2 "F" 3 "M" 4 "A" 5 "M" 6 "J" 7 
"J" 8 "A" 9 "S" 10 "O" 11 "N" 12 "D") xtitle("Month of 2001") 
ytitle("High and Low Volume") yaxis(1 2) ylabel(12321 "12,321 (mean)", 
axis(2) angle(0)) ytitle("", axis(2)) yline(12321, lstyle(foreground)) 
msize(*2) title("Volume of the S&P 500", margin(b+2.5)) 
note("Source: Yahoo!Finance and Commodity Systems Inc.") ; 
#delimit cr



*半对角矩阵图 
sysuse lifeexp, clear 
generate lgnppc = ln(gnppc) 
graph matrix popgr lgnp safe lexp, half
*Definition of boxes and line styles.
local osmall = ", box margin(small) size(vsmall)"
local omain  = ", box margin(small)"
local bc     = ", lwidth(medthick) lcolor(black)" 
local bca    = ", lwidth(medthick) lcolor(black) mlcolor(black) mlwidth(medthick) msize(medlarge)"

*技术路线图 
twoway  /// 1) PCI to draw a box 2) pcarrowi: connecting arrows.
   pci 5.2 0 5.2 6 `bc' || pci 5.2 6 0 6 `bc' || pci 0 6 0 0 `bc' || pci 0 0 5.2 0 `bc' ///
|| pci 3 1.5 3 4.5 `bc' || pci 1.9 1.5 1.9 4.5 `bc' || pci 0.9 1.5 0.9 4.5 `bc' ///
|| pcarrowi 5 3 3.5 3 `bca' ///
|| pcarrowi 4.35 3 4.35 3.35 `bca'  ///
|| pcarrowi 3.5 3 3.2 3 `bca'  ///
|| pcarrowi 3 3 2.1 3 `bca'  ///
|| pcarrowi 1.9 3 1.1 3 `bca'  ///
, /// Text placed using "added text" [ACHTUNG sizes change with content]
text(5 3 "引言" `omain') ///
text(4.35 4.5 "重要性 "" " ///
        "已有研究 " ///
        " " ///
        "已有研究之不足 " ///
        " " ///
		"本文研究 " ///
        " " ///
        "本文研究意义"" " `osmall') ///
text(3.5 3 "余文结构" `omain') ///
text(3.1 3 "理论分析"  ) ///
text(2.5 1.5 "制度背景" ///
        " " `osmall') ///
text(2.5 4.5 "逻辑、文献" ///
         " " `osmall') ///
text(2 3 "实证研究" ) ///
text(1.5 1.5 "模型篇" ///
        " " ///
        "建立模型" ///
        " " ///
        "定义变量 " ///
		" " ///
        "选择样本" ///
        " " `osmall') ///
text(1.5 4.5 "描述性统计" ///
        " " ///
        "相关性分析" ///
        " " ///
        "差异性检验 " ///
		" " ///
        "回归分析" ///
        " " `osmall') ///
text(1 3 "稳健性检验" ) ///
text(0.5 1.5 "安慰剂检验" ///
        " " ///
        "内生性检验" ///
		" " ///
        "排除性检验" ///
        " " `osmall') ///
text(0.5 4.5 "替换变量" ///
        " " ///
        "替换区间" ///
		" " ///
        "缩小范围" ///
		" " ///
        "扩大范围" ///
        " " `osmall') /// 
legend(off) ///
xlabel("") ylabel("") xtitle("") ytitle("") ///
plotregion(lcolor(black)) ///
graphregion(lcolor(black)) xscale(range(0 6)) ///
xsize(2) ysize(3) /// A4 aspect ratio
title("实证研究流程图") ///
note("欢迎关注嘎嘎哟" ///
, size(tiny))



*带标注的散点图 
sysuse lifeexp, clear 
keep if region==2 | region==3 
replace gnppc = gnppc / 1000 
label var gnppc "GNP per capita (thousands of dollars)" 
gen lgnp = log(gnp) 
qui reg lexp lgnp 
predict hat 
label var hat "Linear prediction" 
replace country = "Trinidad" if country=="Trinidad and Tobago" 
replace country = "Para" if country == "Paraguay" 
gen pos = 3 
replace pos = 9 if lexp > hat 
replace pos = 3 if country == "Colombia" 
replace pos = 3 if country == "Para" 
replace pos = 3 if country == "Trinidad" 
replace pos = 9 if country == "United States"
 #delimit ; 
 twoway (scatter lexp gnppc, mlabel(country) mlabv(pos)) 
        (line hat gnppc, sort) , xsca(log) xlabel(.5 5 10 15 20 25 30, grid) 
		legend(off) title("Life expectancy vs. GNP per capita") 
		subtitle("North, Central, and South America") note("Data source: World bank, 1998") 
		ytitle("Life expectancy at birth (years)") ; 
		#delimit cr

*加权散点图 
sysuse census, clear 
gen drate = divorce / pop18p 
label var drate "Divorce rate" 
scatter drate medage [w=pop18p] if state!="Nevada", msymbol(Oh) /// 
note("State data excluding Nevada" /// 
"Area of symbol proportional to state's population aged 18+")


*带置信区间的散点图 
sysuse auto, clear 
quietly reg mpg weight 
predict hat 
predict s, stdf 
gen low = hat - 1.96*s 
gen hi = hat + 1.96*s 
#delimit ; 
twoway rarea low hi weight, sort bcolor(gs14) || 
scatter mpg weight ; 
#delimit cr
*->使用条件和限制
*plot有自己的条件if和自己的使用范围in
twoway (scatter mpg weight if foreign, msymbol(O)) (scatter mpg weight if !foreign, msymbol(Oh))

*twoway也有自己的条件if和自己的使用范围in
twoway (scatter mpg weight if foreign, msymbol(O)) (scatter mpg weight if !foreign, msymbol(Oh)) if mpg>20

*<=>等价
 twoway scatter mpg weight if foreign, msymbol(O) || ///
scatter mpg weight if !foreign, msymbol(Oh)
*and
 twoway scatter mpg weight if foreign, msymbol(O) || ///
scatter mpg weight if !foreign, msymbol(Oh) || if mpg>20
*or even
 scatter mpg weight if foreign, msymbol(O) || ///
scatter mpg weight if !foreign, msymbol(Oh)
*and
 scatter mpg weight if foreign, msymbol(O) || ///
scatter mpg weight if !foreign, msymbol(Oh) || if mpg>20
twoway connected mpg weight

*->twoway and plot options

scatter mpg weight, saving(mygraph) msymbol(Oh)
twoway (scatter mpg weight, msymbol(Oh)), saving(mygraph)
scatter mpg weight, msymbol(Oh) || lfit mpg weight, saving(mygraph)
* or
scatter mpg weight, msymbol(Oh) saving(mygraph) || lfit mpg weight
twoway (scatter mpg weight, msymbol(Oh)) (lfit mpg weight), saving(mygraph)

*折线、散点复合图 
sysuse sp500, clear 
#delimit ; 
twoway line close date, yaxis(1) || bar change date, yaxis(2) || in 1/52, 
ysca(axis(1) r(1000 1400)) ylab(1200(50)1400, 
axis(1)) ysca(axis(2) r(-50 300)) ylab(-50 0 50, 
axis(2)) ytick(-50(25)50, 
axis(2) grid) legend(off) title("S&P 500") subtitle("January - March 2001") 
note("Source: Yahoo!Finance and Commodity Systems, Inc.") 
yline(1150, axis(1) lstyle(foreground)) ; 
#delimit cr
