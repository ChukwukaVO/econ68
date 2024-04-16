clear
clear matrix
set mem 30m
set more off


/** 
Chukwuka V. Odigbo 
Econ 68: Topics in Public Economics
Parallel trends graphs
**/


* change to the directory where the data are saved
cd "/Users/chukwuka/Desktop/Economics/Stata/Econ68Stata/finalpaper"
cap log close
log using "paralleltrendsgraphs.log", replace
use "votingdsetcleaned.dta"


* I want only presidential election years
drop if ispres == 0

* Target the college-age range
gen isage = (age>=18 & age<=25)
gen probablyincollege = (educ>=73 & educ<123 & educ!=111)
gen targpop = isage*probablyincollege
drop if targpop==0


* state level data
collapse (mean) age targpop whiteshr ishisp ismarried isemployed iswoman incollege [w=vosuppwt], by(year hadmandate) 

* graphs

foreach var in age whiteshr ishisp ismarried isemployed iswoman incollege {
	twoway (connected `var' year if hadmandate == 0, xline(1998) sort lcolor(blue)) ///
		(connected `var' year if hadmandate == 1, xline(1998) sort lcolor(red)), ///
		legend(off) title(`var') ///
		xtitle("Year") ytitle()
		graph save `var'.gph, replace
		
}

graph combine age.gph whiteshr.gph ishisp.gph
gr export balance_test.png, replace as(png)



graph combine ismarried.gph isemployed.gph iswoman.gph incollege.gph
gr export balance_test_2.png, replace as(png)


cap log close
