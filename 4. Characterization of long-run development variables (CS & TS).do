clear
set more off

****************************************************************************************************************************************
* PARAMETERS TO BE CHANGED BY THE USER:
* ORIGINAL DIRECTORY:
cd "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata\WDI"
* ORIGINAL DATABASES
use "wdi2013.dta", clear
* OTHER DATABASES:
	* EDUCATION
	global education "BL2013_MF2599_v1.3.dta"
	* PHYSICAL CAPITAL
	global capital "C:\Users\Luis Miguel\Documents\Bases de Datos\Penn World Tables\pwt80\pwt80.dta"
	* TAX REVENUE
	global revenue "C:\Users\Luis Miguel\Documents\Bases de Datos\IMF\taxrevenue.dta"
	* INSTITUTIONS
	global institutions "C:\Users\Luis Miguel\Documents\Bases de Datos\The Quality of Government Institute\Standard data\qog_std_ts_20dec13.dta"
	* COMPLEXITY
	global complexity "C:\Users\Luis Miguel\Documents\Bases de Datos\CID - Harvard\complexity_y_c.dta"
* COUNTRY TO BE ANALYZED
local ctry IRL
levelsof country if wbcode=="`ctry'", local(j) clean
* RESULTS
cd "C:\Users\Luis Miguel\Dropbox\CID\Automatization Growth Diagnostics\Results"
capture mkdir "`ctry'"
global dir "C:\Users\Luis Miguel\Dropbox\CID\Automatization Growth Diagnostics\Results\\`ctry'"
cd "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata"
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
drop n m
sort country year

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

* In which region the country is?
summ region if wbcode=="`ctry'"
scalar region`ctry'=r(mean)

* Renaming and labeling
rename NY_GDP_PCAP_KD gdppc
gen lngdppc=ln(gdppc)
label var lngdppc "Ln(GDPPC)"
rename NY_GDP_PCAP_PP_KD gdppc2
gen lngdppc2=ln(gdppc2)
label var lngdppc "GDP per capita (constant 2005 US$), log"
label var lngdppc2 "GDP per capita, PPP (constant 2005 international $), log"
label var year "Years"


*********************************************
** STRUCTURAL TRANSFORMATION: URBANIZATION **
*********************************************
rename SP_URB_TOTL_IN_ZS urban_pop
preserve

* Minimum and maximum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & urban_pop!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & urban_pop!=.
scalar maxyear1=r(max)
local maxyear1: display %9.0f maxyear1
scalar minyear1=r(min)
local minyear1: display %9.0f minyear1

keep if year==`=minyear1' | year==`=maxyear1'

* Coordinates for country
summ urban_pop if wbcode=="`ctry'" & year==`=minyear1'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear1'
scalar x1=r(mean)
gen x1=`=x1'
summ urban_pop if wbcode=="`ctry'" & year==`=maxyear1'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear1'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear1'!=. & `=minyear1'!=. {
	* Figure 1: Urban population as % of total (vs World)
	lpoly urban_pop lngdppc2 if year==`=minyear1', noscatter /*
	*/ title("Urbanization, `=minyear1' and `=maxyear1'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Urban population (% of total)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear1'") lab(2 "`=maxyear1'")) /*
	*/ addplot(lpoly urban_pop lngdppc2 if year==`=maxyear1' || /*
	*/ scatter urban_pop lngdppc2 if wbcode=="`ctry'" & year==`=minyear1', mlab(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter urban_pop lngdppc2 if wbcode=="`ctry'" & year==`=maxyear1', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure1`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure1`ctry'_2C.png") replace
}
restore

*********************************************************
** STRUCTURAL TRANSFORMATION: AGRICULTURE SHARE OF GDP **
*********************************************************
rename NV_AGR_TOTL_ZS agr_gdp
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & agr_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & agr_gdp!=.
scalar maxyear2=r(max)
local maxyear2: display %9.0f maxyear2
scalar minyear2=r(min)
local minyear2: display %9.0f minyear2

keep if year==`=minyear2' | year==`=maxyear2'

* Coordinates for country
summ agr_gdp if wbcode=="`ctry'" & year==`=minyear2'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear2'
scalar x1=r(mean)
gen x1=`=x1'
summ agr_gdp if wbcode=="`ctry'" & year==`=maxyear2'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear2'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear2'!=. & `=minyear2'!=. {
	* Figure 2: Agriculture as % of GDP (vs World)
	lpoly agr_gdp lngdppc2 if year==`=minyear2', noscatter /*
	*/ title("Share of agriculture in GDP, `=minyear2' and `=maxyear2'") subtitle("`j'") note("Note: Agriculture corresponds to ISIC Rev.3 divisions 1-5" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Agriculture, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear2'") lab(2 "`=maxyear2'")) /*
	*/ addplot(lpoly agr_gdp lngdppc2 if year==`=maxyear2' || /*
	*/ scatter agr_gdp lngdppc2 if wbcode=="`ctry'" & year==`=minyear2', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter agr_gdp lngdppc2 if wbcode=="`ctry'" & year==`=maxyear2', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure2`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure2`ctry'_2C.png") append
}
restore

***********************************************************
** STRUCTURAL TRANSFORMATION: MANUFACTURING SHARE OF GDP **
***********************************************************
rename NV_IND_MANF_ZS mnf_gdp
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & mnf_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & mnf_gdp!=.
scalar maxyear3=r(max)
local maxyear3: display %9.0f maxyear3
scalar minyear3=r(min)
local minyear3: display %9.0f minyear3

keep if year==`=minyear3' | year==`=maxyear3'

* Coordinates for country
summ mnf_gdp if wbcode=="`ctry'" & year==`=minyear3'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear3'
scalar x1=r(mean)
gen x1=`=x1'
summ mnf_gdp if wbcode=="`ctry'" & year==`=maxyear3'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear3'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear3'!=. & `=minyear3'!=. {
	* Figure 3: Manufacturing as % of GDP (vs World)
	lpoly mnf_gdp lngdppc2 if year==`=minyear3', noscatter /*
	*/ title("Share of manufacturing in GDP, `=minyear3' and `=maxyear3'") subtitle("`j'") /*
	*/ note("Note: Manufacturing refers to industries belonging to ISIC Rev.3 divisions 15-37" "Data source: World Development Indicators") /*
	*/ ytitle("Manufacturing, value added (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear3'") lab(2 "`=maxyear3'")) /*
	*/ addplot(lpoly mnf_gdp lngdppc2 if year==`=maxyear3' || /*
	*/ scatter mnf_gdp lngdppc2 if wbcode=="`ctry'" & year==`=minyear3', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter mnf_gdp lngdppc2 if wbcode=="`ctry'" & year==`=maxyear3', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure3`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure3`ctry'_2C.png") append
}
restore

*******************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN INDUSTRY **
*******************************************************
rename SL_IND_EMPL_ZS emp_ind
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & emp_ind!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & emp_ind!=.
scalar maxyear4=r(max)
local maxyear4: display %9.0f maxyear4
scalar minyear4=r(min)
local minyear4: display %9.0f minyear4

keep if year==`=minyear4' | year==`=maxyear4'

* Coordinates for country
summ emp_ind if wbcode=="`ctry'" & year==`=minyear4'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear4'
scalar x1=r(mean)
gen x1=`=x1'
summ emp_ind if wbcode=="`ctry'" & year==`=maxyear4'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear4'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear4'!=. & `=minyear4'!=. {
	* Figure 4: Employment in industry (vs World)
	lpoly emp_ind lngdppc2 if year==`=minyear4', noscatter /*
	*/ title("Industry employment, `=minyear4' and `=maxyear4'") subtitle("`j'") note("Note: Industry corresponds to ISIC Rev.3 divisions 10-45" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in industry (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear4'") lab(2 "`=maxyear4'"))	/*
	*/ addplot(lpoly emp_ind lngdppc2 if year==`=maxyear4'	|| /*
	*/ scatter emp_ind lngdppc2 if wbcode=="`ctry'" & year==`=minyear4', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter emp_ind lngdppc2 if wbcode=="`ctry'" & year==`=maxyear4', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
		
	* Exporting results into word document
	gr export "$dir\figure4`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure4`ctry'_2C.png") append
}
restore

*******************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN SERVICES **
*******************************************************
rename SL_SRV_EMPL_ZS emp_ss
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & emp_ss!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & emp_ss!=.
scalar maxyear5=r(max)
local maxyear5: display %9.0f maxyear5
scalar minyear5=r(min)
local minyear5: display %9.0f minyear5

keep if year==`=minyear5' | year==`=maxyear5'

* Coordinates for country
summ emp_ss if wbcode=="`ctry'" & year==`=minyear5'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear5'
scalar x1=r(mean)
gen x1=`=x1'
summ emp_ss if wbcode=="`ctry'" & year==`=maxyear5'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear5'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear5'!=. & `=minyear5'!=. {
	* Figure 5: Employment in services (vs World)
	lpoly emp_ss lngdppc2 if year==`=minyear5', noscatter /*
	*/ title("Services employment, `=minyear5' and `=maxyear5'") subtitle("`j'") note("Note: Services correspond to ISIC Rev.3 divisions 50-99" /*
	*/ "Data source: World Development Indicators") /*
	*/ ytitle("Employment in services (% of total employment)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear5'") lab(2 "`=maxyear5'"))	/*
	*/ addplot(lpoly emp_ss lngdppc2 if year==`=maxyear5'	|| /*
	*/ scatter emp_ss lngdppc2 if wbcode=="`ctry'" & year==`=minyear5', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter emp_ss lngdppc2 if wbcode=="`ctry'" & year==`=maxyear5', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure5`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure5`ctry'_2C.png") append
}
restore

********************************************************************************************************************************************************

*****************************************************
** PHYSICAL CAPITAL: ENERGY CONSUMPTION PER CAPITA **
*****************************************************
rename EG_USE_PCAP_KG_OE energypc
gen lnenergypc=ln(energypc)
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & lnenergypc!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & lnenergypc!=.
scalar maxyear6=r(max)
local maxyear6: display %9.0f maxyear6
scalar minyear6=r(min)
local minyear6: display %9.0f minyear6

keep if year==`=minyear6' | year==`=maxyear6'

* Coordinates for country
summ lnenergypc if wbcode=="`ctry'" & year==`=minyear6'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear6'
scalar x1=r(mean)
gen x1=`=x1'
summ lnenergypc if wbcode=="`ctry'" & year==`=maxyear6'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear6'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear6'!=. & `=minyear6'!=. {
	* Figure 6: Energy consumption per capita (vs World)
	lpoly lnenergypc lngdppc2 if year==`=minyear6', noscatter /*
	*/ title("Energy consumption per capita, `=minyear6' and `=maxyear6'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Energy use (kg of oil equivalent per capita), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear6'") lab(2 "`=maxyear6'"))	/*
	*/ addplot(lpoly lnenergypc lngdppc2 if year==`=maxyear6' || /*
	*/ scatter lnenergypc lngdppc2 if wbcode=="`ctry'" & year==`=minyear6', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter lnenergypc lngdppc2 if wbcode=="`ctry'" & year==`=maxyear6', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure6`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure6`ctry'_2C.png") append
}
restore

*******************************************
** PHYSICAL CAPITAL: CAPITAL PER WORKER **
*******************************************
preserve
save "temp.dta", replace
use "$capital", clear /*Penn World Tables*/
rename countrycode wbcode
replace wbcode="ZAR" if wbcode=="COD"
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge
gen kpw=ln(ck/SL_TLF_TOTL_IN)

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & kpw!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & kpw!=.
scalar maxyear7=r(max)
local maxyear7: display %9.0f maxyear7
scalar minyear7=r(min)
local minyear7: display %9.0f minyear7

keep if year==`=minyear7' | year==`=maxyear7'

* Coordinates for country
summ kpw if wbcode=="`ctry'" & year==`=minyear7'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear7'
scalar x1=r(mean)
gen x1=`=x1'
summ kpw if wbcode=="`ctry'" & year==`=maxyear7'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear7'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear7'!=. & `=minyear7'!=. {
	* Figure 7: Capital per worker (vs World)
	lpoly kpw lngdppc2 if year==`=minyear7', noscatter /*
	*/ title("Capital per worker, `=minyear7' and `=maxyear7'") subtitle("`j'") note("Data source: Penn World Table 8.0 and World Development Indicators") /*
	*/ ytitle("Capital stock/labor force" "(at current PPP mil. 2005 US$), log") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear7'") lab(2 "`=maxyear7'"))	/*
	*/ addplot(lpoly kpw lngdppc2 if year==`=maxyear7' || /*
	*/ scatter kpw lngdppc2 if wbcode=="`ctry'" & year==`=minyear7', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter kpw lngdppc2 if wbcode=="`ctry'" & year==`=maxyear7', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure7`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure7`ctry'_2C.png") append
}
restore
********************************************************************************************************************************************************

***************************************************************
** HUMAN CAPITAL: YEARS OF SCHOOLING (OF POPULATION OVER 25) **
***************************************************************
preserve
merge 1:1 wbcode year using "$education" /*Barro and Lee only have data for every 5 years*/
drop if _merge!=3
drop _merge
rename yr_sch school

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & school!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & school!=.
scalar maxyear8=r(max)
local maxyear8: display %9.0f maxyear8
scalar minyear8=r(min)
local minyear8: display %9.0f minyear8

keep if year==`=minyear8' | year==`=maxyear8'

* Coordinates for country
summ school if wbcode=="`ctry'" & year==`=minyear8'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear8'
scalar x1=r(mean)
gen x1=`=x1'
summ school if wbcode=="`ctry'" & year==`=maxyear8'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear8'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear8'!=. & `=minyear8'!=. {
	* Figure 8: Years of schooling (vs World)
	lpoly school lngdppc2 if year==`=minyear8', noscatter /*
	*/ title("Years of schooling, `=minyear8' and `=maxyear8'") subtitle("Population aged 25 and over, `j'") /*
	*/ note("Data source: Barro-Lee dataset and World Development Indicators") /*
	*/ ytitle("Years of schooling") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear8'") lab(2 "`=maxyear8'"))	/*
	*/ addplot(lpoly school lngdppc2 if year==`=maxyear8' || /*
	*/ scatter school lngdppc2 if wbcode=="`ctry'" & year==`=minyear8', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter school lngdppc2 if wbcode=="`ctry'" & year==`=maxyear8', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure8`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure8`ctry'_2C.png") append
}
restore

***********************************************
** HUMAN CAPITAL: SECONDARY ENROLLMENT (NET) **
***********************************************
rename SE_SEC_NENR sec
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & sec!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & sec!=.
scalar maxyear9=r(max)
local maxyear9: display %9.0f maxyear9
scalar minyear9=r(min)
local minyear9: display %9.0f minyear9

keep if year==`=minyear9' | year==`=maxyear9'

* Coordinates for country
summ sec if wbcode=="`ctry'" & year==`=minyear9'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear9'
scalar x1=r(mean)
gen x1=`=x1'
summ sec if wbcode=="`ctry'" & year==`=maxyear9'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear9'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear9'!=. & `=minyear9'!=. {
	* Figure 9: Secondary enrollment (vs World)
	lpoly sec lngdppc2 if year==`=minyear9', noscatter /*
	*/ title("Secondary enrollment, `=minyear9' and `=maxyear9'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("School enrollment, secondary (% net)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear9'") lab(2 "`=maxyear9'"))	/*
	*/ addplot(lpoly sec lngdppc2 if year==`=maxyear9' || /*
	*/ scatter sec lngdppc2 if wbcode=="`ctry'" & year==`=minyear9', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter sec lngdppc2 if wbcode=="`ctry'" & year==`=maxyear9', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure9`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure9`ctry'_2C.png") append
}
restore

**************************************************************
** HUMAN CAPITAL: SCIENTIFIC AND TECHNICAL JOURNAL ARTICLES **
**************************************************************
gen journal=IP_JRN_ARTC_SC*1000/SP_POP_TOTL
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & journal!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & journal!=.
scalar maxyear10=r(max)
local maxyear10: display %9.0f maxyear10
scalar minyear10=r(min)
local minyear10: display %9.0f minyear10

keep if year==`=minyear10' | year==`=maxyear10'

* Coordinates for country
summ journal if wbcode=="`ctry'" & year==`=minyear10'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear10'
scalar x1=r(mean)
gen x1=`=x1'
summ journal if wbcode=="`ctry'" & year==`=maxyear10'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear10'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear10'!=. & `=minyear10'!=. {
	* Figure 10: Journals (vs World)
	lpoly journal lngdppc2 if year==`=minyear10', noscatter /*
	*/ title("Scientific and Technical Journal Articles, `=minyear10' and `=maxyear10'") subtitle("Per 1,000 people, `j'") /*
	*/ note("Data source: World Development Indicators") /*
	*/ ytitle("Scientific and technical journal articles per 1,000 people") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear10'") lab(2 "`=maxyear10'"))	/*
	*/ addplot(lpoly journal lngdppc2 if year==`=maxyear10' || /*
	*/ scatter journal lngdppc2 if wbcode=="`ctry'" & year==`=minyear10', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter journal lngdppc2 if wbcode=="`ctry'" & year==`=maxyear10', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure10`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure10`ctry'_2C.png") append
}
restore

***************************************
** HUMAN CAPITAL: TERTIARY EDUCATION **
***************************************
rename SL_TLF_TERT_ZS univ
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & univ!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & univ!=.
scalar maxyear11=r(max)
local maxyear11: display %9.0f maxyear11
scalar minyear11=r(min)
local minyear11: display %9.0f minyear11

keep if year==`=minyear11' | year==`=maxyear11'

* Coordinates for country
summ univ if wbcode=="`ctry'" & year==`=minyear11'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear11'
scalar x1=r(mean)
gen x1=`=x1'
summ univ if wbcode=="`ctry'" & year==`=maxyear11'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear11'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear11'!=. & `=minyear11'!=. {
	* Figure 11: Tertiary education (vs World)
	lpoly univ lngdppc2 if year==`=minyear11', noscatter /*
	*/ title("University education, `=minyear11' and `=maxyear11'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Labor force with tertiary education (% of total)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear11'") lab(2 "`=maxyear11'"))	/*
	*/ addplot(lpoly univ lngdppc2 if year==`=maxyear11' || /*
	*/ scatter univ lngdppc2 if wbcode=="`ctry'" & year==`=minyear11', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter univ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear11', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure11`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure11`ctry'_2C.png") append
}
restore
********************************************************************************************************************************************************

**********************************
** POPULATION: INFANT MORTALITY **
**********************************
rename SP_DYN_IMRT_IN infant
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & infant!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & infant!=.
scalar maxyear12=r(max)
local maxyear12: display %9.0f maxyear12
scalar minyear12=r(min)
local minyear12: display %9.0f minyear12

keep if year==`=minyear12' | year==`=maxyear12'

* Coordinates for country
summ infant if wbcode=="`ctry'" & year==`=minyear12'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear12'
scalar x1=r(mean)
gen x1=`=x1'
summ infant if wbcode=="`ctry'" & year==`=maxyear12'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear12'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear12'!=. & `=minyear12'!=. {
	* Figure 12: Infant mortality (vs World)
	lpoly infant lngdppc2 if year==`=minyear12', noscatter /*
	*/ title("Infant mortality, `=minyear12' and `=maxyear12'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Mortality rate, infant (per 1,000 live births)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear12'") lab(2 "`=maxyear12'"))	/*
	*/ addplot(lpoly infant lngdppc2 if year==`=maxyear12' || /*
	*/ scatter infant lngdppc2 if wbcode=="`ctry'" & year==`=minyear12', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter infant lngdppc2 if wbcode=="`ctry'" & year==`=maxyear12', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure12`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure12`ctry'_2C.png") append
}
restore

********************************
** POPULATION: FERTILITY RATE **
********************************
rename SP_DYN_TFRT_IN fertil
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & fertil!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & fertil!=.
scalar maxyear13=r(max)
local maxyear13: display %9.0f maxyear13
scalar minyear13=r(min)
local minyear13: display %9.0f minyear13

keep if year==`=minyear13' | year==`=maxyear13'

* Coordinates for country
summ fertil if wbcode=="`ctry'" & year==`=minyear13'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear13'
scalar x1=r(mean)
gen x1=`=x1'
summ fertil if wbcode=="`ctry'" & year==`=maxyear13'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear13'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear13'!=. & `=minyear13'!=. {
	* Figure 13: Fertility rate (vs World)
	lpoly fertil lngdppc2 if year==`=minyear13', noscatter /*
	*/ title("Fertility rate, `=minyear13' and `=maxyear13'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Fertility rate, total (births per woman)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear13'") lab(2 "`=maxyear13'"))	/*
	*/ addplot(lpoly fertil lngdppc2 if year==`=maxyear13' || /*
	*/ scatter fertil lngdppc2 if wbcode=="`ctry'" & year==`=minyear13', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter fertil lngdppc2 if wbcode=="`ctry'" & year==`=maxyear13', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure13`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure13`ctry'_2C.png") append
}
restore

*********************************
** POPULATION: LIFE EXPECTANCY **
*********************************
rename SP_DYN_LE00_IN life
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & life!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & life!=.
scalar maxyear14=r(max)
local maxyear14: display %9.0f maxyear14
scalar minyear14=r(min)
local minyear14: display %9.0f minyear14

keep if year==`=minyear14' | year==`=maxyear14'

* Coordinates for country
summ life if wbcode=="`ctry'" & year==`=minyear14'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear14'
scalar x1=r(mean)
gen x1=`=x1'
summ life if wbcode=="`ctry'" & year==`=maxyear14'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear14'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear14'!=. & `=minyear14'!=. {
	* Figure 14: Life Expectancy (vs World)
	lpoly life lngdppc2 if year==`=minyear14', noscatter /*
	*/ title("Life expectancy, `=minyear14' and `=maxyear14'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Life expectancy at birth, total (years)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear14'") lab(2 "`=maxyear14'"))	/*
	*/ addplot(lpoly life lngdppc2 if year==`=maxyear14' || /*
	*/ scatter life lngdppc2 if wbcode=="`ctry'" & year==`=minyear14', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter life lngdppc2 if wbcode=="`ctry'" & year==`=maxyear14', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure14`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure14`ctry'_2C.png") append
}
restore

***********************************
** POPULATION: POPULATION GROWTH **
***********************************
rename SP_POP_GROW pop_g
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & pop_g!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & pop_g!=.
scalar maxyear15=r(max)
local maxyear15: display %9.0f maxyear15
scalar minyear15=r(min)
local minyear15: display %9.0f minyear15

keep if year==`=minyear15' | year==`=maxyear15'

* Coordinates for country
summ pop_g if wbcode=="`ctry'" & year==`=minyear15'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear15'
scalar x1=r(mean)
gen x1=`=x1'
summ pop_g if wbcode=="`ctry'" & year==`=maxyear15'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear15'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear15'!=. & `=minyear15'!=. {
	* Figure 15: Population growth (vs World)
	lpoly pop_g lngdppc2 if year==`=minyear15', noscatter /*
	*/ title("Population growth, `=minyear15' and `=maxyear15'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Population growth (annual %)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear15'") lab(2 "`=maxyear15'"))	/*
	*/ addplot(lpoly pop_g lngdppc2 if year==`=maxyear15' || /*
	*/ scatter pop_g lngdppc2 if wbcode=="`ctry'" & year==`=minyear15', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter pop_g lngdppc2 if wbcode=="`ctry'" & year==`=maxyear15', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure15`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure15`ctry'_2C.png") append
}
restore

**************************************
** POPULATION: DEMOGRAPHIC DIVIDEND **
**************************************
rename SP_POP_DPND depend
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & depend!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & depend!=.
scalar maxyear16=r(max)
local maxyear16: display %9.0f maxyear16
scalar minyear16=r(min)
local minyear16: display %9.0f minyear16

keep if year==`=minyear16' | year==`=maxyear16'

* Coordinates for country
summ depend if wbcode=="`ctry'" & year==`=minyear16'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear16'
scalar x1=r(mean)
gen x1=`=x1'
summ depend if wbcode=="`ctry'" & year==`=maxyear16'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear16'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear16'!=. & `=minyear16'!=. {
	* Figure 16: Demographic Dividend (vs World)
	lpoly depend lngdppc2 if year==`=minyear16', noscatter /*
	*/ title("Demographic dividend, `=minyear16' and `=maxyear16'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Age dependency ratio (% of working-age population)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear16'") lab(2 "`=maxyear16'"))	/*
	*/ addplot(lpoly depend lngdppc2 if year==`=maxyear16' || /*
	*/ scatter depend lngdppc2 if wbcode=="`ctry'" & year==`=minyear16', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter depend lngdppc2 if wbcode=="`ctry'" & year==`=maxyear16', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure16`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure16`ctry'_2C.png") append
}
restore
save "temp.dta", replace
********************************************************************************************************************************************************

**************************
** PRODUCTIVITY AND TFP **
**************************
preserve
use "$capital", clear /*Penn World Tables*/
rename countrycode wbcode
replace wbcode="ZAR" if wbcode=="COD"
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & ctfp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & ctfp!=.
scalar maxyear17=r(max)
local maxyear17: display %9.0f maxyear17
scalar minyear17=r(min)
local minyear17: display %9.0f minyear17

keep if year==`=minyear17' | year==`=maxyear17'

* Coordinates for country
summ ctfp if wbcode=="`ctry'" & year==`=minyear17'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear17'
scalar x1=r(mean)
gen x1=`=x1'
summ ctfp if wbcode=="`ctry'" & year==`=maxyear17'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear17'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear17'!=. & `=minyear17'!=. {
	* Figure 17: Total Factor Productivity  (vs World)
	lpoly ctfp lngdppc2 if year==`=minyear17', noscatter /*
	*/ title("Total Factor Productivity, `=minyear17' and `=maxyear17'") subtitle("Relative to USA, `j'") /*
	*/ note("Data source: Penn World Table 8.0 and World Development Indicators") /*
	*/ ytitle("TFP level at current PPPs (USA=1)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear17'") lab(2 "`=maxyear17'"))	/*
	*/ addplot(lpoly ctfp lngdppc2 if year==`=maxyear17' || /*
	*/ scatter ctfp lngdppc2 if wbcode=="`ctry'" & year==`=minyear17', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter ctfp lngdppc2 if wbcode=="`ctry'" & year==`=maxyear17', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure17`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure17`ctry'_2C.png") append
}
restore
save "temp2.dta", replace
********************************************************************************************************************************************************

********************************************
** POLICY AND INSTITUTIONS: TAXES REVENUE **
********************************************
preserve
use "$revenue", clear /*World Economic Outlook*/
reshape long y, i(iso) j(year)
drop weocountrycode weosubjectcode subjectdescriptor units scale
drop if year>=estimatesstartafter
drop estimatesstartafter
rename iso wbcode
replace wbcode="KSV" if wbcode=="UVK"
replace wbcode="ROM" if wbcode=="ROU"
replace wbcode="TMP" if wbcode=="TLS"
replace wbcode="ZAR" if wbcode=="COD"
merge 1:1 wbcode year using "temp2.dta"
drop if _merge!=3
drop _merge
rename y tax_gdp
label var tax_gdp "General government revenue (% of GDP)"

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & tax_gdp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & tax_gdp!=.
scalar maxyear18=r(max)
local maxyear18: display %9.0f maxyear18
scalar minyear18=r(min)
local minyear18: display %9.0f minyear18

keep if year==`=minyear18' | year==`=maxyear18'

* Coordinates for country
summ tax_gdp if wbcode=="`ctry'" & year==`=minyear18'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear18'
scalar x1=r(mean)
gen x1=`=x1'
summ tax_gdp if wbcode=="`ctry'" & year==`=maxyear18'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear18'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear18'!=. & `=minyear18'!=. {
	* Figure 18: Tax revenue (% of GDP) (vs World)
	lpoly tax_gdp lngdppc2 if year==`=minyear18', noscatter /*
	*/ title("Government revenue, `=minyear18' and `=maxyear18'") subtitle("`j'") /*
	*/ note("Data source: World Economic Outlook and World Development Indicators") /*
	*/ ytitle("General government revenue (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear18'") lab(2 "`=maxyear18'"))	/*
	*/ addplot(lpoly tax_gdp lngdppc2 if year==`=maxyear18' || /*
	*/ scatter tax_gdp lngdppc2 if wbcode=="`ctry'" & year==`=minyear18', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter tax_gdp lngdppc2 if wbcode=="`ctry'" & year==`=maxyear18', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure18`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure18`ctry'_2C.png") append
}
restore

***************************************
** POLICY AND INSTITUTIONS: OPENNESS **
***************************************
gen open=NE_EXP_GNFS_ZS+NE_IMP_GNFS_ZS
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & open!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & open!=.
scalar maxyear19=r(max)
local maxyear19: display %9.0f maxyear19
scalar minyear19=r(min)
local minyear19: display %9.0f minyear19

keep if year==`=minyear19' | year==`=maxyear19'

* Coordinates for country
summ open if wbcode=="`ctry'" & year==`=minyear19'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear19'
scalar x1=r(mean)
gen x1=`=x1'
summ open if wbcode=="`ctry'" & year==`=maxyear19'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear19'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear19'!=. & `=minyear19'!=. {
	* Figure 19: Openness (% of GDP) (vs World)
	lpoly open lngdppc2 if year==`=minyear19', noscatter /*
	*/ title("Openness, `=minyear19' and `=maxyear19'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("Exports + Imports of goods and services (% of GDP)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear19'") lab(2 "`=maxyear19'"))	/*
	*/ addplot(lpoly open lngdppc2 if year==`=maxyear19' || /*
	*/ scatter open lngdppc2 if wbcode=="`ctry'" & year==`=minyear19', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter open lngdppc2 if wbcode=="`ctry'" & year==`=maxyear19', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure19`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure19`ctry'_2C.png") append
}
restore
save "temp3.dta", replace

****************************************
** POLICY AND INSTITUTIONS: DEMOCRACY **
****************************************
preserve
use "$institutions", clear /*The Quality of Government Dataset*/
drop if ccodealp==""
rename ccodealp wbcode
rename cname country
drop if year<1960
replace wbcode="ADO" if wbcode=="AND"
replace wbcode="ROM" if wbcode=="ROU"
replace wbcode="TMP" if wbcode=="TLS"
replace wbcode="ZAR" if wbcode=="COD"
replace country="Germany" if wbcode=="DEU"
expand 2 if wbcode=="CSK", gen(new1)
replace wbcode="CZE" if wbcode=="CSK" & new1==0
replace country="Czech Republic" if wbcode=="CZE"
replace wbcode="SVK" if wbcode=="CSK" & new1==1
replace country="Slovakia" if wbcode=="SVK"
expand 3 if wbcode=="YUG", gen(new2)
bys wbcode year new2: gen n2=_n
replace wbcode="SRB" if wbcode=="YUG" & new2==0
replace country="Serbia" if wbcode=="SRB" & new2==0
replace wbcode="SRB" if wbcode=="SCG"
replace country="Serbia" if wbcode=="SRB"
replace wbcode="MKD" if wbcode=="YUG" & new2==1 & n2==1
replace country="Macedonia" if wbcode=="MKD" & new2==1  & n2==1
drop if wbcode=="YUG" & new2==1 & n2==2 & year==1991
replace wbcode="SVN" if wbcode=="YUG" & new2==1 & n2==2
replace country="Slovenia" if wbcode=="SVN" & new2==1 & n2==2
expand 14 if wbcode=="SUN", gen(new3)
bys wbcode year new3: gen n3=_n
replace wbcode="RUS" if wbcode=="SUN" & new3==0
replace country="Russia" if wbcode=="RUS" & new3==0
replace wbcode="ARM" if wbcode=="SUN" & new3==1  & n3==1
replace country="Armenia" if wbcode=="ARM" & new3==1  & n3==1
replace wbcode="AZE" if wbcode=="SUN" & new3==1  & n3==2
replace country="Azerbaijan" if wbcode=="AZE" & new3==1 & n3==1
replace wbcode="BLR" if wbcode=="SUN" & new3==1 & n3==3
replace country="Belarus" if wbcode=="BLR" & new3==1 & n3==3
replace wbcode="GEO" if wbcode=="SUN" & new3==1 & n3==4
replace country="Georgia" if wbcode=="GEO" & new3==1 & n3==4
replace wbcode="KAZ" if wbcode=="SUN" & new3==1 & n3==5
replace country="Kazakhstan" if wbcode=="KAZ" & new3==1 & n3==5
replace wbcode="KGZ" if wbcode=="SUN" & new3==1 & n3==6
replace country="Kyrgyzstan" if wbcode=="KGZ" & new3==1 & n3==6
replace wbcode="LVA" if wbcode=="SUN" & new3==1 & n3==7
replace country="Latvia" if wbcode=="LVA" & new3==1 & n3==7
replace wbcode="LTU" if wbcode=="SUN" & new3==1 & n3==8
replace country="Lithuania" if wbcode=="LTU" & new3==1 & n3==8
replace wbcode="MDA" if wbcode=="SUN" & new3==1 & n3==9
replace country="Moldova" if wbcode=="MDA" & new3==1 & n3==9
replace wbcode="TJK" if wbcode=="SUN" & new3==1 & n3==10
replace country="Tajikistan" if wbcode=="TJK" & new3==1 & n3==10
replace wbcode="TKM" if wbcode=="SUN" & new3==1 & n3==11
replace country="Turkmenistan" if wbcode=="TKM" & new3==1 & n3==11
replace wbcode="UKR" if wbcode=="SUN" & new3==1 & n3==12
replace country="Ukraine" if wbcode=="UKR" & new3==1 & n3==12
replace wbcode="UZB" if wbcode=="SUN" & new3==1 & n3==13
replace country="Uzbekistan" if wbcode=="UZB" & new3==1 & n3==13
replace country="Cyprus" if wbcode=="CYP"
replace country="Ethiopia" if wbcode=="ETH"
replace country="France" if wbcode=="FRA"
replace country="Malaysia" if wbcode=="MYS"
replace country="Pakistan" if wbcode=="PAK"
replace country="Sudan" if wbcode=="SDN"
bys wbcode year: drop if fh_ipolity2==.
merge 1:1 wbcode year using "temp3.dta"
drop if _merge!=3
drop _merge n2 n3
rename fh_ipolity2 demo

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & demo!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & demo!=.
scalar maxyear20=r(max)
local maxyear20: display %9.0f maxyear20
scalar minyear20=r(min)
local minyear20: display %9.0f minyear20

keep if year==`=minyear20' | year==`=maxyear20'

* Coordinates for country
summ demo if wbcode=="`ctry'" & year==`=minyear20'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear20'
scalar x1=r(mean)
gen x1=`=x1'
summ demo if wbcode=="`ctry'" & year==`=maxyear20'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear20'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear20'!=. & `=minyear20'!=. {
	* Figure 20: Democracy (vs World)
	lpoly demo lngdppc2 if year==`=minyear20', noscatter /*
	*/ title("Democracy, `=minyear20' and `=maxyear20'") subtitle("`j'") note("Data source: The Quality of Government Dataset (Freedom House/Polity) and" /*
	*/ "World Development Indicators") /*
	*/ ytitle("Democracy (Freedom House/Imputed Polity)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear20'") lab(2 "`=maxyear20'"))	/*
	*/ addplot(lpoly demo lngdppc2 if year==`=maxyear20' || /*
	*/ scatter demo lngdppc2 if wbcode=="`ctry'" & year==`=minyear20', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter demo lngdppc2 if wbcode=="`ctry'" & year==`=maxyear20', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure20`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure20`ctry'_2C.png") append
}
restore
save "temp3.dta", replace

******************************************
** POLICY AND INSTITUTIONS: RULE OF LAW **
******************************************
preserve
use "$institutions", clear /*The Quality of Government Dataset*/
drop if ccodealp==""
rename ccodealp wbcode
rename cname country
drop if year<1960
replace wbcode="ADO" if wbcode=="AND"
replace wbcode="ROM" if wbcode=="ROU"
replace wbcode="TMP" if wbcode=="TLS"
replace wbcode="ZAR" if wbcode=="COD"
replace country="Germany" if wbcode=="DEU"
expand 2 if wbcode=="CSK", gen(new1)
replace wbcode="CZE" if wbcode=="CSK" & new1==0
replace country="Czech Republic" if wbcode=="CZE"
replace wbcode="SVK" if wbcode=="CSK" & new1==1
replace country="Slovakia" if wbcode=="SVK"
expand 3 if wbcode=="YUG", gen(new2)
bys wbcode year new2: gen n2=_n
replace wbcode="SRB" if wbcode=="YUG" & new2==0
replace country="Serbia" if wbcode=="SRB" & new2==0
replace wbcode="SRB" if wbcode=="SCG"
replace country="Serbia" if wbcode=="SRB"
replace wbcode="MKD" if wbcode=="YUG" & new2==1 & n2==1
replace country="Macedonia" if wbcode=="MKD" & new2==1  & n2==1
drop if wbcode=="YUG" & new2==1 & n2==2 & year==1991
replace wbcode="SVN" if wbcode=="YUG" & new2==1 & n2==2
replace country="Slovenia" if wbcode=="SVN" & new2==1 & n2==2
expand 14 if wbcode=="SUN", gen(new3)
bys wbcode year new3: gen n3=_n
replace wbcode="RUS" if wbcode=="SUN" & new3==0
replace country="Russia" if wbcode=="RUS" & new3==0
replace wbcode="ARM" if wbcode=="SUN" & new3==1  & n3==1
replace country="Armenia" if wbcode=="ARM" & new3==1  & n3==1
replace wbcode="AZE" if wbcode=="SUN" & new3==1  & n3==2
replace country="Azerbaijan" if wbcode=="AZE" & new3==1 & n3==1
replace wbcode="BLR" if wbcode=="SUN" & new3==1 & n3==3
replace country="Belarus" if wbcode=="BLR" & new3==1 & n3==3
replace wbcode="GEO" if wbcode=="SUN" & new3==1 & n3==4
replace country="Georgia" if wbcode=="GEO" & new3==1 & n3==4
replace wbcode="KAZ" if wbcode=="SUN" & new3==1 & n3==5
replace country="Kazakhstan" if wbcode=="KAZ" & new3==1 & n3==5
replace wbcode="KGZ" if wbcode=="SUN" & new3==1 & n3==6
replace country="Kyrgyzstan" if wbcode=="KGZ" & new3==1 & n3==6
replace wbcode="LVA" if wbcode=="SUN" & new3==1 & n3==7
replace country="Latvia" if wbcode=="LVA" & new3==1 & n3==7
replace wbcode="LTU" if wbcode=="SUN" & new3==1 & n3==8
replace country="Lithuania" if wbcode=="LTU" & new3==1 & n3==8
replace wbcode="MDA" if wbcode=="SUN" & new3==1 & n3==9
replace country="Moldova" if wbcode=="MDA" & new3==1 & n3==9
replace wbcode="TJK" if wbcode=="SUN" & new3==1 & n3==10
replace country="Tajikistan" if wbcode=="TJK" & new3==1 & n3==10
replace wbcode="TKM" if wbcode=="SUN" & new3==1 & n3==11
replace country="Turkmenistan" if wbcode=="TKM" & new3==1 & n3==11
replace wbcode="UKR" if wbcode=="SUN" & new3==1 & n3==12
replace country="Ukraine" if wbcode=="UKR" & new3==1 & n3==12
replace wbcode="UZB" if wbcode=="SUN" & new3==1 & n3==13
replace country="Uzbekistan" if wbcode=="UZB" & new3==1 & n3==13
replace country="Cyprus" if wbcode=="CYP"
replace country="Ethiopia" if wbcode=="ETH"
replace country="France" if wbcode=="FRA"
replace country="Malaysia" if wbcode=="MYS"
replace country="Pakistan" if wbcode=="PAK"
replace country="Sudan" if wbcode=="SDN"
bys wbcode year: drop if fh_rol==.
merge 1:1 wbcode year using "temp3.dta"
drop if _merge!=3
drop _merge
rename fh_rol rule

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & rule!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & rule!=.
scalar maxyear21=r(max)
local maxyear21: display %9.0f maxyear21
scalar minyear21=r(min)
local minyear21: display %9.0f minyear21

keep if year==`=minyear21' | year==`=maxyear21'

* Coordinates for country
summ rule if wbcode=="`ctry'" & year==`=minyear21'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear21'
scalar x1=r(mean)
gen x1=`=x1'
summ rule if wbcode=="`ctry'" & year==`=maxyear21'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear21'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear21'!=. & `=minyear21'!=. {
	* Figure 21: Rule of Law (vs World)
	lpoly rule lngdppc2 if year==`=minyear21', noscatter /*
	*/ title("Rule of Law, `=minyear21' and `=maxyear21'") subtitle("`j'") note("Data source: The Quality of Government Dataset (Freedom House) and" /*
	*/ "World Development Indicators") /*
	*/ ytitle("Rule of Law") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear21'") lab(2 "`=maxyear21'"))	/*
	*/ addplot(lpoly rule lngdppc2 if year==`=maxyear21' || /*
	*/ scatter rule lngdppc2 if wbcode=="`ctry'" & year==`=minyear21', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter rule lngdppc2 if wbcode=="`ctry'" & year==`=maxyear21', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure21`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure21`ctry'_2C.png") append
}
restore
save "temp3.dta", replace

***********************************************
** POLICY AND INSTITUTIONS: ECONOMIC FREEDOM **
***********************************************
preserve
use "$institutions", clear /*The Quality of Government Dataset*/
drop if ccodealp==""
rename ccodealp wbcode
rename cname country
drop if year<1960
replace wbcode="ADO" if wbcode=="AND"
replace wbcode="ROM" if wbcode=="ROU"
replace wbcode="TMP" if wbcode=="TLS"
replace wbcode="ZAR" if wbcode=="COD"
replace country="Germany" if wbcode=="DEU"
expand 2 if wbcode=="CSK", gen(new1)
replace wbcode="CZE" if wbcode=="CSK" & new1==0
replace country="Czech Republic" if wbcode=="CZE"
replace wbcode="SVK" if wbcode=="CSK" & new1==1
replace country="Slovakia" if wbcode=="SVK"
expand 3 if wbcode=="YUG", gen(new2)
bys wbcode year new2: gen n2=_n
replace wbcode="SRB" if wbcode=="YUG" & new2==0
replace country="Serbia" if wbcode=="SRB" & new2==0
replace wbcode="SRB" if wbcode=="SCG"
replace country="Serbia" if wbcode=="SRB"
replace wbcode="MKD" if wbcode=="YUG" & new2==1 & n2==1
replace country="Macedonia" if wbcode=="MKD" & new2==1  & n2==1
drop if wbcode=="YUG" & new2==1 & n2==2 & year==1991
replace wbcode="SVN" if wbcode=="YUG" & new2==1 & n2==2
replace country="Slovenia" if wbcode=="SVN" & new2==1 & n2==2
expand 14 if wbcode=="SUN", gen(new3)
bys wbcode year new3: gen n3=_n
replace wbcode="RUS" if wbcode=="SUN" & new3==0
replace country="Russia" if wbcode=="RUS" & new3==0
replace wbcode="ARM" if wbcode=="SUN" & new3==1  & n3==1
replace country="Armenia" if wbcode=="ARM" & new3==1  & n3==1
replace wbcode="AZE" if wbcode=="SUN" & new3==1  & n3==2
replace country="Azerbaijan" if wbcode=="AZE" & new3==1 & n3==1
replace wbcode="BLR" if wbcode=="SUN" & new3==1 & n3==3
replace country="Belarus" if wbcode=="BLR" & new3==1 & n3==3
replace wbcode="GEO" if wbcode=="SUN" & new3==1 & n3==4
replace country="Georgia" if wbcode=="GEO" & new3==1 & n3==4
replace wbcode="KAZ" if wbcode=="SUN" & new3==1 & n3==5
replace country="Kazakhstan" if wbcode=="KAZ" & new3==1 & n3==5
replace wbcode="KGZ" if wbcode=="SUN" & new3==1 & n3==6
replace country="Kyrgyzstan" if wbcode=="KGZ" & new3==1 & n3==6
replace wbcode="LVA" if wbcode=="SUN" & new3==1 & n3==7
replace country="Latvia" if wbcode=="LVA" & new3==1 & n3==7
replace wbcode="LTU" if wbcode=="SUN" & new3==1 & n3==8
replace country="Lithuania" if wbcode=="LTU" & new3==1 & n3==8
replace wbcode="MDA" if wbcode=="SUN" & new3==1 & n3==9
replace country="Moldova" if wbcode=="MDA" & new3==1 & n3==9
replace wbcode="TJK" if wbcode=="SUN" & new3==1 & n3==10
replace country="Tajikistan" if wbcode=="TJK" & new3==1 & n3==10
replace wbcode="TKM" if wbcode=="SUN" & new3==1 & n3==11
replace country="Turkmenistan" if wbcode=="TKM" & new3==1 & n3==11
replace wbcode="UKR" if wbcode=="SUN" & new3==1 & n3==12
replace country="Ukraine" if wbcode=="UKR" & new3==1 & n3==12
replace wbcode="UZB" if wbcode=="SUN" & new3==1 & n3==13
replace country="Uzbekistan" if wbcode=="UZB" & new3==1 & n3==13
replace country="Cyprus" if wbcode=="CYP"
replace country="Ethiopia" if wbcode=="ETH"
replace country="France" if wbcode=="FRA"
replace country="Malaysia" if wbcode=="MYS"
replace country="Pakistan" if wbcode=="PAK"
replace country="Sudan" if wbcode=="SDN"
bys wbcode year: drop if hf_efiscore==.
merge 1:1 wbcode year using "temp3.dta"
drop if _merge!=3
drop _merge
rename hf_efiscore econ_freedom

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & econ_freedom!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & econ_freedom!=.
scalar maxyear22=r(max)
local maxyear22: display %9.0f maxyear22
scalar minyear22=r(min)
local minyear22: display %9.0f minyear22

keep if year==`=minyear22' | year==`=maxyear22'

* Coordinates for country
summ econ_freedom if wbcode=="`ctry'" & year==`=minyear22'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear22'
scalar x1=r(mean)
gen x1=`=x1'
summ econ_freedom if wbcode=="`ctry'" & year==`=maxyear22'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear22'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear22'!=. & `=minyear22'!=. {
	* Figure 22: Economic Freedom (vs World)
	lpoly econ_freedom lngdppc2 if year==`=minyear22', noscatter /*
	*/ title("Economic Freedom, `=minyear22' and `=maxyear22'") subtitle("`j'") note("Note: The Economic Freedom Index uses 10 specific freedoms: business, trade, fiscal, from" /*
	*/ "government, monetary, investment, financial, property rights, from corruption, and labor" /*
	*/ "Data source: The Quality of Government Dataset (Heritage Foundation) and World Development" "Indicators") /*
	*/ ytitle("Economic Freedom Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear22'") lab(2 "`=maxyear22'"))	/*
	*/ addplot(lpoly econ_freedom lngdppc2 if year==`=maxyear22' || /*
	*/ scatter econ_freedom lngdppc2 if wbcode=="`ctry'" & year==`=minyear22', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter econ_freedom lngdppc2 if wbcode=="`ctry'" & year==`=maxyear22', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure22`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure22`ctry'_2C.png") append
}
restore
save "temp3.dta", replace

***********************************************
** POLICY AND INSTITUTIONS: BUSINESS FREEDOM **
***********************************************
preserve
use "$institutions", clear /*The Quality of Government Dataset*/
drop if ccodealp==""
rename ccodealp wbcode
rename cname country
drop if year<1960
replace wbcode="ADO" if wbcode=="AND"
replace wbcode="ROM" if wbcode=="ROU"
replace wbcode="TMP" if wbcode=="TLS"
replace wbcode="ZAR" if wbcode=="COD"
replace country="Germany" if wbcode=="DEU"
expand 2 if wbcode=="CSK", gen(new1)
replace wbcode="CZE" if wbcode=="CSK" & new1==0
replace country="Czech Republic" if wbcode=="CZE"
replace wbcode="SVK" if wbcode=="CSK" & new1==1
replace country="Slovakia" if wbcode=="SVK"
expand 3 if wbcode=="YUG", gen(new2)
bys wbcode year new2: gen n2=_n
replace wbcode="SRB" if wbcode=="YUG" & new2==0
replace country="Serbia" if wbcode=="SRB" & new2==0
replace wbcode="SRB" if wbcode=="SCG"
replace country="Serbia" if wbcode=="SRB"
replace wbcode="MKD" if wbcode=="YUG" & new2==1 & n2==1
replace country="Macedonia" if wbcode=="MKD" & new2==1  & n2==1
drop if wbcode=="YUG" & new2==1 & n2==2 & year==1991
replace wbcode="SVN" if wbcode=="YUG" & new2==1 & n2==2
replace country="Slovenia" if wbcode=="SVN" & new2==1 & n2==2
expand 14 if wbcode=="SUN", gen(new3)
bys wbcode year new3: gen n3=_n
replace wbcode="RUS" if wbcode=="SUN" & new3==0
replace country="Russia" if wbcode=="RUS" & new3==0
replace wbcode="ARM" if wbcode=="SUN" & new3==1  & n3==1
replace country="Armenia" if wbcode=="ARM" & new3==1  & n3==1
replace wbcode="AZE" if wbcode=="SUN" & new3==1  & n3==2
replace country="Azerbaijan" if wbcode=="AZE" & new3==1 & n3==1
replace wbcode="BLR" if wbcode=="SUN" & new3==1 & n3==3
replace country="Belarus" if wbcode=="BLR" & new3==1 & n3==3
replace wbcode="GEO" if wbcode=="SUN" & new3==1 & n3==4
replace country="Georgia" if wbcode=="GEO" & new3==1 & n3==4
replace wbcode="KAZ" if wbcode=="SUN" & new3==1 & n3==5
replace country="Kazakhstan" if wbcode=="KAZ" & new3==1 & n3==5
replace wbcode="KGZ" if wbcode=="SUN" & new3==1 & n3==6
replace country="Kyrgyzstan" if wbcode=="KGZ" & new3==1 & n3==6
replace wbcode="LVA" if wbcode=="SUN" & new3==1 & n3==7
replace country="Latvia" if wbcode=="LVA" & new3==1 & n3==7
replace wbcode="LTU" if wbcode=="SUN" & new3==1 & n3==8
replace country="Lithuania" if wbcode=="LTU" & new3==1 & n3==8
replace wbcode="MDA" if wbcode=="SUN" & new3==1 & n3==9
replace country="Moldova" if wbcode=="MDA" & new3==1 & n3==9
replace wbcode="TJK" if wbcode=="SUN" & new3==1 & n3==10
replace country="Tajikistan" if wbcode=="TJK" & new3==1 & n3==10
replace wbcode="TKM" if wbcode=="SUN" & new3==1 & n3==11
replace country="Turkmenistan" if wbcode=="TKM" & new3==1 & n3==11
replace wbcode="UKR" if wbcode=="SUN" & new3==1 & n3==12
replace country="Ukraine" if wbcode=="UKR" & new3==1 & n3==12
replace wbcode="UZB" if wbcode=="SUN" & new3==1 & n3==13
replace country="Uzbekistan" if wbcode=="UZB" & new3==1 & n3==13
replace country="Cyprus" if wbcode=="CYP"
replace country="Ethiopia" if wbcode=="ETH"
replace country="France" if wbcode=="FRA"
replace country="Malaysia" if wbcode=="MYS"
replace country="Pakistan" if wbcode=="PAK"
replace country="Sudan" if wbcode=="SDN"
bys wbcode year: drop if hf_business==.
merge 1:1 wbcode year using "temp3.dta"
drop if _merge!=3
drop _merge
rename hf_business bus_freedom

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & bus_freedom!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & bus_freedom!=.
scalar maxyear23=r(max)
local maxyear23: display %9.0f maxyear23
scalar minyear23=r(min)
local minyear23: display %9.0f minyear23

keep if year==`=minyear23' | year==`=maxyear23'

* Coordinates for country
summ bus_freedom if wbcode=="`ctry'" & year==`=minyear23'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear23'
scalar x1=r(mean)
gen x1=`=x1'
summ bus_freedom if wbcode=="`ctry'" & year==`=maxyear23'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear23'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear23'!=. & `=minyear23'!=. {
	* Figure 23: Business Freedom (vs World)
	lpoly bus_freedom lngdppc2 if year==`=minyear23', noscatter /*
	*/ title("Business Freedom, `=minyear23' and `=maxyear23'") subtitle("`j'") /*
	*/ note("Note: The Business Freedom score encompasses 10 components: starting a business" /*
	*/ "(procedures, time, cost, and minimum capital), obtaining a licence (procedures, time, and cost)," /*
	*/ "and closing a business (time, cost, and recovery rate)" /*
	*/ "Data source: The Quality of Government Dataset (Heritage Foundation) and World Development" "Indicators") /*
	*/ ytitle("Business Freedom score") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear23'") lab(2 "`=maxyear23'"))	/*
	*/ addplot(lpoly bus_freedom lngdppc2 if year==`=maxyear23' || /*
	*/ scatter bus_freedom lngdppc2 if wbcode=="`ctry'" & year==`=minyear23', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter bus_freedom lngdppc2 if wbcode=="`ctry'" & year==`=maxyear23', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure23`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure23`ctry'_2C.png") append
}
restore

********************************************************************************************************************************************************

*****************************************************
** COMPOSITION OF EXPORTS: HIGH-TECHNOLOGY EXPORTS **
*****************************************************
gen tech_exp=TX_VAL_TECH_MF_ZS*TX_VAL_MANF_ZS_UN/100
preserve

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & tech_exp!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & tech_exp!=.
scalar maxyear24=r(max)
local maxyear24: display %9.0f maxyear24
scalar minyear24=r(min)
local minyear24: display %9.0f minyear24

keep if year==`=minyear24' | year==`=maxyear24'

* Coordinates for country
summ tech_exp if wbcode=="`ctry'" & year==`=minyear24'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear24'
scalar x1=r(mean)
gen x1=`=x1'
summ tech_exp if wbcode=="`ctry'" & year==`=maxyear24'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear24'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear24'!=. & `=minyear24'!=. {
	* Figure 24: High-technology exports (vs World)
	lpoly tech_exp lngdppc2 if year==`=minyear24', noscatter /*
	*/ title("High-technology exports, `=minyear24' and `=maxyear24'") subtitle("`j'") note("Data source: World Development Indicators") /*
	*/ ytitle("High-technology exports (% of merchandise exports)") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear24'") lab(2 "`=maxyear24'"))	/*
	*/ addplot(lpoly tech_exp lngdppc2 if year==`=maxyear24' || /*
	*/ scatter tech_exp lngdppc2 if wbcode=="`ctry'" & year==`=minyear24', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter tech_exp lngdppc2 if wbcode=="`ctry'" & year==`=maxyear24', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))
	
	* Exporting results into word document
	gr export "$dir\figure24`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure24`ctry'_2C.png") append
}
restore
save "temp4.dta", replace

***************************************
** COMPOSITION OF EXPORTS: DIVERSITY **
***************************************
preserve
use "$complexity", clear /*CID dataset*/
rename iso wbcode
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp4.dta"
drop if _merge!=3
drop _merge

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & diversity_rca!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & diversity_rca!=.
scalar maxyear25=r(max)
local maxyear25: display %9.0f maxyear25
scalar minyear25=r(min)
local minyear25: display %9.0f minyear25

keep if year==`=minyear25' | year==`=maxyear25'

* Coordinates for country
summ diversity_rca if wbcode=="`ctry'" & year==`=minyear25'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear25'
scalar x1=r(mean)
gen x1=`=x1'
summ diversity_rca if wbcode=="`ctry'" & year==`=maxyear25'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear25'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear25'!=. & `=minyear25'!=. {
	* Figure 25: Diversity of exports (vs World)
	lpoly diversity_rca lngdppc2 if year==`=minyear25', noscatter /*
	*/ title("Diversity of exports, `=minyear25' and `=maxyear25'") subtitle("`j'") /*
	*/ note("Note: Revealed Comparative Advantage (RCA) measures the share of the exported value of the" /*
	*/ "product in the total exported amount of a given country relative to the average world's share" "Data source: CID database") /*
	*/ ytitle("Number of products exported with RCA") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear25'") lab(2 "`=maxyear25'"))	/*
	*/ addplot(lpoly diversity_rca lngdppc2 if year==`=maxyear25' || /*
	*/ scatter diversity_rca lngdppc2 if wbcode=="`ctry'" & year==`=minyear25', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter diversity_rca lngdppc2 if wbcode=="`ctry'" & year==`=maxyear25', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure25`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure25`ctry'_2C.png") append
}
restore
save "temp4.dta", replace

*************************************************
** COMPOSITION OF EXPORTS: ECONOMIC COMPLEXITY **
*************************************************
preserve
use "$complexity", clear /*CID dataset*/
rename iso wbcode
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp4.dta"
drop if _merge!=3
drop _merge
format eci_rca %9.1fc

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & eci_rca!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & eci_rca!=.
scalar maxyear26=r(max)
local maxyear26: display %9.0f maxyear26
scalar minyear26=r(min)
local minyear26: display %9.0f minyear26

keep if year==`=minyear26' | year==`=maxyear26'

* Coordinates for country
summ eci_rca if wbcode=="`ctry'" & year==`=minyear26'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear26'
scalar x1=r(mean)
gen x1=`=x1'
summ eci_rca if wbcode=="`ctry'" & year==`=maxyear26'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear26'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear26'!=. & `=minyear26'!=. {
	* Figure 26: Economic Complexity Index (vs World)
	lpoly eci_rca lngdppc2 if year==`=minyear26', noscatter /*
	*/ title("Economic Complexity, `=minyear26' and `=maxyear26'") subtitle("`j'") note("Data source: CID database") /*
	*/ ytitle("Economic Complexity Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear26'") lab(2 "`=maxyear26'"))	/*
	*/ addplot(lpoly eci_rca lngdppc2 if year==`=maxyear26' || /*
	*/ scatter eci_rca lngdppc2 if wbcode=="`ctry'" & year==`=minyear26', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter eci_rca lngdppc2 if wbcode=="`ctry'" & year==`=maxyear26', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure26`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure26`ctry'_2C.png") append
}
restore
save "temp4.dta", replace

************************************************
** COMPOSITION OF EXPORTS: COMPLEXITY OUTLOOK **
************************************************
preserve
use "$complexity", clear /*CID dataset*/
rename iso wbcode
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp4.dta"
drop if _merge!=3
drop _merge
rename oppvalue_rca coi_rca
format coi_rca %9.1fc

* Maximum and Minimum years
forval x=1960(1)2013 {
	count if lngdppc2!=. & year==`x' & coi_rca!=.
	if r(N)<30 {
		drop if year==`x'
	}
}
summ year if wbcode=="`ctry'" & lngdppc2!=. & coi_rca!=.
scalar maxyear27=r(max)
local maxyear27: display %9.0f maxyear27
scalar minyear27=r(min)
local minyear27: display %9.0f minyear27

keep if year==`=minyear27' | year==`=maxyear27'

* Coordinates for country
summ coi_rca if wbcode=="`ctry'" & year==`=minyear27'
scalar y1=r(mean)
gen y1=`=y1'
summ lngdppc2 if wbcode=="`ctry'" & year==`=minyear27'
scalar x1=r(mean)
gen x1=`=x1'
summ coi_rca if wbcode=="`ctry'" & year==`=maxyear27'
scalar y2=r(mean)
gen y2=`=y2'
summ lngdppc2 if wbcode=="`ctry'" & year==`=maxyear27'
scalar x2=r(mean)
gen x2=`=x2'

if `=maxyear27'!=. & `=minyear27'!=. {
	* Figure 27: Economic Complexity Index (vs World)
	lpoly coi_rca lngdppc2 if year==`=minyear27', noscatter /*
	*/ title("Complexity Outlook, `=minyear27' and `=maxyear27'") subtitle("`j'") note("Data source: CID database") /*
	*/ ytitle("Complexity Outlook Index") xtitle("GDP per capita, PPP (constant 2005 international $), log") /*
	*/ legend(order(1 2) lab(1 "`=minyear27'") lab(2 "`=maxyear27'"))	/*
	*/ addplot(lpoly coi_rca lngdppc2 if year==`=maxyear27' || /*
	*/ scatter coi_rca lngdppc2 if wbcode=="`ctry'" & year==`=minyear27', mlabel(wbcode) mlabsize(vsmall) mcolor(red) mlabcolor(red) || /*
	*/ scatter coi_rca lngdppc2 if wbcode=="`ctry'" & year==`=maxyear27', mcolor(red) || /*
	*/ pcarrow y1 x1 y2 x2 if wbcode=="`ctry'", mcolor(black) mfcolor(black) mlcolor(black) lcolor(black) lwidth(medium) msize(medlarge))

	* Exporting results into word document
	gr export "$dir\figure27`ctry'_2C.png", height(548) width(753) replace
	png2rtf using "$dir\analysis`ctry'_2C.doc", g("$dir\figure27`ctry'_2C.png") append
}
restore
********************************************************************************************************************************************************

scalar drop _all
macro drop _all
erase "temp.dta"
forval x=1/27 {
	erase "temp`x'.dta"
}
