clear
clear matrix
set mem 30m
set more off

cd "/Users/chukwuka/Desktop/Economics/Stata/Econ68Stata/finalpaper"
cap log close
log using "figures.log", replace
use "votingdsetcleaned.dta"

/*
To plot event study graphs for my regressions
*/

* Target the college-age range
gen isage = (age>=18 & age<=25)
gen probablyincollege = (educ>=73 & educ<123)
gen targpop = isage*probablyincollege
drop if targpop==0

* I want only presidential election years
drop if ispres==0

* Create event study interaction terms
foreach a in 1992 2000 2004 2008 {
	gen _year`a'xhadmandate=(year==`a')*hadmandate
}

* Estimate the event study model
areg didvote _year* iswoman whiteshr isemployed ishisp i.year [w=vosuppwt] if targpop==1, absorb(statefip) cluster(statefip) robust

* Create event study coefficients and standard errors
gen coef=0
gen se=.

foreach a in 1992 2000 2004 2008 {
	replace coef=_b[_year`a'xhadmandate] if year==`a'
	replace se=_se[_year`a'xhadmandate] if year==`a'
}
sort year

* Keep limited set of variables
keep coef se year

* Confidence intervals
gen lower=coef-se*1.66
gen upper=coef+se*1.66
sort year

* Draw graphs
gr twoway (connected coef year, xline(1998) mcolor(blue) lcolor(blue)) ///
(rcap lower upper year, lcolor(blue)), scheme(s1color) ///
title("Voter Turnout Event Study", size(medlarge)) ///
plotregion(lcolor(none)) legend(off) ylabel(, grid) xtitle("year")
gr export figure2.png, as(png) replace


// gr twoway (rarea lower upper year, xline(1998) color(gray)) ///
// (connected coef year, msym(+) mcolor(black) lcolor(black)), scheme(s1color) ///
// title("Event study plot", size(medlarge)) ///
// plotregion(lcolor(none)) legend(off) ylabel(, grid) xtitle("year")
// gr export figure2alt.png, as(png) replace



cap log close
