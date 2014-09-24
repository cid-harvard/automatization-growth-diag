clear
set more off

****************************************************************************************************************************************
* PARAMETERS TO BE CHANGED BY THE USER:
* ORIGINAL DIRECTORY:
cd "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata\WDI"
* ORIGINAL DATABASE
use "wdi2013.dta", clear
* COUNTRY TO BE ANALYZED
local ctry PER
levelsof country if wbcode=="`ctry'", local(j) clean
* RESULTS DIRECTORY
cd "C:\Users\Luis Miguel\Dropbox\CID\Automatization Growth Diagnostics\Results"
capture mkdir `ctry'
global dir "C:\Users\Luis Miguel\Dropbox\CID\Automatization Growth Diagnostics\Results\\`ctry'"
cd "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata"
* VARIABLE TO BE USED
keep wbcode country year NY_GDP_PCAP_KD NY_GDP_PCAP_PP_KD SP_POP_TOTL
****************************************************************************************************************************************

* Elimination of non-countries: 38
* Arab World, Caribbean Small States, East Asia & Pacific (all income levels), East Asia & Pacific (developing only), East Asia & Pacific (IFC classification),
* Euro Area, Euope & Central Asia (all income levels), Europe & Central Asia (developing only), Europe & Central Asia (IFC classification), European Union,
* Heavily indebted poor countries (HIPC), High Income, High Income: OECD, High Income: nonOECD, Latin America & Caribbean (all income levels),
* Latin America & Caribbean (developing only), Latin America and the Caribbean (IFC classification), Least developed countries: UN classification,
* Low & middle income, Low income, Lower middle income, Middle East & North Africa (all income levels), Middle East & North Africa (developing only),
* Middle East and North Africa (IFC classification), Middle income, North America, Not classified, OECD members, Other small states, 
* Pacific island small states, Small states, South Asia, South Asia (IFC classification), Sub-Saharian Africa (IFC classification), 
* Sub-Saharian Africa (all income levels), Sub-Saharian Africa (developing only), Upper middle income, World
drop if wbcode=="ARB" | wbcode=="CSS" | wbcode=="EAS" | wbcode=="EAP" | wbcode=="CEA" | wbcode=="EMU" | wbcode=="ECS" | wbcode=="ECA" | wbcode=="CEU" /*
*/ | wbcode=="EUU" | wbcode=="HPC" | wbcode=="HIC" | wbcode=="OEC" | wbcode=="NOC"| wbcode=="LCN" | wbcode=="LAC" | wbcode=="CLA" | wbcode=="LDC" /*
*/ | wbcode=="LMY" | wbcode=="LIC" | wbcode=="LMC" | wbcode=="MEA" | wbcode=="MNA" | wbcode=="CME" | wbcode=="MIC" | wbcode=="NAC" | wbcode=="INX" /*
*/ | wbcode=="OED" | wbcode=="OSS" | wbcode=="PSS" | wbcode=="SST" | wbcode=="SAS" | wbcode=="CSA" | wbcode=="CAA" | wbcode=="SSF" | wbcode=="SSA" /*
*/ | wbcode=="UMC" | wbcode=="WLD"

* Elimination of small countries
gen n=0
replace n=1 if year==2012 & SP_POP_TOTL<1000000
bys wbcode: egen m=max(n)
drop if m==1
drop n m SP_POP_TOTL
sort country year

********************************************************
** Figure 1: Overall, ten, and five year growth rates **
********************************************************
rename NY_GDP_PCAP_KD gdppc
gen loggdppc=log(gdppc)				/* GDP per capita (constant 2005 US$) */
label var loggdppc "log(GDPPC)"
rename NY_GDP_PCAP_PP_KD gdppc2		/* GDP per capita, PPP (constant 2005 international $) */
gen loggdppc2=log(gdppc2)
label var loggdppc2 "log(GDPPC)"
label var year "Years"
* Statistics for Figure 1
foreach var of varlist gdppc loggdppc {
	summ `var' if wbcode=="`ctry'", d
		* Minimum
		scalar min`var'=r(min)
		local min`var': display %9.0fc  min`var'
		* Median
		scalar med`var'=r(p50)
		local med`var': display %9.0fc  med`var'
		*Maximum
		scalar max`var'=r(max)
		local max`var': display %9.0fc  max`var'
		* Range
		scalar range`var'=ceil((r(max)-r(min)+0.6)*5)
		local range`var': display %9.0fc  range`var'
	}
summ year if wbcode=="`ctry'" & loggdppc!=.
	* Minimum
	if r(min)==round(r(min),5) {
		scalar minyear5=r(min)
	}
	else {
		scalar minyear5=5*round((r(min)+2.5)/5)
	}	
	local minyear5: display %9.0fc  minyear5
	if r(min)==round(r(min),10) {
		scalar minyear10=r(min)
	}
	else {
		scalar minyear10=10*round((r(min)+5)/10)
	}
	local minyear10: display %9.0fc minyear10
	scalar minyear=r(min)
	local minyear: display %9.0fc minyear
	*Maximum
	scalar maxyear=r(max)
	local maxyear: display %9.0fc maxyear
summ year if wbcode=="`ctry'" & loggdppc2!=.
	* Minimum
	scalar minyear2=r(min)
	local minyear2: display %9.0fc minyear2
	*Maximum
	scalar maxyear2=r(max)
	local maxyear2: display %9.0fc maxyear2
* Overall growth rate and R2 for country
reg loggdppc year if wbcode=="`ctry'", robust
foreach x in max min {
	summ gdppc if wbcode=="`ctry'" & year==`=`x'year'
	scalar y`=`x'year'=r(mean)
}
scalar g_all=(((y`=maxyear'/y`=minyear')^(1/(`=maxyear'-`=minyear')))-1)*100
local g_all: display %2.1f g_all
scalar r2=e(r2)
local r2: display %3.2f r2
* Ten growth rates
forval x=`=minyear10'(10)`=maxyear' {
	summ gdppc if wbcode=="`ctry'" & year==`x'
	scalar y`x'=r(mean)
	summ gdppc if wbcode=="`ctry'" & year==`x'+10
	scalar y`=`x'+10'=r(mean)
	scalar g`x'=(((y`=`x'+10'/y`x')^(1/(`=`x'+10'-`x')))-1)*100
	local g`x': display %2.1f g`x'
}
* Five growth rates
forval x=`=minyear5'(5)`=maxyear' {
	summ gdppc if wbcode=="`ctry'" & year==`x'
	scalar y`x'=r(mean)
	summ gdppc if wbcode=="`ctry'" & year==`x'+5
	scalar y`=`x'+5'=r(mean)
	scalar g_`x'=(((y`=`x'+5'/y`x')^(1/(`=`x'+5'-`x')))-1)*100
	local g_`x': display %2.1f g_`x'
}
* Standard deviation of the annual log changes
gen g=100*((gdppc[_n]/gdppc[_n-1])-1) if wbcode[_n]==wbcode[_n-1]
tabstat g if wbcode=="`ctry'", s(sd) save
return list
matrix sd=r(StatTotal)
scalar sd=sd[1,1]
local sd: display %2.1f sd
* Figure 1
if `=maxyear'>=2010 {
	if `=minyear5'<=1960 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log, log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1962.5 "`g_1960'") text(`=minloggdppc-0.2' 1967.5 "`g_1965'") text(`=minloggdppc-0.2' 1972.5 "`g_1970'") /*
		*/ text(`=minloggdppc-0.2' 1977.5 "`g_1975'") text(`=minloggdppc-0.2' 1982.5 "`g_1980'") text(`=minloggdppc-0.2' 1987.5 "`g_1985'") /*
		*/ text(`=minloggdppc-0.2' 1992.5 "`g_1990'") text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") /*
		*/ text(`=minloggdppc-0.2' 2007.5 "`g_2005'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.4' 1965 "g{subscript:60s}: `g1960'") text(`=maxloggdppc+0.4' 1975 "g{subscript:70s}: `g1970'") /*
		*/ text(`=maxloggdppc+0.4' 1985 "g{subscript:80s}: `g1980'") text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") /*
		*/ text(`=maxloggdppc+0.4' 2005 "g{subscript:00s}: `g2000'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+3.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1960 & `=minyear5'<=1965 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1967.5 "`g_1965'") text(`=minloggdppc-0.2' 1972.5 "`g_1970'") text(`=minloggdppc-0.2' 1977.5 "`g_1975'") /*
		*/ text(`=minloggdppc-0.2' 1982.5 "`g_1980'") text(`=minloggdppc-0.2' 1987.5 "`g_1985'") text(`=minloggdppc-0.2' 1992.5 "`g_1990'") /*
		*/ text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc-0.2' 2007.5 "`g_2005'") /*
		*/ text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) /*
		*/ text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) text(`=maxloggdppc+0.4' 1975 "g{subscript:70s}: `g1970'") /*
		*/ text(`=maxloggdppc+0.4' 1985 "g{subscript:80s}: `g1980'") text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") /*
		*/ text(`=maxloggdppc+0.4' 2005 "g{subscript:00s}: `g2000'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+3.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1965 & `=minyear5'<=1970 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1972.5 "`g_1970'") text(`=minloggdppc-0.2' 1977.5 "`g_1975'") text(`=minloggdppc-0.2' 1982.5 "`g_1980'") /*
		*/ text(`=minloggdppc-0.2' 1987.5 "`g_1985'") text(`=minloggdppc-0.2' 1992.5 "`g_1990'") text(`=minloggdppc-0.2' 1997.5 "`g_1995'") /*
		*/ text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc-0.2' 2007.5 "`g_2005'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.4' 1975 "g{subscript:70s}: `g1970'") text(`=maxloggdppc+0.4' 1985 "g{subscript:80s}: `g1980'") /*
		*/ text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") text(`=maxloggdppc+0.4' 2005 "g{subscript:00s}: `g2000'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+3.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1970 & `=minyear5'<=1975 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1977.5 "`g_1975'") text(`=minloggdppc-0.2' 1982.5 "`g_1980'") text(`=minloggdppc-0.2' 1987.5 "`g_1985'") /*
		*/ text(`=minloggdppc-0.2' 1992.5 "`g_1990'") text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") /*
		*/ text(`=minloggdppc-0.2' 2007.5 "`g_2005'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.4' 1985 "g{subscript:80s}: `g1980'") text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") /*
		*/ text(`=maxloggdppc+0.4' 2005 "g{subscript:00s}: `g2000'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+2.5' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1975 & `=minyear5'<=1980 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1982.5 "`g_1980'") text(`=minloggdppc-0.2' 1987.5 "`g_1985'") text(`=minloggdppc-0.2' 1992.5 "`g_1990'") /*
		*/ text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc-0.2' 2007.5 "`g_2005'") /*
		*/ text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) /*
		*/ text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) text(`=maxloggdppc+0.4' 1985 "g{subscript:80s}: `g1980'") /*
		*/ text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") text(`=maxloggdppc+0.4' 2005 "g{subscript:00s}: `g2000'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+2.5' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1980 & `=minyear5'<=1985 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1987.5 "`g_1985'") text(`=minloggdppc-0.2' 1992.5 "`g_1990'") text(`=minloggdppc-0.2' 1997.5 "`g_1995'") /*
		*/ text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc-0.2' 2007.5 "`g_2005'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") text(`=maxloggdppc+0.4' 2005 "g{subscript:00s}: `g2000'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+2.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1985 & `=minyear5'<=1990 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1992.5 "`g_1990'") text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") /*
		*/ text(`=minloggdppc-0.2' 2007.5 "`g_2005'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") text(`=maxloggdppc+0.4' 2005 "g{subscript:00s}: `g2000'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+2.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
		else if `=minyear5'>1990 & `=minyear5'<=1995 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc-0.2' 2007.5 "`g_2005'") /*
		*/ text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) /*
		*/ text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) text(`=maxloggdppc+0.4' 2005 "g{subscript:00s}: `g2000'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+1.5' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
		else if `=minyear5'>1995 & `=minyear5'<=2000 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators")  /*
		*/ text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc-0.2' 2007.5 "`g_2005'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.4' 2005 "g{subscript:00s}: `g2000'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+1.5' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
		else if `=minyear5'>2000 & `=minyear5'<=2005 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 2007.5 "`g_2005'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+1.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
		else {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) /*
		*/ text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+1.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
}
else {
	if `=minyear5'<=1960 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1962.5 "`g_1960'") text(`=minloggdppc-0.2' 1967.5 "`g_1965'") text(`=minloggdppc-0.2' 1972.5 "`g_1970'") /*
		*/ text(`=minloggdppc-0.2' 1977.5 "`g_1975'") text(`=minloggdppc-0.2' 1982.5 "`g_1980'") text(`=minloggdppc-0.2' 1987.5 "`g_1985'") /*
		*/ text(`=minloggdppc-0.2' 1992.5 "`g_1990'") text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") /*
		*/ text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) /*
		*/ text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) text(`=maxloggdppc+0.4' 1965 "g{subscript:60s}: `g1960'") /*
		*/ text(`=maxloggdppc+0.4' 1975 "g{subscript:70s}: `g1970'") text(`=maxloggdppc+0.4' 1985 "g{subscript:80s}: `g1980'") /*
		*/ text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+3.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1960 & `=minyear5'<=1965 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1967.5 "`g_1965'") text(`=minloggdppc-0.2' 1972.5 "`g_1970'") text(`=minloggdppc-0.2' 1977.5 "`g_1975'") /*
		*/ text(`=minloggdppc-0.2' 1982.5 "`g_1980'") text(`=minloggdppc-0.2' 1987.5 "`g_1985'") text(`=minloggdppc-0.2' 1992.5 "`g_1990'") /*
		*/ text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.4' 1975 "g{subscript:70s}: `g1970'") text(`=maxloggdppc+0.4' 1985 "g{subscript:80s}: `g1980'") /*
		*/ text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+3.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1965 & `=minyear5'<=1970 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1972.5 "`g_1970'") text(`=minloggdppc-0.2' 1977.5 "`g_1975'") text(`=minloggdppc-0.2' 1982.5 "`g_1980'") /*
		*/ text(`=minloggdppc-0.2' 1987.5 "`g_1985'") text(`=minloggdppc-0.2' 1992.5 "`g_1990'") text(`=minloggdppc-0.2' 1997.5 "`g_1995'") /*
		*/ text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.4' 1975 "g{subscript:70s}: `g1970'") text(`=maxloggdppc+0.4' 1985 "g{subscript:80s}: `g1980'") /*
		*/ text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+3.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1970 & `=minyear5'<=1975 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1977.5 "`g_1975'") text(`=minloggdppc-0.2' 1982.5 "`g_1980'") text(`=minloggdppc-0.2' 1987.5 "`g_1985'") /*
		*/ text(`=minloggdppc-0.2' 1992.5 "`g_1990'") text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") /*
		*/ text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) /*
		*/ text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) text(`=maxloggdppc+0.4' 1985 "g{subscript:80s}: `g1980'") /*
		*/ text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+2.5' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1975 & `=minyear5'<=1980 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1982.5 "`g_1980'") text(`=minloggdppc-0.2' 1987.5 "`g_1985'") text(`=minloggdppc-0.2' 1992.5 "`g_1990'") /*
		*/ text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.4' 1985 "g{subscript:80s}: `g1980'") text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+2.5' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1980 & `=minyear5'<=1985 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1987.5 "`g_1985'") text(`=minloggdppc-0.2' 1992.5 "`g_1990'") text(`=minloggdppc-0.2' 1997.5 "`g_1995'") /*
		*/ text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+2.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
	else if `=minyear5'>1985 & `=minyear5'<=1990 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1992.5 "`g_1990'") text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") /*
		*/ text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) /*
		*/ text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) text(`=maxloggdppc+0.4' 1995 "g{subscript:90s}: `g1990'") /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+2.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
		else if `=minyear5'>1990 & `=minyear5'<=1995 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 1997.5 "`g_1995'") text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc' `=maxyear' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+1.5' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
		else if `=minyear5'>1995 & `=minyear5'<=2000 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc-0.2' 2002.5 "`g_2000'") text(`=minloggdppc' `=maxyear-1' "`mingdppc'" "Min", j(right)) /*
		*/ text(`=medloggdppc' `=maxyear-1' "`medgdppc'" "Med", j(right)) text(`=maxloggdppc' `=maxyear-1' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+1.5' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
		else if `=minyear5'>2000 & `=minyear5'<=2005 {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc' `=maxyear-1.0' "`mingdppc'" "Min", j(right)) text(`=medloggdppc' `=maxyear-1.0' "`medgdppc'" "Med", j(right)) /*
		*/ text(`=maxloggdppc' `=maxyear-1.0' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+1.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
		else {
		twoway line loggdppc year if wbcode=="`ctry'" & year>=`=minyear5', xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
		*/ ysc(range(`=minloggdppc-0.2'(0.2)`=maxloggdppc+0.6')) ylabel(#`rangeloggdppc') lwidth(medthick) ytitle(log(GDPPC)) || /*
		*/ lfit loggdppc year if wbcode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
		*/ subtitle("`j'") note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
		*/ text(`=minloggdppc' `=maxyear-1.0' "`mingdppc'" "Min", j(right)) text(`=medloggdppc' `=maxyear-1.0' "`medgdppc'" "Med", j(right)) /*
		*/ text(`=maxloggdppc' `=maxyear-1.0' "`maxgdppc'" "Max", j(right)) /*
		*/ text(`=maxloggdppc+0.2' `=minyear5+1.0' "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)
	}
}

* Exporting results into word document
gr export "$dir\figure1`ctry'.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'.doc", g("$dir\figure1`ctry'.png") replace

*******************************************************
** Figure 3: (ln) Annual growth rates and five year MA **
*******************************************************

preserve
drop if wbcode!="`ctry'"
* Creation of MA
tsset year
tssmooth ma ma=g, window(2 1 2)

*Format
label var g "Annual growth rate GDPPC"
format g %9.1fc

* Statistics for Figure 3
summ g if wbcode=="`ctry'", d
	* Minimum
	if r(min)<0 {
		if r(min)==round(r(min),1) {
			scalar ming=r(min)
		}
		else {
			scalar ming=round((r(min)-0.5))
		}	
	}
	else {
			if r(min)==round(r(min),1) {
			scalar ming=r(min)
		}
		else {
			scalar ming=round((r(min)+0.5))
		}	
	}
	local ming: display %9.0fc  ming
	*Maximum
	if r(max)==round(r(max),1) {
		scalar maxg=r(max)
	}
	else {
		scalar maxg=round((r(max)+0.5))
	}	
	local maxg: display %9.0fc  maxg
	* Range
	scalar rangeg=ceil(`=maxg'-`=ming')
	local rangeg': display %9.0fc  rangeg

*Figure 3
twoway scatter g year if wbcode=="`ctry'" || line ma year if wbcode=="`ctry'", lwidth(medthick) legend(off) ytitle("Annual growth rate GDPPC") yline(0, lp(dash) lc(black)) /*
*/ yline(2, lp(solid) lc(black)) yline(4, lp(dash) lc(black)) xlabel(`=minyear5'(5)`=maxyear') xsc(range(`=minyear5'(5)`=maxyear')) /*
* ylabel(`=ming'(2.0)`=maxg') ysc(range(`=ming'(2.0)`=maxg'))
*/ title("Yearly growth rates and five year Moving Average") subtitle("`j'") /*
*/ note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") 

* Exporting results into word document
gr export "$dir\figure3`ctry'.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'.doc", g("$dir\figure3`ctry'.png") append

* Volatility = Number of times the MA crosses the 4% and 0% lines
count if (ma[_n-1]<0.0 & ma[_n]>0.0) | (ma[_n-1]>0.0 & ma[_n]<0.0) | (ma[_n-1]<4.0 & ma[_n]>4.0) | (ma[_n-1]>4.0 & ma[_n]<4.0)
scalar crossing=r(N)
restore

*******************************************************
** Figure 4: Distribution of all 8 year growth rates **
*******************************************************
* Region
gen region=.
* South America
	* Argentina, Bolivia, Brazil, Chile, Colombia, Ecuador, Guyana, Paraguay, Peru, Uruguay, Venezuela
foreach x in ARG BOL BRA CHL COL ECU GUY PRY PER URY VEN {
	replace region=1 if wbcode=="`x'"
}
* Central America & Caribbean
	* Antigua y Barbuda, Aruba, Bahamas, Barbados, Belize, Cayman Islands, Costa Rica, Cuba, Curacao, Dominica, 
	* Dominican Rep., El Salvador, Grenada, Guatemala, Haiti, Honduras, Jamaica, Mexico, Nicaragua, Panama, Puerto Rico,
	* Sint Maarten (Dutch part), St. Kitts and Nevis, St. Lucia, St. Martin (French part), St. Vincent and the Grenadines, Suriname, Trinidad and Tobago, 
	* Turks and Caicos Islands, Virgin Islands (U.S.)
foreach x in ATG ABW BHS BRB BLZ CYM CRI CUB CUW DMA DOM SLV GRD GTM HTI HND JAM MEX NIC PAN PRI SXM KNA LCA MAF VCT SUR /*
*/ TTO TCA VIR {
	replace region=2 if wbcode=="`x'"
}
* North-America: Bermuda, Canada, United States
foreach x in BMU CAN USA {
	replace region=2 if wbcode=="`x'"
}
* Central Europe (former non-communist): Austria, Germany, Liechtenstein, Luxemburg, Switzerland
foreach x in AUT DEU LIE LUX CHE {
		replace region=3 if wbcode=="`x'"
}
* Central Europe (former Communist): Croatia, Czech Rep., Hungary, Poland, Slovak Rep., Slovenia
foreach x in HRV CZE HUN POL SVK SVN {
		replace region=4 if wbcode=="`x'"
}
* North Europe: Denmark, Faeroe Islands, Finland, Greenland, Iceland, Norway, Sweden
foreach x in DNK FIN FRO GRL ISL NOR SWE {
	replace region=3 if wbcode=="`x'"
}
* South Europe: Andorra, Italy, Malta, Portugal, San Marino, Spain
foreach x in ADO ITA MLT PRT SMR ESP {
	replace region=3 if wbcode=="`x'"
}
* West Europe: Belgium, Channel Islands, France, Isle of Man, Ireland, Monaco, Netherlands, United Kingdom
foreach x in BEL CHI FRA IMY IRL MCO NLD GBR {
	replace region=3 if wbcode=="`x'"
}
* Southeast Europe (former non-Communist): Cyprus, Greece
foreach x in CYP GRC  {
	replace region=3 if wbcode=="`x'"
}
* Southeast Europe (former Communist): Albania, Bosnia and Herzegovina, Bulgaria, Kosovo, Macedonia, Moldova, Montenegro, Romania, Serbia
foreach x in ALB BIH BGR KSV MKD MDA MNE ROM SRB {
	replace region=4 if wbcode=="`x'"
}
* Post-Soviet States: Armenia, Azerbaijan, Belarus, Estonia, Georgia, Kazakhstan, Kyrgyzstan, Latvia, Lithuania, Moldova, Russia, Tajikistan, Turkmenistan, 
*					  Ukraine, Uzbekistan
foreach x in ARM AZE BLR EST GEO KAZ KGZ LVA LTU MDA RUS TJK TKM UKR UZB {
	replace region=4 if wbcode=="`x'"
}
* Middle East & North Africa: Algeria, Bahrain, Djibouti, Egypt, Israel, Iran, Iraq, Jordan, Kuwait, Lebanon, Libya, Morocco, Oman, Qatar, Saudi Arabia, Syria, 
*							  Tunisia, Turkey, United Arab Emirates, West Bank and Gaza, Yemen
foreach x in DZA BHR DJI EGY ISR IRN IRQ JOR KWT LBN LBY MAR OMN QAT SAU SYR TUN TUR ARE WBG YEM {
	replace region=5 if wbcode=="`x'"
}
* East and South East Asia: China, Hong Kong, Japan, Macau, Mongolia, North Korea, South Korea
* 							Brunei, Cambodia, Indonesia, Laos, Malaysia, Myanmar(Burma), Philippines, Singapore, Thailand, Vietnam
foreach x in CHN HKG JPN MAC MNG PRK KOR BRN KHM IDN LAO MYS MMR PHL SGP THA VNM {
	replace region=6 if wbcode=="`x'"
}
* South Asia: Afghanistan, Bangladesh, Bhutan, India, Maldives, Nepal, Pakistan, Sri Lanka
foreach x in AFG BGD BTN IND MDV NPL PAK LKA {
	replace region=7 if wbcode=="`x'"
}
* Sub-Saharian Africa: Angola, Benin, Botswana, Burkina Faso, Burundi, Cape Verde, Cameroon, Central African Rep., Chad, Comoros, Dem. Rep. Congo, Rep. Congo,
* 					   Cote d'Ivoire, Equatorial Guinea, Eritrea, Ethiopia, Gabon, Gambia, Ghana, Guinea, Guinea-Bissau, Kenya, Lesotho, Liberia, Madagascar,
*					   Malawi, Mali, Mauritania, Mauritius, Mozambique, Namibia, Niger, Nigeria, Rwanda, Sao Tome and Principe, Senegal, Seychelles, 
*					   Sierra Leone, Somalia, South Africa, South Sudan, Sudan, Swaziland, Tanzania, Togo, Uganda, Zambia, Zimbabwe
foreach x in AGO BEN BWA BFA BDI CPV CMR CAF TCD COM COD ZAR COG CIV GNQ ERI ETH GAB GMB GHA GIN GNB KEN LSO LBR MDG MWI MLI MRT MUS MOZ NAM NER NGA RWA STP SEN /*
*/ SYC SLE SOM ZAF SSD SDN SWZ TZA TGO UGA ZMB ZWE {
	replace region=8 if wbcode=="`x'"
}
* South Pacific: American Samoa, Australia, Fiji, French Polynesia, Guam, Kiribati, Marshall Islands, Micronesia, New Caledonia, New Zealand, 
*				 Northern Mariana Islands, Palau, Papua New Guinea, Samoa, Solomon Islands, Timor-Leste, Tonga, Tuvalu, Vanuatu
foreach x in ASM AUS FJI PYF GUM KIR MHL FSM NCL NZL MNP PLW PNG WSM SLB TMP TON TUV VUT {
	replace region=9 if wbcode=="`x'"
}
label def region 1"South America" 2"North and Central America & the Caribbean" 3"Former Non-Communist Europe" 4"Former-Communist Europe" /*
*/ 5"Middle East & North Africa" 6"East & Southeast Asia" 7"South Asia" 8"Sub-Saharian Africa" 9"South Pacific"
label val region region

* 8 year growth rate (backward)
sort wbcode year
gen g2=100*(((gdppc[_n]/gdppc[_n-7])^(1/7))-1) if wbcode[_n]==wbcode[_n-7]
gen g3=g2 if wbcode=="`ctry'"
summ year if g2!=.
	scalar minyear3=r(min)
	scalar maxyear3=r(max)
summ year if g3!=.
	scalar minyear4=r(min)
	scalar maxyear4=r(max)
* Categories
gen bin=.
replace bin=1 if g2<-2.0
replace bin=2 if g2>=-2.0 & g2<0.0
replace bin=3 if g2>=0.0 & g2<2.0
replace bin=4 if g2>=2.0 & g2<4.0
replace bin=5 if g2>=4.0 & g2<6.0
replace bin=6 if g2>=6.0 & gdppc[_n]!=. & gdppc[_n-7]!=.
label var bin "Growth categories"
replace g2=. if wbcode=="`ctry'"

* Rest of the world
gen ctry=0
replace ctry=1 if wbcode=="`ctry'"

* In which region the country is?
summ region if wbcode=="`ctry'"
scalar region`ctry'=r(mean)
decode region, gen(region3)
levelsof region3 if wbcode=="`ctry'", local(k) clean

* Region
gen region2=.
replace region2=1 if wbcode=="`ctry'"
replace region2=0 if region==`=region`ctry'' & wbcode!="`ctry'"

* Frequencies (ctry)
gen n=1 if bin!=.
bys ctry: egen total=total(n)
gen freq=n/total
preserve
	collapse (sum) n [pw=freq], by(bin ctry)
	summ n
	scalar maxfreq=round(r(max)+0.05,0.1)
restore

* Figure 4
graph bar (count) g2 g3 [pw=freq], over(bin) ytitle("Fraction of growth rates in category") /*
*/ legend(label(1 "Rest of countries") label(2 "`j'")) title("Distribution of all 8 year growth rates, `=max(`=minyear3-7',`=minyear4-7')'-`=min(`=maxyear3',`=maxyear4')'") subtitle("`j' vs. world") /*
*/  note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") ylabel(, format(%9.1fc)) /*
*/ text(`=maxfreq' 7 "g<-2.0") text(`=maxfreq' 23 "-2.0<g<0.0") text(`=maxfreq' 41 "0.0<g<2.0") /*
*/ text(`=maxfreq' 58 "2.0<g<4.0") text(`=maxfreq' 75 "4.0<g<6.0") text(`=maxfreq' 90 "g>6.0") /*
*/ text(`=maxfreq-0.1' 85 "Average growth: `g_all'")

* Exporting results into word document
gr export "$dir\figure4`ctry'.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'.doc", g("$dir\figure4`ctry'.png") append

* Frequencies (region2)
drop n total freq
scalar drop maxfreq minyear3 maxyear3
gen n=1 if bin!=.
bys region2: egen total=total(n)
gen freq=n/total
preserve
	collapse (sum) n [pw=freq], by(bin region2)
	summ n
	scalar maxfreq=round(r(max)+0.05,0.1)
restore

preserve
drop if region2==.
summ year if g2!=.
	scalar minyear3=r(min)
	scalar maxyear3=r(max)
* Figure 4 (EXTRA)
graph bar (count) g2 g3 [pw=freq], over(bin) ytitle("Fraction of growth rates in category") /*
*/ legend(label(1 "Rest of countries in `k'") label(2 "`j'")) title("Distribution of all 8 year growth rates, `=max(`=minyear3-7',`=minyear4-7')'-`=min(`=maxyear3',`=maxyear4')'") subtitle("`j' vs. `k'") /*
*/  note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") ylabel(, format(%9.1fc)) /*
*/ text(`=maxfreq' 7 "g<-2.0") text(`=maxfreq' 23 "-2.0<g<0.0") text(`=maxfreq' 41 "0.0<g<2.0") /*
*/ text(`=maxfreq' 58 "2.0<g<4.0") text(`=maxfreq' 75 "4.0<g<6.0") text(`=maxfreq' 90 "g>6.0") /*
*/ text(`=maxfreq-0.1' 85 "Average growth: `g_all'")

* Exporting results into word document
gr export "$dir\figure4b`ctry'.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'.doc", g("$dir\figure4b`ctry'.png") append
restore

**************************************************
** Figure 7: Growth Accelerations and Collapses **
**************************************************	

* 8 year growth rate (forward)
sort wbcode year
gen g4=100*(((gdppc[_n+7]/gdppc[_n])^(1/7))-1) if wbcode[_n+7]==wbcode[_n]

* Change in growth rate
gen delta=g4[_n]-g4[_n-7] if wbcode[_n+7]==wbcode[_n]

* Aceleration
gen accel=0
replace accel=1 if g4>=3.5 & delta>=2.0 & gdppc[_n+7]>=max(gdppc[_n],gdppc[_n+1],gdppc[_n+2],gdppc[_n+3],gdppc[_n+4],gdppc[_n+5],gdppc[_n+6]) /*
*/ & gdppc[_n+7]!=. & gdppc[_n]!=.

* Selecting the acceleration
gen accel2=1 if accel[_n]==1 & gdppc[_n]>gdppc[_n-1] & gdppc[_n]<gdppc[_n+1]
gen accel3=1 if accel2==1 & accel2[_n-1]!=1 & accel2[_n-2]!=1 & accel2[_n-3]!=1 & accel2[_n-4]!=1 & accel2[_n-5]!=1 & accel2[_n-6]!=1 & accel2[_n-7]!=1
drop accel2
rename accel3 accel2

* Deacceleration
gen deaccel=0
replace deaccel=1 if g4<=1.0 & delta<=-2.0

* Selecting the deacceleration
gen deaccel2=1 if deaccel==1 & deaccel[_n-1]!=1 & deaccel[_n-2]!=1 & deaccel[_n-3]!=1 & deaccel[_n-4]!=1 & deaccel[_n-5]!=1 & deaccel[_n-6]!=1 & deaccel[_n-7]!=1

* Defining and counting the thresholds
gen milestone=1 if (deaccel2==1 | accel2==1) & wbcode=="`ctry'"
count if milestone==1
scalar number_milestones=r(N)
if `=number_milestones'>0 {
	* Capturing the thresholds
	tab year if milestone==1, matrow(milestone)
	forval x=1/`=number_milestones' {
		scalar milestone`x'=milestone[`x',1]
	}

	* Length of periods (and halves)
	scalar length1=`=milestone1'-`=minyear'
	scalar half1=`=`=length1'/2'
	forval x=2/`=number_milestones' {
		scalar length`x'=`=milestone`x''-`=milestone`=`x'-1''
		scalar half`x'=`=`=length`x''/2'
	}
	scalar length`=`=number_milestones'+1'=`=maxyear'-`=milestone`=number_milestones''
	scalar half`=`=number_milestones'+1'=`=`=length`=`=number_milestones'+1''/2'
}
else {
	* Capturing the thresholds
	scalar milestone1=`=maxyear'
	* Length of periods (and halves)
	scalar length1=`=milestone1'-`=minyear'
	scalar half1=`=`=length1'/2'
}

* Calculation of GDPpc
summ gdppc if year==`=minyear' & wbcode=="`ctry'"
scalar y`=minyear'=r(mean)
if `=number_milestones'>0 {
	forval x=1/`=number_milestones' {
		summ gdppc if year==`=milestone`x'' & wbcode=="`ctry'"
		scalar y`=milestone`x''=r(mean)
	}
}
summ gdppc if year==`=maxyear' & wbcode=="`ctry'"
scalar y`=maxyear'=r(mean)

* Calculation of growth rates
scalar growth_1=(((y`=milestone1'/y`=minyear')^(1/(`=length1')))-1)*100
local growth_1: display %2.1f growth_1
if `=number_milestones'>0 {
	forval x=2/`=number_milestones' {
		scalar growth_`x'=(((y`=milestone`x''/y`=milestone`=`x'-1'')^(1/(`=length`x'')))-1)*100
		local growth_`x': display %2.1f growth_`x'
	}
	scalar growth_`=`=number_milestones'+1'=(((y`=maxyear'/y`=milestone`=number_milestones'')^(1/(`=length`=`=number_milestones'+1'')))-1)*100
	local growth_`=`=number_milestones'+1': display %2.1f growth_`=`=number_milestones'+1'
}

* Calculation of accelerations
if `=number_milestones'>0 {
	forval x=2/`=`=number_milestones'+1' {
		scalar delta_`x'=growth_`x'-growth_`=`x'-1'
		local delta_`x': display %2.1f delta_`x'
	}
}
* Max loggdppc
gen max_loggdppc=`=maxloggdppc' if wbcode=="`ctry'"

* Calculation of points to draw the scalars
scalar year1=`=minyear'+`=half1'
if `=number_milestones'>0 {
	forval x=2/`=`=number_milestones'+1' {
		scalar year`x'=`=milestone`=`x'-1''+`=half`x''
	}
}

* Figure 7
if `=number_milestones'==1 {
	twoway line loggdppc year if wbcode=="`ctry'", lwidth(medthick) || /*
	*/ spike max_loggdppc year if wbcode=="`ctry'" & milestone==1, lcolor(gs8) /*
	*/ xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) /*
	*/ ysc(range(`=minloggdppc'(0.2)`=maxloggdppc')) ytitle(log(GDPPC)) /*
	*/ legend(off) title("Growth Accelerations and Deaccelerations") subtitle("`j'") /*
	*/ note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
	*/ text(`=maxloggdppc' `=year1' "g{subscript:1}:`growth_1'" "") /*
	*/ text(`=maxloggdppc' `=year2' "g{subscript:2}:`growth_2'" "{&Delta}g:`delta_2'")
}
else if `=number_milestones'==2 {
	twoway line loggdppc year if wbcode=="`ctry'", lwidth(medthick) || /*
	*/ spike max_loggdppc year if wbcode=="`ctry'" & milestone==1, lcolor(gs8) /*
	*/ xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) /*
	*/ ysc(range(`=minloggdppc'(0.2)`=maxloggdppc')) ytitle(log(GDPPC)) /*
	*/ legend(off) title("Growth Accelerations and Deaccelerations") subtitle("`j'") /*
	*/ note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
	*/ text(`=maxloggdppc' `=year1' "g{subscript:1}:`growth_1'" "") /*
	*/ text(`=maxloggdppc' `=year2' "g{subscript:2}:`growth_2'" "{&Delta}g:`delta_2'") /*
	*/ text(`=maxloggdppc' `=year3' "g{subscript:3}:`growth_3'" "{&Delta}g:`delta_3'")
}
else if `=number_milestones'==3 {
	twoway line loggdppc year if wbcode=="`ctry'", lwidth(medthick) || /*
	*/ spike max_loggdppc year if wbcode=="`ctry'" & milestone==1, lcolor(gs8) /*
	*/ xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) /*
	*/ ysc(range(`=minloggdppc'(0.2)`=maxloggdppc')) ytitle(log(GDPPC)) /*
	*/ legend(off) title("Growth Accelerations and Collapses") subtitle("`j'") /*
	*/ note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
	*/ text(`=maxloggdppc' `=year1' "g{subscript:1}:`growth_1'") /*
	*/ text(`=maxloggdppc' `=year2' "g{subscript:2}:`growth_2'" "{&Delta}g:`delta_2'") /*
	*/ text(`=maxloggdppc' `=year3' "g{subscript:3}:`growth_3'" "{&Delta}g:`delta_3'") /*
	*/ text(`=maxloggdppc' `=year4' "g{subscript:4}:`growth_4'" "{&Delta}g:`delta_4'")
}
else if `=number_milestones'==4 {
	twoway line loggdppc year if wbcode=="`ctry'", lwidth(medthick) || /*
	*/ spike max_loggdppc year if wbcode=="`ctry'" & milestone==1, lcolor(gs8) /*
	*/ xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) /*
	*/ ysc(range(`=minloggdppc'(0.2)`=maxloggdppc')) ytitle(log(GDPPC)) /*
	*/ legend(off) title("Growth Accelerations and Collapses") subtitle("`j'") /*
	*/ note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
	*/ text(`=maxloggdppc' `=year1' "g{subscript:1}:`growth_1'" "") /*
	*/ text(`=maxloggdppc' `=year2' "g{subscript:2}:`growth_2'" "{&Delta}g:`delta_2'") /*
	*/ text(`=maxloggdppc' `=year3' "g{subscript:3}:`growth_3'" "{&Delta}g:`delta_3'") /*
	*/ text(`=maxloggdppc' `=year4' "g{subscript:4}:`growth_4'" "{&Delta}g:`delta_4'") /*
	*/ text(`=maxloggdppc' `=year5' "g{subscript:5}:`growth_5'" "{&Delta}g:`delta_5'")
}
else if `=number_milestones'==5 {
	twoway line loggdppc year if wbcode=="`ctry'", lwidth(medthick) || /*
	*/ spike max_loggdppc year if wbcode=="`ctry'" & milestone==1, lcolor(gs8) /*
	*/ xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) /*
	*/ ysc(range(`=minloggdppc'(0.2)`=maxloggdppc')) ytitle(log(GDPPC)) /*
	*/ legend(off) title("Growth Accelerations and Collapses") subtitle("`j'") /*
	*/ note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
	*/ text(`=maxloggdppc' `=year1' "g{subscript:1}:`growth_1'" "") /*
	*/ text(`=maxloggdppc' `=year2' "g{subscript:2}:`growth_2'" "{&Delta}g:`delta_2'") /*
	*/ text(`=maxloggdppc' `=year3' "g{subscript:3}:`growth_3'" "{&Delta}g:`delta_3'") /*
	*/ text(`=maxloggdppc' `=year4' "g{subscript:4}:`growth_4'" "{&Delta}g:`delta_4'") /*
	*/ text(`=maxloggdppc' `=year5' "g{subscript:5}:`growth_5'" "{&Delta}g:`delta_5'") /*
	*/ text(`=maxloggdppc' `=year6' "g{subscript:6}:`growth_6'" "{&Delta}g:`delta_6'")
}
else if `=number_milestones'==6 {
	twoway line loggdppc year if wbcode=="`ctry'", lwidth(medthick) || /*
	*/ spike max_loggdppc year if wbcode=="`ctry'" & milestone==1, lcolor(gs8) /*
	*/ xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) /*
	*/ ysc(range(`=minloggdppc'(0.2)`=maxloggdppc')) ytitle(log(GDPPC)) /*
	*/ legend(off) title("Growth Accelerations and Collapses") subtitle("`j'") /*
	*/ note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
	*/ text(`=maxloggdppc' `=year1' "g{subscript:1}:`growth_1'" "") /*
	*/ text(`=maxloggdppc' `=year2' "g{subscript:2}:`growth_2'" "{&Delta}g:`delta_2'") /*
	*/ text(`=maxloggdppc' `=year3' "g{subscript:3}:`growth_3'" "{&Delta}g:`delta_3'") /*
	*/ text(`=maxloggdppc' `=year4' "g{subscript:4}:`growth_4'" "{&Delta}g:`delta_4'") /*
	*/ text(`=maxloggdppc' `=year5' "g{subscript:5}:`growth_5'" "{&Delta}g:`delta_5'") /*
	*/ text(`=maxloggdppc' `=year6' "g{subscript:6}:`growth_6'" "{&Delta}g:`delta_6'") /*
	*/ text(`=maxloggdppc' `=year7' "g{subscript:7}:`growth_7'" "{&Delta}g:`delta_7'")
}
else {
	twoway line loggdppc year if wbcode=="`ctry'", lwidth(medthick) || /*
	*/ spike max_loggdppc year if wbcode=="`ctry'" & milestone==1, lcolor(gs8) /*
	*/ xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) /*
	*/ ysc(range(`=minloggdppc'(0.2)`=maxloggdppc')) ytitle(log(GDPPC)) /*
	*/ legend(off) title("Growth Accelerations and Collapses") subtitle("`j'") /*
	*/ note("Note: GDP per capita (constant 2005 US$), log" "Data source:  World Development Indicators") /*
	*/ text(`=maxloggdppc' `=year1' "g{subscript:1}:`growth_1'" "")
}

* Exporting results into word document
gr export "$dir\figure7`ctry'.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'.doc", g("$dir\figure7`ctry'.png") append

************************************************
** Figure 2: Initial and Final level of GDPPC **
************************************************

* Reshape and labels
keep region year wbcode country loggdppc gdppc loggdppc2 gdppc2 g
reshape wide loggdppc gdppc loggdppc2 gdppc2 g, i(wbcode) j(year)
label var loggdppc2`=maxyear2' "Level of GDPPC (log), `=maxyear'"
label var loggdppc2`=minyear2' "Level of GDPPC (log), `=minyear'"
summ loggdppc2`=minyear2'
summ loggdppc2`=maxyear2'

* In which region the country is?
summ region if wbcode=="`ctry'"
scalar region`ctry'=r(mean)

* First value
summ gdppc2`=minyear2' if wbcode=="`ctry'"
scalar y_min=r(mean)
local y_min: display %9.0fc y_min

* Last value
summ gdppc2`=maxyear2' if wbcode=="`ctry'"
scalar y_max=r(mean)
local y_max: display %9.0fc y_max

* Ratio
scalar ratio=y_max/y_min
local ratio: display %9.1fc ratio

* Percentiles
foreach x in min max {
	xtile pct`=`x'year2'=gdppc2`=`x'year2' if gdppc2`=`x'year2'!=., nq(100)
	summ pct`=`x'year2' if wbcode=="`ctry'"
	scalar pct_`x'=r(mean)
	local pct_`x': display %9.1fc pct_`x'
}

* Ranks
foreach x in min max {
	count if gdppc2`=`x'year2'!=.
	scalar n_`x'=r(N)
	gsort -gdppc2`=`x'year2'
	gen rank_`x'=_n if gdppc2`=`x'year2'!=.
	summ rank_`x' if wbcode=="`ctry'"
	scalar rank`=`x'year2'=r(mean)
}

* Figure 2
twoway scatter loggdppc2`=maxyear2' loggdppc2`=minyear2' || /*
*/ scatter loggdppc2`=maxyear2' loggdppc2`=minyear2' if region==`=region`ctry'' & wbcode!="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(orange) mlabcolor(orange) mlabposition(3) || /*
*/ scatter loggdppc2`=maxyear2' loggdppc2`=minyear2' if wbcode=="`ctry'", mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3) || /*
*/ function y=x, range(5 11) lc(gs8) || function y=x+1, range(5 10.5) lc(gs8) || function y=x+2, range(5 10) lc(gs8) legend(off) /*
*/ xsc(range(5(1)11)) xlabel(5(1)12) ysc(range(5(1)12)) ylabel(5(1)12) text(11 11.5 "0% growth") text(11.5 11 "2% growth") text(12 10.5 "4% growth") /*
*/ ytitle("Level of GDPPC (log), `=maxyear2'") xtitle("Level of GDPPC (log), `=minyear2'") title("Initial and final level of GDP per capita") subtitle("`j'") /*
*/ note("Note: GDP per capita, PPP (constant 2005 international $), log" "Data source: World Development Indicators") /*
*/ text(6.8 8.5 "`=minyear2'" "`=maxyear2'" "Ratio") text(7.6 9.07 "`ctry'" ) text(7.0 9 "`y_min'" "`y_max'") text(6.4 8.85 "`ratio'") /*
*/ text(7.6 9.7 "Rank") text(7 9.8 "`=rank`=minyear2''/`=n_min'" "`=rank`=maxyear2''/`=n_max'", j(left)) /*
*/ text(7.6 10.7 "Percentile") text(7 10.3 "`pct_min'" "`pct_max'") 

* Exporting results into word document
gr export "$dir\figure2`ctry'.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'.doc", g("$dir\figure2`ctry'.png") append

scalar drop _all
macro drop _all
