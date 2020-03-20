***离散_嘎嘎
cd D:\stata15\ado\personal\club\club_离散0311
*logit长啥样？
twoway function y = ln(x/(1-x))
*t分布*标准正态分布
twoway function y = tden(4,x), range(-4 4) ||    ///
       function y = normalden(x), range(-4 4)    ///
    legend(label(1 "t分布(df=4)")                ///
           label(2 "正态分布"))



     **要不要表白  anglebaby
	 
	 clear
	  set obs 80000 //一个亿粉丝 5000w男 2000w 239个 海淀区
	  egen p = seq(), from(0) 
	  replace p = p/80000
	  gen odd_p = p/(1-p)
	  gen ln_odd_p = ln(odd_p)
	  
	  scatter p    odd_p   // [0,1) --> [0,+oo)
	  scatter p ln_odd_p   // [0,1) --> [-oo,+oo)
	  
	  histogram ln_odd_p, normal 
	  sum ln_odd_p, detail 

*美国佬疫情当前买不买私人医疗保险？
use 美国人口普查老年人数据.dta,clear
sum
*1.回归
logit ins linc female age age2 educyear ,r  nolog //nolog是啥？cmdlog
probit ins linc female age age2 educyear ,r  nolog //nolog是啥？cmdlog
*收入增加一个单位，logit(ins)增加多少？
*收入增加一个单位，odds增加多少？
dis exp(.6464588)
logit ins linc female age age2 educyear ,or  nolog

*2.假设检验
	*-Wald test
test linc female age age2 educyear

*3.拟合优度
fitstat
	*-模型的比较
    qui logit ins linc female
    qui fitstat, saving(m1)
    qui logit ins linc female age age2 educyear
    fitstat, using(m1) 
*4.拟合值和预测概率
    predict pr
	sum pr
	label var pr "Logit: Pr(ins)"
	dotplot pr, ylabel(0(.2)1) 	
	*-概率
	gen Yes = pr>0.5
	gen str1 Error = "" 
	replace Error="*" if (ins==0&pr>0.5)|(ins==1&pr<0.5)
	sort Error
	browse ins pr Yes Error 
	list ins pr Yes Error in -10/-1, clean noobs
    *-样本外预测
	  gen u = uniform()
      gen S = (u<=0.6)
	  logit ins linc female age age2 educyear if S==1 // 随机抽取 60% 的样本
	  predict pr1  // 利用上面的参数进行全样本预测
	
	*-误判情况
	  replace Error="*" if (ins==0&pr>0.5)|(ins==1&pr<0.5)
	  sort Error
	  browse ins pr Yes Error if S==1  // 样本内误判
	  browse ins pr Yes Error if S==0  // 样本外误判

*二、多元 logit 模型 序列 不能直接输出or
      tab chronic, miss
*1.回归
	  mlogit chronic  linc female age age2 educyear ,r  nolog  //慢性病分类
	  *-基准组的设定
	  mlogit chronic  linc female age age2 educyear ,r base(3) nolog  //慢性病
*2.假设检验
      *-Wald test
        test linc female age age2 educyear 
	  *-自带检验
		 qui mlogit chronic  linc female age age2 educyear 
		mlogtest, lr wald 
*3.拟合优度
    fitstat
*4.拟合值和预测概率 给你证明下多读书有利于健康
      prgen educyear,x(female=1) from(6) to(20) gen(fem) ncases(15)
      des fem*
      prgen ed,x(female=0) from(6) to(20) gen(nfem) ncases(15)

      label var femp5  "Female"
      label var nfemp5 "Male"
      twoway connected femp5 nfemp5 femx, scheme(s1mono) ///
             ylabel(,angle(08)) ytitle("Pr(Prof,chronic)")  

*三、有序logit
tab adl // 受限活动数目 or ok 但oprobit不行
*1.回归
	*-ologit v.s. oprobit v.s. mlogit
	
	  ologit adl  chronic  linc female age age2 educyear,r
	   est store ologit
	  oprobit adl  chronic  linc female age age2 educyear,r
	   est store oprobit
	  mlogit  adl  chronic  linc female age age2 educyear,base(1)
	   est store mlogit	
	   
	*-呈现结果
	  local m "ologit oprobit mlogit"
	  esttab `m', mtitle(`m') nogap s(N ll r2_p)

*2.假设检验
	*-Wald test
   	  test chronic  linc female age age2 educyear
*3.拟合优度
    fitstat
*4.拟合值和预测概率
    predict Dadl1 Dadl2 Aadl3 Sadl4 Sadl5  Sadl6 
    label var Dadl1 "Pr(1)"
    label var Dadl2  "Pr(2)"
    label var Aadl3  "Pr(3)"
    label var Sadl4 "Pr(4)"
	 label var Sadl5  "Pr(5)"
    label var Sadl6 "Pr(6)"

    dotplot Dadl1 Dadl2 Aadl3 Sadl4 Sadl5  Sadl6 ,  ///
	        ylabel(0(.25).75) 
  *-特定人群的概率
      prvalue, x(chronic=1 female=1 age=64 ed=16) rest(mean)
  *-列表呈现概率值		
	prtab chronic  , novarlbl	

*四、会不会有内生性？这个方法从来无法解决内生性！！！最爱的IV闪亮登场
ivprobit ins female age age2 educyear   (linc = retire), nolog 
probit ins linc female age age2 educyear  , nolog 

 *p值<0.05，可在5%水平上认为linc为内生变量
 *u与v的相关系数高达 0.8，遗漏变量在增加家庭收入的同时，也会提高购买保险的倾向。
*两阶段
 ivprobit ins female age age2 educyear  married hisp white chronic adl hstatusg  (linc = retire),first twostep

