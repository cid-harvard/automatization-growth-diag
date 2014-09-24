clear
set more off

****************************************************************************************************************************************
* PARAMETERS TO BE CHANGED BY THE USER:
* DIRECTORY:
cd "C:\Users\Luis Miguel\Documents\Bases de Datos\Penn World Tables\pwt80"
* ORIGINAL DATABASE
use "pwt80.dta", clear
* COUNTRY TO BE ANALYZED
local ctry VEN
levelsof country if countrycode=="`ctry'", local(j) clean
* VARIABLE TO BE USED
keep countrycode country year rgdpe pop 
****************************************************************************************************************************************

********************************************************
** Figure 1: Overall, ten, and five year growth rates **
********************************************************
gen gdppc=rgdpe/pop
gen lngdppc=ln(gdppc)
label var lngdppc "Ln(GDPPC)"
* Statistics for Figure 1
foreach var of varlist gdppc lngdppc {
	summ `var' if countrycode=="`ctry'", d
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
summ year if countrycode=="`ctry'" & lngdppc!=.
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
	local minyear10: display %9.0fc  minyear10
	*Maximum
	scalar maxyear=r(max)
	local maxyear: display %9.0fc  maxyear
* Overall growth rate and R2 for country
reg lngdppc year if countrycode=="`ctry'", robust
scalar g_all=_b[year]*100
local g_all: display %2.1f g_all
scalar r2=e(r2)
local r2: display %3.2f r2
* Ten growth rates
forval x=`=minyear10'(10)`=maxyear' {
	qui reg lngdppc year if countrycode=="`ctry'" & year>=`x' & year<=`x'+10, robust
	scalar g`x'=_b[year]*100
	local g`x': display %2.1f g`x'
}
* Five growth rates
forval x=`=minyear5'(5)`=maxyear' {
	qui reg lngdppc year if countrycode=="`ctry'" & year>=`x' & year<=`x'+5, robust
	scalar g_`x'=_b[year]*100
	local g_`x': display %2.1f g_`x'
}
* Standard deviation of the annual log changes
gen g=100*(lngdppc[_n]-lngdppc[_n-1]) if countrycode[_n]==countrycode[_n-1]
tabstat g if countrycode=="`ctry'", s(sd) save
return list
matrix sd=r(StatTotal)
scalar sd=sd[1,1]
local sd: display %2.1f sd
* Figure 1
twoway line lngdppc year if countrycode=="`ctry'", xlabel(1950(5)2010) xsc(range(1950(5)2011)) /*
*/ ysc(range(`=minlngdppc-0.2'(0.2)`=maxlngdppc+0.6')) ylabel(#`rangelngdppc') lwidth(medthick) ytitle(Ln(GDPPC)) || /*
*/ lfit lngdppc year if countrycode=="`ctry'", legend(off) lpattern(dash) lcolor(black) title("Overall, ten, and five year growth rates") /*
*/ subtitle("`j'") note("Data source:  Penn World Tables 8.0") text(`=minlngdppc-0.2' 1952.5 "`g_1950'") text(`=minlngdppc-0.2' 1957.2 "`g_1955'") /*
*/ text(`=minlngdppc-0.2' 1962.5 "`g_1960'") text(`=minlngdppc-0.2' 1967.5 "`g_1965'") text(`=minlngdppc-0.2' 1972.5 "`g_1970'") /*
*/ text(`=minlngdppc-0.2' 1977.5 "`g_1975'") text(`=minlngdppc-0.2' 1982.5 "`g_1980'") text(`=minlngdppc-0.2' 1987.5 "`g_1985'") /*
*/ text(`=minlngdppc-0.2' 1992.5 "`g_1990'") text(`=minlngdppc-0.2' 1997.5 "`g_1995'") text(`=minlngdppc-0.2' 2002.5 "`g_2000'") /*
*/ text(`=minlngdppc-0.2' 2007.5 "`g_2005'") text(`=minlngdppc' 2010 "`mingdppc'" "Min", j(right)) text(`=medlngdppc' 2010 "`medgdppc'" "Med", j(right)) /*
*/ text(`=maxlngdppc' 2010 "`maxgdppc'" "Max", j(right)) text(`=maxlngdppc+0.4' 1955 "g{subscript:50s}: `g1950'") /*
*/ text(`=maxlngdppc+0.4' 1965 "g{subscript:60s}: `g1960'") text(`=maxlngdppc+0.4' 1975 "g{subscript:70s}: `g1970'") /*
*/ text(`=maxlngdppc+0.4' 1985 "g{subscript:80s}: `g1980'") text(`=maxlngdppc+0.4' 1995 "g{subscript:90s}: `g1990'") /*
*/ text(`=maxlngdppc+0.4' 2005 "g{subscript:00s}: `g2000'") /*
*/ text(`=maxlngdppc' 1955 "g: `g_all'" "R{superscript:2}: `r2'" "{&sigma}{subscript:{&Delta}y}: `sd'", j(left)) scale(0.9)


************************************************
** Figure 2: Initial and Final level of GDPPC **
************************************************

* DEVELOPING REGIONS (according to the World Bank)
* East Asia and Pacific
	* Available 10: Cambodia, China, Fiji, Indonesia, Laos, Malaysia, Mongolia, Philippines, Thailand, Vietnam
	* Missing 14: American Samoa, Kiribati, North Korea, Marshall Islands, Micronesia, Myanmar(Burma), Palau, Papua New Guinea, Samoa,
				* Solomon Islands, Timor-Leste, Tonga, Tuvalu, Vanuatu
gen east_asia=0
replace east_asia=1 if countrycode=="KHM" | countrycode=="CHN" | countrycode=="FJI" | countrycode=="IDN" | countrycode=="LAO" | countrycode=="MYS" /*
*/ | countrycode=="MNG" | countrycode=="PHL" | countrycode=="THA" | countrycode=="VNM"
* Europe and Central Asia
	* Available 19: Albania, Armenia, Azerbaijan, Belarus, Bosnia and Herzegovina, Bulgaria, Georgia, Kazakhstan, Kyrgyz Rep.(Kyrgyzstan),
				* Macedonia, Moldova, Montenegro, Rumania, Serbia, Tajikistan, Turkey, Turkmenistan, Ukraine, Uzbekistan
	* Missing 1: Kosovo
gen europe=0
replace europe=1 if countrycode=="ALB" | countrycode=="ARM" | countrycode=="AZE" | countrycode=="BLR" | countrycode=="BIH" | countrycode=="BGR" /*
*/ | countrycode=="GEO" | countrycode=="KAZ" | countrycode=="KGZ" | countrycode=="MKD" | countrycode=="MDA" | countrycode=="MNE" | countrycode=="ROU" /*
*/ | countrycode=="SRB" | countrycode=="TJK" | countrycode=="TUR" | countrycode=="TKM" | countrycode=="UKR" | countrycode=="UZB"
* Latin America and Caribbean
	* Available 22: Argentina, Belize, Bolivia, Brazil, Colombia, Costa Rica, Dominica, Dominican Rep., Ecuador, El Salvador, Grenada, Guatemala, Honduras,
				* Jamaica, Mexico, Panama, Paraguay, Peru, St. Lucia, St. Vincent and the Grenadines, Suriname, Venezuela
	* Missing 4: Cuba, Guyana, Haiti, Nicaragua
gen latam=0
replace latam=1 if countrycode=="ARG" | countrycode=="BLZ" | countrycode=="BOL" | countrycode=="BRA" | countrycode=="COL" | countrycode=="CRI" /*
*/ | countrycode=="DMA" | countrycode=="DOM" | countrycode=="ECU" | countrycode=="SLV" | countrycode=="GRD" | countrycode=="GTM" | countrycode=="HND" /*
*/ | countrycode=="JAM" | countrycode=="MEX" | countrycode=="PAN" | countrycode=="PRY" | countrycode=="PER" | countrycode=="LCA" | countrycode=="VCT" /*
*/ | countrycode=="SUR" | countrycode=="VEN"
* Middle East & North Africa
	* Available 10: Djibouti, Egypt, Iran, Iraq, Jordan, Lebanon, Morocco, Syria, Tunisia, Yemen
	* Missing 3: Algeria, Libya, West Bank and Gaza (Palestine), 
gen middle_east=0
replace middle_east=1 if countrycode=="DJI" | countrycode=="EGY" | countrycode=="IRN" | countrycode=="IRQ" | countrycode=="JOR" | countrycode=="LBN" /*
*/ | countrycode=="MAR" | countrycode=="SYR" | countrycode=="TUN" | countrycode=="YEM"
* South Asia
	* Available 7: Bangladesh, Bhutan, India, Maldives, Nepal, Pakistan, Sri Lanka
	* Missing 1: Afghanistan
gen south_asia=0
replace south_asia=1 if countrycode=="BGD" | countrycode=="BTN" | countrycode=="IND" | countrycode=="MDV" | countrycode=="NPL" | countrycode=="PAK" /*
*/ | countrycode=="LKA"
* Sub-Saharian Africa
	* Available 43: Angola, Benin, Botswana, Burkina Faso, Burundi, Cape Verde, Camerron, Central African Rep., Chad, Comoros, Dem. Rep. Congo, Rep. Congo,
				* Cote d'Ivoire, Ethiopia, Gabon, Gambia, Ghana, Guinea, Guinea-Bissau, Kenya, Lesotho, Liberia, Madagascar, Malawi, Mali, Mauritania,
				* Mauritius, Mozambique, Namibia, Niger, Nigeria, Rwanda, Sao Tome and Principe, Senegal, Sierra Leone, South Africa, Sudan, Swaziland,
				* Tanzania, Togo, Uganda, Zambia, Zimbabwe
	* Missing 4: Eritrea, Seychelles, Somalia, South Sudan
gen africa=0
replace africa=1 if countrycode=="AGO" | countrycode=="BEN" | countrycode=="BWA" | countrycode=="BFA" | countrycode=="BDI" | countrycode=="CPV" /*
*/ | countrycode=="CMR" | countrycode=="CAF" | countrycode=="TCD" | countrycode=="COM" | countrycode=="COD" | countrycode=="COG" | countrycode=="CIV" /*
*/ | countrycode=="ETH" | countrycode=="GAB" | countrycode=="GMB" | countrycode=="GHA" | countrycode=="GIN" | countrycode=="GNB" | countrycode=="KEN" /*
*/ | countrycode=="LSO" | countrycode=="LBR" | countrycode=="MDG" | countrycode=="MWI" | countrycode=="MLI" | countrycode=="MRT" | countrycode=="MUS" /*
*/ | countrycode=="MOZ" | countrycode=="NAM" | countrycode=="NER" | countrycode=="NGA" | countrycode=="RWA" | countrycode=="STP" | countrycode=="SEN" /*
*/ | countrycode=="SLE" | countrycode=="ZAF" | countrycode=="SDN" | countrycode=="SWZ" | countrycode=="TZA" | countrycode=="TGO" | countrycode=="UGA" /*
*/ | countrycode=="ZMB" | countrycode=="ZWE"

* INCOME LEVELS
* High income
	* Available 53: Antigua and Barbuda, Australia, Bahamas, Bahrain, Bardados, Belgium, Bermuda, Brunei, Canada, Chile, Croatia, Cyprus, Czech Rep.,
				* Denmark, Equatorial Guinea, Estonia, Finland, France, Germany, Greece, Hong Kong, Iceland, Ireland, Israel, Italy, Japan, South Korea,
				* Kuwait, Latvia, Lithuania, Luxembourg, Macao, Malta, Netherlands, New Zealand, Norway, Oman, Poland, Portugal, Qatar, Russia, Saudi Arabia,
				* Singapore, Slovak Rep., Slovenia, Spain, Sweden, Switzerland, Trinidad and Tobago, United Kingdom, United States, Uruguay
	* Missing 21: Andorra, Aruba, Cayman Islands, Channel Islands, Curacao, Faeroe Islands, French Polynesia, Greenland, Guam, Isle of Man, Liechtenstein,
				* Monaco, New Caledonia, Northern Mariana Islands, Puerto Rico, San Marino, Sin Maarten (Dutch part), St. Martin (French part),
				* Turks and Caicos Islands, United Arab Emirates, Virgin Islands (U.S.)
	* Note 2: St. Kitts and Nevis is listed as "High Income: NonOECD" but not as "High Income".
				* Taiwan is not considered separate, but added to "High Income" countries aggregate.
gen high_income=0
replace high_income=1 if countrycode=="ATG" | countrycode=="AUS" | countrycode=="AUT" | countrycode=="BHS" | countrycode=="BHR" | countrycode=="BRB" /*
*/ | countrycode=="BEL" | countrycode=="BMU" | countrycode=="BRN" | countrycode=="CAN" | countrycode=="CHL" | countrycode=="HRV" | countrycode=="CYP" /*
*/ | countrycode=="CZE" | countrycode=="DNK" | countrycode=="GNQ" | countrycode=="EST" | countrycode=="FIN" | countrycode=="FRA" | countrycode=="DEU" /*
*/ | countrycode=="GRC" | countrycode=="HKG" | countrycode=="ISL" | countrycode=="IRL" | countrycode=="ISR" | countrycode=="ITA" | countrycode=="JPN" /*
*/ | countrycode=="KOR" | countrycode=="KWT" | countrycode=="LVA" | countrycode=="LTU" | countrycode=="LUX" | countrycode=="MAC" | countrycode=="MLT" /*
*/ | countrycode=="NLD" | countrycode=="NZL" | countrycode=="NOR" | countrycode=="OMN" | countrycode=="POL" | countrycode=="PRT" | countrycode=="QAT" /*
*/ | countrycode=="RUS" | countrycode=="SAU" | countrycode=="SGP" | countrycode=="SVK" | countrycode=="SVN" | countrycode=="ESP" | countrycode=="KNA" /*
*/ | countrycode=="SWE" | countrycode=="CHE" | countrycode=="TWN" |countrycode=="TTO" | countrycode=="GBR" | countrycode=="USA" | countrycode=="URY"
* Low income
	* Available 29: Bangladesh, Benin, Burkina Faso, Burundi, Cambodia, Central African Republic, Chad, Comoros, Dem. Rep. Congo, Ethiopia, Gambia, Guinea,
				* Guinea-Bissau, Kenya, North Korea, Liberia, Madagascar, Malawi, Mali, Mozambique, Nepal, Niger, Rwanda, Sierra Leone, Tajikistan, Tanzania,
				* Togo, Uganda, Zimbabwe
	* Missing 5: Afghanistan, Eritrea, Haiti, Myanmar, Somalia
gen low_income=0
replace low_income=1 if countrycode=="BGD" | countrycode=="BEN" | countrycode=="BFA" | countrycode=="BDI" | countrycode=="KHM" | countrycode=="CAF" /*
*/ | countrycode=="TCD" | countrycode=="COM" | countrycode=="COD" | countrycode=="ETH" | countrycode=="GMB" | countrycode=="GIN" | countrycode=="GNB" /*
*/ | countrycode=="KEN" | countrycode=="LBR" | countrycode=="MDG" | countrycode=="MWI" | countrycode=="MLI" | countrycode=="MOZ" | countrycode=="NPL" /*
*/ | countrycode=="NER" | countrycode=="RWA" | countrycode=="SLE" | countrycode=="TJK" | countrycode=="TZA" | countrycode=="TGO" | countrycode=="UGA" /*
*/ | countrycode=="ZWE"
* Lower Middle Income
	* Available 39: Armenia, Bhutan, Bolivia, Cape Verde, Cameroon, Rep. Congo, Cote d'Ivoire, Djibouti, Egypt, El Salvador, Georgia, Ghana, Guatemala,
				* Honduras, India, Indonesia, Kyrgyzstan, Lao, Lesotho, Mauritania, Moldova, Mongolia, Morocco, Nigeria, Pakistan, Paraguay, Philippines,
				* Sao Tome and Principe, Senegal, Sri Lanka, Sudan, Swaziland, Syria, Ukraine, Uzbekistan, Vietnam, Yemen, Zambia
	* Missing 11: Guyana, Kiribati, Kosovo, Micronesia, Nicaragua, Papua New Guinea, Samoa, Solomon Islands, South Sudan, Timor-Leste, Vanuatu,
				* West Bank and Gaza (Palestine)
gen low_mid_income=0
replace low_mid_income=1 if countrycode=="ARM" | countrycode=="BTN" | countrycode=="BOL" | countrycode=="CPV" | countrycode=="CMR" | countrycode=="COG" /*
*/ | countrycode=="CIV" | countrycode=="DJI" | countrycode=="EGY" | countrycode=="SLV" | countrycode=="GEO" | countrycode=="GHA" | countrycode=="GTM" /*
*/ | countrycode=="HND" | countrycode=="IND" | countrycode=="IDN" | countrycode=="KGZ" | countrycode=="LAO" | countrycode=="LSO" | countrycode=="MRT" /*
*/ | countrycode=="MDA" | countrycode=="MNG" | countrycode=="MAR" | countrycode=="NGA" | countrycode=="PAK" | countrycode=="PRY" | countrycode=="PHL" /*
*/ | countrycode=="STP" | countrycode=="SEN" | countrycode=="LKA" | countrycode=="SDN" | countrycode=="SWZ" | countrycode=="SYR" | countrycode=="UKR" /*
*/ | countrycode=="UZB" | countrycode=="VNM" | countrycode=="YEM" | countrycode=="ZMB"
* Upper Middle Income
	* Available 48: Albania, Angola, Argentina, Azerbaijan, Belarus, Belize, Bosnia and Herzegovina, Botswana, Brazil, Bulgaria, China, Colombia, Costa Rica,
				* Dominica, Dominican Rep., Ecuador, Fiji, Gabon, Grenada, Hungary, Iran, Iraq, Jamaica, Jordan, Kazakhstan, Lebanon, Libya, Macedonia,
				* Malaysia, Maldives, Mauritius, Mexico, Montenegro, Namibia, Panama, Peru, Romania, Serbia, South Africa, St. Lucia, 
				* St. Vincent and the Grenadines, Suriname, Thailand, Tunisia, Turkey, Turkmenistan, Tuvalu, Venezuela
	* Missing 7: Algeria, American Samoa, Cuba, Marshall Islands, Palau, Seychelles, Tonga
gen upper_mid_income=0
replace upper_mid_income=1 if countrycode=="ALB" | countrycode=="AGO" | countrycode=="ARG" | countrycode=="AZE" | countrycode=="BLR" | countrycode=="BLZ" /*
*/ | countrycode=="BIH" | countrycode=="BWA" | countrycode=="BRA" | countrycode=="BGR" | countrycode=="CHN" | countrycode=="COL" | countrycode=="CRI" /*
*/ | countrycode=="DMA" | countrycode=="DOM" | countrycode=="ECU" | countrycode=="FJI" | countrycode=="GAB" | countrycode=="GRD" | countrycode=="HUN" /*
*/ | countrycode=="IRN" | countrycode=="IRQ" | countrycode=="JAM" | countrycode=="JOR" | countrycode=="KAZ" | countrycode=="LBN" | countrycode=="MKD" /*
*/ | countrycode=="MYS" | countrycode=="MDV" | countrycode=="MUS" | countrycode=="MEX" | countrycode=="MNE" | countrycode=="NAM" | countrycode=="PAN" /*
*/ | countrycode=="PER" | countrycode=="ROU" | countrycode=="SRB" | countrycode=="ZAF" | countrycode=="LCA" | countrycode=="VCT" | countrycode=="SUR" /*
*/ | countrycode=="THA" | countrycode=="TUN" | countrycode=="TUR" | countrycode=="TKM" | countrycode=="VEN"
* High income: OECD
	* Available:
	* Missing:
gen oecd=0
replace oecd=1 if countrycode=="AUS" | countrycode=="AUT" | countrycode=="BEL" | countrycode=="CAN" | countrycode=="CHL" | countrycode=="CZE" /*
*/ | countrycode=="DEN" | countrycode=="EST" | countrycode=="FIN" | countrycode=="FRA" | countrycode=="DEU" | countrycode=="GRC" | countrycode=="ISL" /*
*/ | countrycode=="IRL" | countrycode=="ISR" | countrycode=="ITA" | countrycode=="JPN" | countrycode=="KOR" | countrycode=="LUX" | countrycode=="NLD" /*
*/ | countrycode=="NZL" | countrycode=="NOR" | countrycode=="POL" | countrycode=="SVK" | countrycode=="SVN" | countrycode=="ESP" | countrycode=="SWE" /*
*/ | countrycode=="CHE" | countrycode=="GBR" | countrycode=="USA"
* Minimum
if `=minyear10'<=1960 {
	scalar minyear2=1960
}
else if `=minyear10'>1960 & `=minyear10'<=1970 {
	scalar minyear2=1970
}
else if `=minyear10'>=1970 & `=minyear10'<=1980 {
	scalar minyear2=1980
}
else {
	scalar minyear2=1990
}
* Overall growth rate of World
/*bys year: egen rgdpo_w=total(rgdpo)
bys year: egen pop_w=total(pop)
gen gdppc_w=rgdpo_w/pop_w
gen lngdppc_w=ln(gdppc_w)
reg lngdppc_w year, robust
scalar g_w=_b[year]*100
local g_w: display %2.1f g_w

egen world=group(countrycode)
qui reg lngdppc year if world==1 & year>=`=minyear2', robust
scalar g_w=_b[year]*100
local g_w: display g_w
summ world, meanonly
forval x=2/`r(max)' {
	reg lngdppc year if world==`x' & year>=`=minyear2', robust
	scalar g_w=(`=g_w'*(`x'-1)+_b[year]*100)/`x'
}
* Overall growth rate of Region
* Overall growth rate of Income Group
* Overall growth rate of OECD
* Overall growth rate of USA
*/

* Reshape and labels
reshape wide lngdppc gdppc rgdpo pop g, i(countrycode) j(year)
label var lngdppc`=maxyear' "Level of GDPPC, `=maxyear'"
label var lngdppc`=minyear2' "Level of GDPPC, `=minyear2'"

***************************
* Version 1: vs the World *
***************************

* Figure 2.1
two lpolyci lngdppc`=maxyear' lngdppc`=minyear2', xlabel(5(1)11) ylabel(5(1)11) title("Initial and final level of GDP per capita") subtitle("`j'") /*
*/ note("Data source:  Penn World Tables 8.0") || scatter lngdppc`=maxyear' lngdppc`=minyear2' if countrycode=="`ctry'", mlabel(countrycode) /*
*/ mlabsize(vsmall) mcolor(red) mlabcolor(red) mlabposition(3) legend(off)

****************************
* Version 2: vs the Region *
****************************

**********************************
* Version 3: vs the Income Group *
**********************************

***********************************
* Version 4: vs OECD (and the US) *
***********************************


*scalar drop _all
*macro drop _all
