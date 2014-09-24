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
	global education "C:\Users\Luis Miguel\Documents\Bases de Datos\md4stata\Educational Attainment (Barro & Lee)\BL2013_MF2599_v1.3.dta"
	* PHYSICAL CAPITAL
	global capital "C:\Users\Luis Miguel\Documents\Bases de Datos\Penn World Tables\pwt80\pwt80.dta"
	* TAX REVENUE
	global revenue "C:\Users\Luis Miguel\Documents\Bases de Datos\IMF\taxrevenue.dta"
	* INSTITUTIONS
	global institutions "C:\Users\Luis Miguel\Documents\Bases de Datos\The Quality of Government Institute\Standard data\qog_std_ts_20dec13.dta"
	* COMPLEXITY
	global complexity "C:\Users\Luis Miguel\Documents\Bases de Datos\CID - Harvard\complexity_y_c.dta"
* COUNTRY TO BE ANALYZED
local ctry PER
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
label var year "Years"

* Identification of growth collapses and accelerations
	rename NY_GDP_PCAP_KD gdppc
	summ year if wbcode=="`ctry'" & gdppc!=.
	* Minimum
	scalar minyear=r(min)
	local minyear: display %9.0fc minyear
	*Maximum
	scalar maxyear=r(max)
	local maxyear: display %9.0fc maxyear
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

*********************************************
** STRUCTURAL TRANSFORMATION: URBANIZATION **
*********************************************
rename SP_URB_TOTL_IN_ZS urban_pop
preserve

* Statistics for Figure 1
summ year if wbcode=="`ctry'" & urban_pop!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ urban_pop if wbcode=="`ctry'"
scalar max_urban_pop=r(max)
gen max_urban_pop=`=max_urban_pop' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 1
twoway connect urban_pop year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_urban_pop year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Urban population (% of total)") /*
*/ title("Urbanization, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure1`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure1`ctry'_2B.png") replace
}
scalar drop minyear maxyear
macro drop minyear maxyear
restore

*********************************************************
** STRUCTURAL TRANSFORMATION: AGRICULTURE SHARE OF GDP **
*********************************************************
rename NV_AGR_TOTL_ZS agr_gdp
preserve

* Statistics for Figure 2
summ year if wbcode=="`ctry'" & agr_gdp!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ agr_gdp if wbcode=="`ctry'"
scalar max_agr_gdp=r(max)
gen max_agr_gdp=`=max_agr_gdp' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 2
twoway connect agr_gdp year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_agr_gdp year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Agriculture, value added (% of GDP)") /*
*/ title("Share of agriculture in GDP, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Note: Agriculture corresponds to ISIC Rev.3 divisions 1-5" "Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure2`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure2`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

***********************************************************
** STRUCTURAL TRANSFORMATION: MANUFACTURING SHARE OF GDP **
***********************************************************
rename NV_IND_MANF_ZS mnf_gdp
preserve

* Statistics for Figure 3
summ year if wbcode=="`ctry'" & mnf_gdp!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ mnf_gdp if wbcode=="`ctry'"
scalar max_mnf_gdp=r(max)
gen max_mnf_gdp=`=max_mnf_gdp' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 3
twoway connect mnf_gdp year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_mnf_gdp year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Manufacturing, value added (% of GDP)") /*
*/ title("Share of manufacturing in GDP, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Note: Manufacturing corresponds to ISIC Rev.3 divisions 15-37" "Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure3`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure3`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

******************************************************
** STRUCTURAL TRANSFORMATION: INDUSTRY SHARE OF GDP **
******************************************************
rename NV_IND_TOTL_ZS ind_gdp
preserve

* Statistics for Figure 4
summ year if wbcode=="`ctry'" & ind_gdp!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ ind_gdp if wbcode=="`ctry'"
scalar max_ind_gdp=r(max)
gen max_ind_gdp=`=max_ind_gdp' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 4
twoway connect ind_gdp year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_ind_gdp year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Industry, value added (% of GDP)") /*
*/ title("Share of industry in GDP, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Note: Industry corresponds to ISIC Rev.3 divisions 10-45" "Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure4`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure4`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

******************************************************
** STRUCTURAL TRANSFORMATION: SERVICES SHARE OF GDP **
******************************************************
rename NV_SRV_TETC_ZS ss_gdp
preserve

* Statistics for Figure 5
summ year if wbcode=="`ctry'" & ss_gdp!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ ss_gdp if wbcode=="`ctry'"
scalar max_ss_gdp=r(max)
gen max_ss_gdp=`=max_ss_gdp' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 5
twoway connect ss_gdp year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_ss_gdp year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Services, value added (% of GDP)") /*
*/ title("Share of services in GDP, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Note: Services correspond to ISIC Rev.3 divisions 50-99" "Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure5`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure5`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

**********************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN AGRICULTURE **
**********************************************************
rename SL_AGR_EMPL_ZS emp_agr
preserve

* Statistics for Figure 6
summ year if wbcode=="`ctry'" & emp_agr!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ emp_agr if wbcode=="`ctry'"
scalar max_emp_agr=r(max)
gen max_emp_agr=`=max_emp_agr' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 6
twoway connect emp_agr year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_emp_agr year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Employment in agriculture (% of total employment)") /*
*/ title("Agriculture employment, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Note: Agriculture corresponds to ISIC Rev.3 divisions 1-5" "Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure6`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure6`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

*******************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN INDUSTRY **
*******************************************************
rename SL_IND_EMPL_ZS emp_ind
preserve

* Statistics for Figure 7
summ year if wbcode=="`ctry'" & emp_ind!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ emp_ind if wbcode=="`ctry'"
scalar max_emp_ind=r(max)
gen max_emp_ind=`=max_emp_ind' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 7
twoway connect emp_ind year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_emp_ind year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Employment in industry (% of total employment)") /*
*/ title("Industry employment, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Note: Industry corresponds to ISIC Rev.3 divisions 10-45" "Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure7`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure7`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

*******************************************************
** STRUCTURAL TRANSFORMATION: EMPLOYMENT IN SERVICES **
*******************************************************
rename SL_SRV_EMPL_ZS emp_ss
preserve

* Statistics for Figure 8
summ year if wbcode=="`ctry'" & emp_ss!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ emp_ss if wbcode=="`ctry'"
scalar max_emp_ss=r(max)
gen max_emp_ss=`=max_emp_ss' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 8
twoway connect emp_ss year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_emp_ss year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Employment in services (% of total employment)") /*
*/ title("Services employment, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Note: Services correspond to ISIC Rev.3 divisions 50-99" "Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure8`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure8`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore
********************************************************************************************************************************************************

*****************************************************
** PHYSICAL CAPITAL: ENERGY CONSUMPTION PER CAPITA **
*****************************************************
rename EG_USE_PCAP_KG_OE energypc
gen logenergypc=log(energypc)
preserve

* Statistics for Figure 9
summ year if wbcode=="`ctry'" & logenergypc!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ logenergypc if wbcode=="`ctry'"
scalar max_logenergypc=r(max)
gen max_logenergypc=`=max_logenergypc' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 9
twoway connect logenergypc year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_logenergypc year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Energy use (kg of oil equivalent per capita), log") /*
*/ title("Energy consumption per capita, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure9`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure9`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

*******************************************
** PHYSICAL CAPITAL: CAPITAL PER WORKER **
*******************************************
save "temp.dta", replace
use "$capital", clear /*Penn World Tables*/
rename countrycode wbcode
replace wbcode="ZAR" if wbcode=="COD"
replace wbcode="ROM" if wbcode=="ROU"
keep wbcode year rkna rtfpna
merge 1:1 wbcode year using "temp.dta"
drop _merge
replace country="`j'" if wbcode=="`ctry'"
sort wbcode year
gen kpw=log(rkna*1000000/SL_TLF_TOTL_IN)
preserve

* Statistics for Figure 10
summ year if wbcode=="`ctry'" & kpw!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max/Min variable
summ kpw if wbcode=="`ctry'"
scalar max_kpw=r(max)
gen max_kpw=`=max_kpw' if wbcode=="`ctry'"
scalar min_kpw=r(min)
gen min_kpw=`=min_kpw' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 10
twoway connect kpw year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_kpw year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) || /*
*/ spike min_kpw year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Capital stock/labor force" "(at constant 2005 national prices), log") /*
*/ title("Capital per worker, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: Penn World Table 8.0")

* Exporting results into word document
gr export "$dir\figure10`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure10`ctry'_2B.png") append
}
scalar drop minyear maxyear
macro drop minyear maxyear
restore

********************************************************************************************************************************************************
***************************************************************
** HUMAN CAPITAL: YEARS OF SCHOOLING (OF POPULATION OVER 25) **
***************************************************************
save "temp.dta", replace
use "$education", clear /*Barro and Lee only have data for every 5 years*/
keep wbcode year yr_sch
merge 1:1 wbcode year using "temp.dta" 
drop _merge
replace country="`j'" if wbcode=="`ctry'"
sort wbcode year
rename yr_sch school
preserve

* Statistics for Figure 11
summ year if wbcode=="`ctry'" & school!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ school if wbcode=="`ctry'"
scalar max_school=r(max)
gen max_school=`=max_school' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 11
twoway connect school year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_school year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Years of schooling") /*
*/ title("Years of schooling, `=minyear'-`=maxyear'") subtitle("Population aged 25 and over, `j'") /*
*/ note("Data source: Barro-Lee dataset")

* Exporting results into word document
gr export "$dir\figure11`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure11`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

**************************************
** HUMAN CAPITAL: PRIMARY SCHOOLING **
**************************************
save "temp.dta", replace
use "$education", clear /*Barro and Lee only have data for every 5 years*/
keep wbcode year lp
merge 1:1 wbcode year using "temp.dta" 
drop _merge
replace country="`j'" if wbcode=="`ctry'"
sort wbcode year
rename lp prim
preserve

* Statistics for Figure 12
summ year if wbcode=="`ctry'" & prim!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ prim if wbcode=="`ctry'"
scalar max_prim=r(max)
gen max_prim=`=max_prim' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 12
twoway connect prim year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_prim year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Primary schooling attained in Pop. (%)") /*
*/ title("Primary schooling, `=minyear'-`=maxyear'") subtitle("Population aged 25 and over, `j'") /*
*/ note("Data source: Barro-Lee dataset")

* Exporting results into word document
gr export "$dir\figure12`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure12`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

****************************************
** HUMAN CAPITAL: SECONDARY SCHOOLING **
****************************************
save "temp.dta", replace
use "$education", clear /*Barro and Lee only have data for every 5 years*/
keep wbcode year ls
merge 1:1 wbcode year using "temp.dta" 
drop _merge
replace country="`j'" if wbcode=="`ctry'"
sort wbcode year
rename ls sec
preserve

* Statistics for Figure 13
summ year if wbcode=="`ctry'" & sec!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ sec if wbcode=="`ctry'"
scalar max_sec=r(max)
gen max_sec=`=max_sec' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 13
twoway connect sec year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_sec year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Secondary schooling attained in Pop. (%)") /*
*/ title("Secondary schooling, `=minyear'-`=maxyear'") subtitle("Population aged 25 and over, `j'") /*
*/ note("Data source: Barro-Lee dataset")

* Exporting results into word document
gr export "$dir\figure13`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure13`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

****************************************
** HUMAN CAPITAL: TERTIARY SCHOOLING **
****************************************
save "temp.dta", replace
use "$education", clear /*Barro and Lee only have data for every 5 years*/
keep wbcode year lh
merge 1:1 wbcode year using "temp.dta" 
drop _merge
replace country="`j'" if wbcode=="`ctry'"
sort wbcode year
rename lh univ
preserve

* Statistics for Figure 14
summ year if wbcode=="`ctry'" & univ!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ univ if wbcode=="`ctry'"
scalar max_univ=r(max)
gen max_univ=`=max_univ' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 14
twoway connect univ year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_univ year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Tertiary schooling attained in Pop. (%)") /*
*/ title("Tertiary schooling, `=minyear'-`=maxyear'") subtitle("Population aged 25 and over, `j'") /*
*/ note("Data source: Barro-Lee dataset")

* Exporting results into word document
gr export "$dir\figure14`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure14`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

**************************************************************
** HUMAN CAPITAL: SCIENTIFIC AND TECHNICAL JOURNAL ARTICLES **
**************************************************************
gen journal=IP_JRN_ARTC_SC*1000/SP_POP_TOTL
preserve

* Statistics for Figure 15
summ year if wbcode=="`ctry'" & journal!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ journal if wbcode=="`ctry'"
scalar max_journal=r(max)
gen max_journal=`=max_journal' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 15
twoway connect journal year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_journal year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Scientific and technical journal articles per 1,000 people") /*
*/ title("Scientific and Technical Journal Articles, `=minyear'-`=maxyear'") subtitle("Per 1,000 people, `j'") /*
*/ note("Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure15`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure15`ctry'_2B.png") append
}
scalar drop minyear maxyear
macro drop minyear maxyear
restore

***************************************
** HUMAN CAPITAL: RESEARCHERS IN R&D **
***************************************
rename SP_POP_SCIE_RD_P6 research
preserve

* Statistics for Figure 16
summ year if wbcode=="`ctry'" & research!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ research if wbcode=="`ctry'"
scalar max_research=r(max)
gen max_research=`=max_research' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 16
twoway connect research year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_research year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Researchers in R&D per million people") /*
*/ title("Researchers in R&D, `=minyear'-`=maxyear'") subtitle("Per million people, `j'") /*
*/ note("Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure16`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure16`ctry'_2B.png") append
}
scalar drop minyear maxyear
macro drop minyear maxyear
restore

********************************************************************************************************************************************************
**********************************
** POPULATION: INFANT MORTALITY **
**********************************
rename SP_DYN_IMRT_IN infant
preserve

* Statistics for Figure 17
summ year if wbcode=="`ctry'" & infant!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ infant if wbcode=="`ctry'"
scalar max_infant=r(max)
gen max_infant=`=max_infant' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 17
twoway connect infant year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_infant year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Mortality rate, infant (per 1,000 live births)") /*
*/ title("Infant mortality, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure17`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure17`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

********************************
** POPULATION: FERTILITY RATE **
********************************
rename SP_DYN_TFRT_IN fertil
preserve

* Statistics for Figure 18
summ year if wbcode=="`ctry'" & fertil!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ fertil if wbcode=="`ctry'"
scalar max_fertil=r(max)
gen max_fertil=`=max_fertil' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 18
twoway connect fertil year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_fertil year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Fertility rate, total (births per woman)") /*
*/ title("Fertility rate, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure18`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure18`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

*********************************
** POPULATION: LIFE EXPECTANCY **
*********************************
rename SP_DYN_LE00_IN life
preserve

* Statistics for Figure 19
summ year if wbcode=="`ctry'" & life!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ life if wbcode=="`ctry'"
scalar max_life=r(max)
gen max_life=`=max_life' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 19
twoway connect life year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_life year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Life expectancy at birth, total (years)") /*
*/ title("Life expectancy, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure19`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure19`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

***********************************
** POPULATION: POPULATION GROWTH **
***********************************
rename SP_POP_GROW pop_g
preserve

* Statistics for Figure 20
summ year if wbcode=="`ctry'" & pop_g!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ pop_g if wbcode=="`ctry'"
scalar max_pop_g=r(max)
gen max_pop_g=`=max_pop_g' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 20
twoway connect pop_g year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_pop_g year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Population growth (annual %)") /*
*/ title("Population growth, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure20`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure20`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

**************************************
** POPULATION: DEMOGRAPHIC DIVIDEND **
**************************************
rename SP_POP_DPND depend
preserve

* Statistics for Figure 21
summ year if wbcode=="`ctry'" & depend!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ depend if wbcode=="`ctry'"
scalar max_depend=r(max)
gen max_depend=`=max_depend' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 21
twoway connect depend year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_depend year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Age dependency ratio (% of working-age population)") /*
*/ title("Demographic dividend, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure21`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure21`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore
********************************************************************************************************************************************************
**************************
** PRODUCTIVITY AND TFP **
**************************
preserve

* Statistics for Figure 22
summ year if wbcode=="`ctry'" & rtfpna!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ rtfpna if wbcode=="`ctry'"
scalar max_rtfpna=r(max)
gen max_rtfpna=`=max_rtfpna' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 22
twoway connect rtfpna year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_rtfpna year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("TFP level at constant national prices (2005=1)") /*
*/ title("Total Factor Productivity, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: Penn World Table 8.0")

* Exporting results into word document
gr export "$dir\figure22`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure22`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore
********************************************************************************************************************************************************
********************************************
** POLICY AND INSTITUTIONS: TAXES REVENUE **
********************************************
save "temp.dta", replace
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
keep wbcode year y
merge 1:1 wbcode year using "temp.dta"
drop _merge
sort wbcode year
rename y tax_gdp
preserve

* Statistics for Figure 23
summ year if wbcode=="`ctry'" & tax_gdp!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ tax_gdp if wbcode=="`ctry'"
scalar max_tax_gdp=r(max)
gen max_tax_gdp=`=max_tax_gdp' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 23
twoway connect tax_gdp year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_tax_gdp year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("General government revenue (% of GDP)") /*
*/ title("Government revenue, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: World Economic Outlook")

* Exporting results into word document
gr export "$dir\figure23`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure23`ctry'_2B.png") append
}
scalar drop minyear maxyear
macro drop minyear maxyear
restore

***************************************
** POLICY AND INSTITUTIONS: OPENNESS **
***************************************
gen open=NE_EXP_GNFS_ZS+NE_IMP_GNFS_ZS
preserve

* Statistics for Figure 24
summ year if wbcode=="`ctry'" & open!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ open if wbcode=="`ctry'"
scalar max_open=r(max)
gen max_open=`=max_open' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 24
twoway connect open year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_open year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Exports + Imports of goods and services (% of GDP)") /*
*/ title("Openness, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure24`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure24`ctry'_2B.png") append
}
scalar drop minyear maxyear
macro drop minyear maxyear
restore

****************************************
** POLICY AND INSTITUTIONS: DEMOCRACY **
****************************************
save "temp.dta", replace
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
keep wbcode year fh_ipolity2 fh_rol hf_efiscore hf_business
merge 1:1 wbcode year using "temp.dta"
drop _merge
sort wbcode year
rename fh_ipolity2 demo
preserve

* Statistics for Figure 25
summ year if wbcode=="`ctry'" & demo!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ demo if wbcode=="`ctry'"
scalar max_demo=r(max)
gen max_demo=`=max_demo' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 25
twoway connect demo year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_demo year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Democracy (Freedom House/Imputed Polity)") /*
*/ title("Democracy, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: The Quality of Government Dataset (Freedom House/Polity)")

* Exporting results into word document
gr export "$dir\figure25`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure25`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

******************************************
** POLICY AND INSTITUTIONS: RULE OF LAW **
******************************************
rename fh_rol rule
preserve

* Statistics for Figure 26
summ year if wbcode=="`ctry'" & rule!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ rule if wbcode=="`ctry'"
scalar max_rule=r(max)
gen max_rule=`=max_rule' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 26
twoway connect rule year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_rule year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Rule of Law") /*
*/ title("Rule of Law, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: The Quality of Government Dataset (Freedom House)")

* Exporting results into word document
gr export "$dir\figure26`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure26`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

***********************************************
** POLICY AND INSTITUTIONS: ECONOMIC FREEDOM **
***********************************************
rename hf_efiscore econ_freedom
preserve

* Statistics for Figure 27
summ year if wbcode=="`ctry'" & econ_freedom!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ econ_freedom if wbcode=="`ctry'"
scalar max_econ_freedom=r(max)
gen max_econ_freedom=`=max_econ_freedom' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 27
twoway connect econ_freedom year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_econ_freedom year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Economic Freedom Index") /*
*/ title("Economic Freedom, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Note: The Economic Freedom Index uses 10 specific freedoms: business, trade, fiscal, from" /*
*/ "government, monetary, investment, financial, property rights, from corruption, and labor" /*
*/ "Data source: The Quality of Government Dataset (Heritage Foundation)")

* Exporting results into word document
gr export "$dir\figure27`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure27`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

***********************************************
** POLICY AND INSTITUTIONS: BUSINESS FREEDOM **
***********************************************
rename hf_business bus_freedom
preserve

* Statistics for Figure 28
summ year if wbcode=="`ctry'" & bus_freedom!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ bus_freedom if wbcode=="`ctry'"
scalar max_bus_freedom=r(max)
gen max_bus_freedom=`=max_bus_freedom' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 28
twoway connect bus_freedom year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_bus_freedom year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Business Freedom score") /*
*/ title("Business Freedom, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Note: The Business Freedom score encompasses 10 components: starting a business" /*
*/ "(procedures, time, cost, and minimum capital), obtaining a licence (procedures, time, and cost)," /*
*/ "and closing a business (time, cost, and recovery rate)" /*
*/ "Data source: The Quality of Government Dataset (Heritage Foundation)")

* Exporting results into word document
gr export "$dir\figure28`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure28`ctry'_2B.png") append
}	
scalar drop minyear maxyear
macro drop minyear maxyear
restore

****************************************************************
** COMPOSITION OF EXPORTS: HIGH-TECHNOLOGY EXPORTS PER CAPITA **
****************************************************************
gen tech_exp=log(TX_VAL_TECH_CD/SP_POP_TOTL)
preserve

* Statistics for Figure 29
summ year if wbcode=="`ctry'" & tech_exp!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max/Min variable
summ tech_exp if wbcode=="`ctry'"
scalar max_tech_exp=r(max)
gen max_tech_exp=`=max_tech_exp' if wbcode=="`ctry'"
scalar min_tech_exp=r(min)
gen min_tech_exp=`=min_tech_exp' if wbcode=="`ctry'"


if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 29
twoway connect tech_exp year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_tech_exp year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) || /*
*/ spike min_tech_exp year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("High-technology exports per capita (current US$), log") /*
*/ title("High-technology exports per capita, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: World Development Indicators")

* Exporting results into word document
gr export "$dir\figure29`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure29`ctry'_2B.png") append
}
scalar drop minyear maxyear
macro drop minyear maxyear
restore

***************************************
** COMPOSITION OF EXPORTS: DIVERSITY **
***************************************
save "temp.dta", replace
preserve
use "$complexity", clear /*CID dataset*/
rename iso wbcode
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge

* Statistics for Figure 30
summ year if wbcode=="`ctry'" & diversity_rca!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max variable
summ diversity_rca if wbcode=="`ctry'"
scalar max_diversity_rca=r(max)
gen max_diversity_rca=`=max_diversity_rca' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 30
twoway connect diversity_rca year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_diversity_rca year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Number of products exported with RCA") /*
*/ title("Diversity of exports, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Note: Revealed Comparative Advantage (RCA) measures the share of the exported value of the" /*
*/ "product in the total exported amount of a given country relative to the average world's share" "Data source: CID database")

* Exporting results into word document
gr export "$dir\figure30`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure30`ctry'_2B.png") append
}
scalar drop minyear maxyear
macro drop minyear maxyear
restore

*************************************************
** COMPOSITION OF EXPORTS: ECONOMIC COMPLEXITY **
*************************************************
save "temp.dta", replace
preserve
use "$complexity", clear /*CID dataset*/
rename iso wbcode
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge
format eci_rca %9.1fc

* Statistics for Figure 31
summ year if wbcode=="`ctry'" & eci_rca!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max/Min variable
summ eci_rca if wbcode=="`ctry'"
scalar max_eci_rca=r(max)
gen max_eci_rca=`=max_eci_rca' if wbcode=="`ctry'"
scalar min_eci_rca=r(min)
gen min_eci_rca=`=min_eci_rca' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 31
twoway connect eci_rca year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_eci_rca year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) || /*
*/ spike min_eci_rca year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Economic Complexity Index") /*
*/ title("Economic Complexity, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: CID database")

* Exporting results into word document
gr export "$dir\figure31`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure31`ctry'_2B.png") append
}
scalar drop minyear maxyear
macro drop minyear maxyear
restore

************************************************
** COMPOSITION OF EXPORTS: COMPLEXITY OUTLOOK **
************************************************
save "temp.dta", replace
preserve
use "$complexity", clear /*CID dataset*/
rename iso wbcode
replace wbcode="ROM" if wbcode=="ROU"
merge 1:1 wbcode year using "temp.dta"
drop if _merge!=3
drop _merge
rename oppvalue_rca coi_rca
format coi_rca %9.1fc

* Statistics for Figure 31
summ year if wbcode=="`ctry'" & coi_rca!=.
* Minimum
scalar minyear=r(min)
local minyear: display %9.0fc minyear
*Maximum
scalar maxyear=r(max)
local maxyear: display %9.0fc maxyear
* Max/Min variable
summ coi_rca if wbcode=="`ctry'"
scalar max_coi_rca=r(max)
gen max_coi_rca=`=max_coi_rca' if wbcode=="`ctry'"
scalar min_coi_rca=r(min)
gen min_coi_rca=`=min_coi_rca' if wbcode=="`ctry'"

if `=minyear'!=. & `=maxyear'!=. & `=minyear'!=`=maxyear' {
* Figure 31
twoway connect coi_rca year if wbcode=="`ctry'" & year>=`=minyear', xlabel(`=minyear'(5)`=maxyear') xsc(range(`=minyear'(5)`=maxyear')) lwidth(medthick) || /*
*/ spike max_coi_rca year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) || /*
*/ spike min_coi_rca year if wbcode=="`ctry'" & milestone==1 & year>=`=minyear', lcolor(gs8) legend(off) /*
*/ ytitle("Complexity Outlook Index") /*
*/ title("Complexity Outlook, `=minyear'-`=maxyear'") subtitle("`j'") /*
*/ note("Data source: CID database")

* Exporting results into word document
gr export "$dir\figure31`ctry'_2B.png", height(548) width(753) replace
png2rtf using "$dir\analysis`ctry'_2B.doc", g("$dir\figure31`ctry'_2B.png") append
}
scalar drop minyear maxyear
macro drop minyear maxyear
restore
********************************************************************************************************************************************************
scalar drop _all
macro drop _all
erase "temp.dta"
