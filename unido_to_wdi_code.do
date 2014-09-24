clear all
insheet ctable country year isic isiccomb value utable source lastupdated unit using "C:\Users\Luis Miguel\Documents\Bases de Datos\UNIDO\va_allyears_allcountries_allsectors_4.csv", comma nonames
label variable ctable "Table Code"
label variable country "Country Code"
label variable year "Year"
label variable isic "ISIC Code"
label variable isiccomb "ISIC Combination Code"
label variable value "Value"
label variable utable "Table Definition code"
label variable source "Source Code"
label variable lastupdated "Last updated"
label variable unit "Unit"
destring value, replace ignore(".")
gen wbcode=""
replace wbcode="AFG" if country==4
replace wbcode="ALB" if country==8	
replace wbcode="DZA" if country==12
replace wbcode="AGO" if country==24
replace wbcode="ARG" if country==32
replace wbcode="ARM" if country==51
replace wbcode="ABW" if country==533
replace wbcode="AUS" if country==36
replace wbcode="AUT" if country==40
replace wbcode="AZE" if country==31
replace wbcode="BHS" if country==44
replace wbcode="BGD" if country==50
replace wbcode="BRB" if country==52
replace wbcode="BLR" if country==112
replace wbcode="BEL" if country==56
replace wbcode="BLZ" if country==84
replace wbcode="BEN" if country==204
replace wbcode="BMU" if country==60
replace wbcode="BOL" if country==68
replace wbcode="BIH" if country==70
replace wbcode="BWA" if country==72
replace wbcode="BRA" if country==76
replace wbcode="BGR" if country==100
replace wbcode="BFA" if country==854
replace wbcode="BDI" if country==108
replace wbcode="KHM" if country==116
replace wbcode="CMR" if country==120
replace wbcode="CAN" if country==124
replace wbcode="CAF" if country==140
replace wbcode="CHL" if country==152
replace wbcode="CHN" if country==156
replace wbcode="HKG" if country==344
replace wbcode="MAC" if country==446
replace wbcode="COL" if country==170
replace wbcode="COG" if country==178
replace wbcode="CRI" if country==188
replace wbcode="CIV" if country==384
replace wbcode="HRV" if country==191
replace wbcode="CUB" if country==192
replace wbcode="CUW" if country==531
replace wbcode="CYP" if country==196
replace wbcode="CZE" if country==203
replace wbcode="DNK" if country==208
replace wbcode="DOM" if country==214
replace wbcode="ECU" if country==218
replace wbcode="EGY" if country==818
replace wbcode="SLV" if country==222
replace wbcode="ERI" if country==232
replace wbcode="EST" if country==233
replace wbcode="ETH" if country==231
replace wbcode="FJI" if country==242
replace wbcode="FIN" if country==246
replace wbcode="FRA" if country==250
replace wbcode="GAB" if country==266
replace wbcode="GMB" if country==270
replace wbcode="GEO" if country==268
replace wbcode="DEU" if country==276
replace wbcode="GHA" if country==288
replace wbcode="GRC" if country==300
replace wbcode="GTM" if country==320
replace wbcode="HTI" if country==332
replace wbcode="HND" if country==340
replace wbcode="HUN" if country==348
replace wbcode="ISL" if country==352
replace wbcode="IND" if country==356
replace wbcode="IDN" if country==360
replace wbcode="IRN" if country==364
replace wbcode="IRQ" if country==368
replace wbcode="IRL" if country==372
replace wbcode="ISR" if country==376
replace wbcode="ITA" if country==380
replace wbcode="JAM" if country==388
replace wbcode="JPN" if country==392
replace wbcode="JOR" if country==400
replace wbcode="KAZ" if country==398
replace wbcode="KEN" if country==404
replace wbcode="KOR" if country==410
replace wbcode="KWT" if country==414
replace wbcode="KGZ" if country==417
replace wbcode="LAO" if country==418
replace wbcode="LVA" if country==428
replace wbcode="LBN" if country==422
replace wbcode="LSO" if country==426
replace wbcode="LBR" if country==430
replace wbcode="LBY" if country==434
replace wbcode="LIE" if country==438
replace wbcode="LTU" if country==440
replace wbcode="LUX" if country==442
replace wbcode="MKD" if country==807
replace wbcode="MDG" if country==450
replace wbcode="MWI" if country==454
replace wbcode="MYS" if country==458
replace wbcode="MLT" if country==470
replace wbcode="MUS" if country==480
replace wbcode="MEX" if country==484
replace wbcode="MDA" if country==498
replace wbcode="MNG" if country==496
replace wbcode="MAR" if country==504
replace wbcode="MOZ" if country==508
replace wbcode="MMR" if country==104
replace wbcode="NPL" if country==524
replace wbcode="NLD" if country==528
replace wbcode="NZL" if country==554
replace wbcode="NIC" if country==558
replace wbcode="NER" if country==562
replace wbcode="NGA" if country==566
replace wbcode="NOR" if country==578
replace wbcode="OMN" if country==512
replace wbcode="PAK" if country==586
replace wbcode="WBG" if country==275
replace wbcode="PAN" if country==590
replace wbcode="PNG" if country==598
replace wbcode="PRY" if country==600
replace wbcode="PER" if country==604
replace wbcode="PHL" if country==608
replace wbcode="POL" if country==616
replace wbcode="PRT" if country==620
replace wbcode="PRI" if country==630
replace wbcode="QAT" if country==634
replace wbcode="ROM" if country==642
replace wbcode="RUS" if country==643
replace wbcode="RWA" if country==646
replace wbcode="SAU" if country==682
replace wbcode="SEN" if country==686
replace wbcode="SRB" if country==688
replace wbcode="SGP" if country==702
replace wbcode="SVK" if country==703
replace wbcode="SVN" if country==705
replace wbcode="SOM" if country==706
replace wbcode="ZAF" if country==710
replace wbcode="ESP" if country==724
replace wbcode="LKA" if country==144
replace wbcode="SDN" if country==736
replace wbcode="SUR" if country==740
replace wbcode="SWZ" if country==748
replace wbcode="SWE" if country==752
replace wbcode="CHE" if country==756
replace wbcode="SYR" if country==760 
replace wbcode="TJK" if country==762 
replace wbcode="TZA" if country==834
replace wbcode="THA" if country==764
replace wbcode="TON" if country==776
replace wbcode="TTO" if country==780
replace wbcode="TUN" if country==788
replace wbcode="TUR" if country==792
replace wbcode="UGA" if country==800
replace wbcode="UKR" if country==804
replace wbcode="ARE" if country==784
replace wbcode="GBR" if country==826
replace wbcode="USA" if country==840
replace wbcode="URY" if country==858
replace wbcode="VEN" if country==862
replace wbcode="VNM" if country==704
replace wbcode="YEM" if country==887
replace wbcode="ZMB" if country==894
replace wbcode="ZWE" if country==716

keep wbcode year isic value
order wbcode year isic value
drop if wbcode==""
replace isic="99" if isic=="D"
destring isic, replace
sort wbcode year isic
save "C:\Users\Luis Miguel\Documents\Bases de Datos\UNIDO\va_allyears_allcountries_allsectors_4.dta", replace

clear all
insheet ctable country year isic isiccomb value utable source lastupdated unit using "C:\Users\Luis Miguel\Documents\Bases de Datos\UNIDO\va_allyears_allcountries_allsectors.csv", comma nonames
label variable ctable "Table Code"
label variable country "Country Code"
label variable year "Year"
label variable isic "ISIC Code"
label variable isiccomb "ISIC Combination Code"
label variable value "Value"
label variable utable "Table Definition code"
label variable source "Source Code"
label variable lastupdated "Last updated"
label variable unit "Unit"
destring value, replace ignore(".")
gen wbcode=""
replace wbcode="AFG" if country==4
replace wbcode="ALB" if country==8	
replace wbcode="DZA" if country==12
replace wbcode="AGO" if country==24
replace wbcode="ARG" if country==32
replace wbcode="ARM" if country==51
replace wbcode="ABW" if country==533
replace wbcode="AUS" if country==36
replace wbcode="AUT" if country==40
replace wbcode="AZE" if country==31
replace wbcode="BHS" if country==44
replace wbcode="BGD" if country==50
replace wbcode="BRB" if country==52
replace wbcode="BLR" if country==112
replace wbcode="BEL" if country==56
replace wbcode="BLZ" if country==84
replace wbcode="BEN" if country==204
replace wbcode="BMU" if country==60
replace wbcode="BOL" if country==68
replace wbcode="BIH" if country==70
replace wbcode="BWA" if country==72
replace wbcode="BRA" if country==76
replace wbcode="BGR" if country==100
replace wbcode="BFA" if country==854
replace wbcode="BDI" if country==108
replace wbcode="KHM" if country==116
replace wbcode="CMR" if country==120
replace wbcode="CAN" if country==124
replace wbcode="CAF" if country==140
replace wbcode="CHL" if country==152
replace wbcode="CHN" if country==156
replace wbcode="HKG" if country==344
replace wbcode="MAC" if country==446
replace wbcode="COL" if country==170
replace wbcode="COG" if country==178
replace wbcode="CRI" if country==188
replace wbcode="CIV" if country==384
replace wbcode="HRV" if country==191
replace wbcode="CUB" if country==192
replace wbcode="CUW" if country==531
replace wbcode="CYP" if country==196
replace wbcode="CZE" if country==203
replace wbcode="DNK" if country==208
replace wbcode="DOM" if country==214
replace wbcode="ECU" if country==218
replace wbcode="EGY" if country==818
replace wbcode="SLV" if country==222
replace wbcode="ERI" if country==232
replace wbcode="EST" if country==233
replace wbcode="ETH" if country==231
replace wbcode="FJI" if country==242
replace wbcode="FIN" if country==246
replace wbcode="FRA" if country==250
replace wbcode="GAB" if country==266
replace wbcode="GMB" if country==270
replace wbcode="GEO" if country==268
replace wbcode="DEU" if country==276
replace wbcode="GHA" if country==288
replace wbcode="GRC" if country==300
replace wbcode="GTM" if country==320
replace wbcode="HTI" if country==332
replace wbcode="HND" if country==340
replace wbcode="HUN" if country==348
replace wbcode="ISL" if country==352
replace wbcode="IND" if country==356
replace wbcode="IDN" if country==360
replace wbcode="IRN" if country==364
replace wbcode="IRQ" if country==368
replace wbcode="IRL" if country==372
replace wbcode="ISR" if country==376
replace wbcode="ITA" if country==380
replace wbcode="JAM" if country==388
replace wbcode="JPN" if country==392
replace wbcode="JOR" if country==400
replace wbcode="KAZ" if country==398
replace wbcode="KEN" if country==404
replace wbcode="KOR" if country==410
replace wbcode="KWT" if country==414
replace wbcode="KGZ" if country==417
replace wbcode="LAO" if country==418
replace wbcode="LVA" if country==428
replace wbcode="LBN" if country==422
replace wbcode="LSO" if country==426
replace wbcode="LBR" if country==430
replace wbcode="LBY" if country==434
replace wbcode="LIE" if country==438
replace wbcode="LTU" if country==440
replace wbcode="LUX" if country==442
replace wbcode="MKD" if country==807
replace wbcode="MDG" if country==450
replace wbcode="MWI" if country==454
replace wbcode="MYS" if country==458
replace wbcode="MLT" if country==470
replace wbcode="MUS" if country==480
replace wbcode="MEX" if country==484
replace wbcode="MDA" if country==498
replace wbcode="MNG" if country==496
replace wbcode="MAR" if country==504
replace wbcode="MOZ" if country==508
replace wbcode="MMR" if country==104
replace wbcode="NPL" if country==524
replace wbcode="NLD" if country==528
replace wbcode="NZL" if country==554
replace wbcode="NIC" if country==558
replace wbcode="NER" if country==562
replace wbcode="NGA" if country==566
replace wbcode="NOR" if country==578
replace wbcode="OMN" if country==512
replace wbcode="PAK" if country==586
replace wbcode="WBG" if country==275
replace wbcode="PAN" if country==590
replace wbcode="PNG" if country==598
replace wbcode="PRY" if country==600
replace wbcode="PER" if country==604
replace wbcode="PHL" if country==608
replace wbcode="POL" if country==616
replace wbcode="PRT" if country==620
replace wbcode="PRI" if country==630
replace wbcode="QAT" if country==634
replace wbcode="ROM" if country==642
replace wbcode="RUS" if country==643
replace wbcode="RWA" if country==646
replace wbcode="SAU" if country==682
replace wbcode="SEN" if country==686
replace wbcode="SRB" if country==688
replace wbcode="SGP" if country==702
replace wbcode="SVK" if country==703
replace wbcode="SVN" if country==705
replace wbcode="SOM" if country==706
replace wbcode="ZAF" if country==710
replace wbcode="ESP" if country==724
replace wbcode="LKA" if country==144
replace wbcode="SDN" if country==736
replace wbcode="SUR" if country==740
replace wbcode="SWZ" if country==748
replace wbcode="SWE" if country==752
replace wbcode="CHE" if country==756
replace wbcode="SYR" if country==760 
replace wbcode="TJK" if country==762 
replace wbcode="TZA" if country==834
replace wbcode="THA" if country==764
replace wbcode="TON" if country==776
replace wbcode="TTO" if country==780
replace wbcode="TUN" if country==788
replace wbcode="TUR" if country==792
replace wbcode="UGA" if country==800
replace wbcode="UKR" if country==804
replace wbcode="ARE" if country==784
replace wbcode="GBR" if country==826
replace wbcode="USA" if country==840
replace wbcode="URY" if country==858
replace wbcode="VEN" if country==862
replace wbcode="VNM" if country==704
replace wbcode="YEM" if country==887
replace wbcode="ZMB" if country==894
replace wbcode="ZWE" if country==716

keep wbcode year isic value
order wbcode year isic value
drop if wbcode==""
replace isic="99" if isic=="D"
destring isic, replace
sort wbcode year isic value
save "C:\Users\Luis Miguel\Documents\Bases de Datos\UNIDO\va_allyears_allcountries_allsectors_2.dta", replace

merge m:m wbcode year isic value using "C:\Users\Luis Miguel\Documents\Bases de Datos\UNIDO\va_allyears_allcountries_allsectors_4.dta"
drop _merge
save "C:\Users\Luis Miguel\Documents\Bases de Datos\UNIDO\va_allyears_allcountries_allsectors_2&4.dta", replace
