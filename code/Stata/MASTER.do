
clear
set more off

if c(username) == "rtenorio" {
	cd "."

	}
	
else { 
	local username "`c(username)'"
	cd "/Users/`username'/."

	}

********************************************************************************
*                            APPENDING HH SUMMARY DATA                         * 
********************************************************************************

*Cleaning and translating 2004 summary data*

forvalue j = 2004/2012 {
	use "sumaria-`j'.dta", clear
	tempfile sum_`j'

	destring ubigeo, replace

	keep aÑo mes conglome vivienda hogar ubigeo percepho mieperho gru11hd gru12hd1 ///
	gru12hd2 gru13hd1 gru13hd2 gru13hd3 sg23 gru21hd gru31hd gru41hd gru51hd gru61hd gru71hd gru81hd inghog2d inghog1d ingmo1hd ingmo2hd ///
	gashog1d gashog2d linpe linea pobreza factor07      

	rename aÑo year
	label variable year "Year of survey"
	rename mes month
	label variable month "Month of survey distribution"
	rename conglome cong
	label variable cong "Stratefied sampling unit 1 at conglomerado level"
	rename vivienda hunit
	label variable hunit "Stratefied sampling unit 2 at house/building level"
	rename hogar hhold
	label variable hhold "Household unit of measurement, level 3"
	rename ubigeo geog
	label variable geog "Geographic location"
	rename percepho hhearn
	label variable hhearn "Total income earners" 
	rename mieperho tothhmem
	label variable tothhmem "Total nummber of members in household" 
	label variable gru11hd "Total Food expenditures"
	label variable gru12hd1 "Total food self_consumed and self-supplied"
	label variable gru12hd2 "Total food paid for in-kind"
	label variable gru13hd1 "Total food from public donation"
	label variable gru13hd2 "Total food private donation"
	label variable gru13hd3 "Total food from other expenses"
	label variable sg23 "Food consumed inside the home"
	label variable gru21hd "Clothing and footwear expenditure"
	label variable gru31hd "Housing rent and gas expenditure"
	label variable gru41hd "Furniture and housing maintenance expenditures" 
	label variable gru51hd "Healthcare expenditures" 
	label variable gru61hd "Transportation and communications expenditures" 
	label variable gru71hd "Recreation expenditures" 
	label variable gru81hd "Other goods and services expenditures" 
	rename inghog2d inchhnet
	label variable inchhnet "Total net household income"
	rename inghog1d inchhgross
	label variable inchhgross "Total gross household income"
	rename ingmo1hd  moinchhgross
	label variable moinchhgross "Annualized Gross Monetary Household Income"
	rename ingmo2hd moinchhnet
	label variable moinchhnet "Annualized Net Monetary Household Income"  
	rename gashog1d  moexphh
	label variable moexphh "Annualized Monetary Expenditure counting Investment and not counting In-Kind Donations"
	rename gashog2d exphhgross
	label variable exphhgross "Total annualized household gross expenditure"
	rename linpe  povlinfd
	label variable povlinfd "Food poverty line"
	rename linea povline
	label variable povline "Poverty line"
	rename pobreza poverty
	label variable poverty "1 = extreme poverty, 2 = poor, 3 = not poor" 

	*creating department specific codes for ag production"
	gen dep = int(geog/10000)
	label variable dep "Department of Peru" 

	describe 

	save `sum_`j'' 

}

***Append to make one master data set***

append using `sum_2004' `sum_2005' `sum_2006' `sum_2007' `sum_2008' `sum_2009' ///
`sum_2010' `sum_2011'

tempfile sum_master

destring, replace

xi i.dep

gen _Idep_1 = 0
replace _Idep_1 = 1 if dep == 1

drop dep

label var _Idep_1 "Amazonas"
label var _Idep_2 "Ancash"
label var _Idep_3 "Apurimac"
label var _Idep_4 "Arequipa"
label var _Idep_5 "Ayacucho"
label var _Idep_6 "Cajamarca"
label var _Idep_7 "Callao"
label var _Idep_8 "Cusco"
label var _Idep_9 "Huancavelica"
label var _Idep_10 "Huanuco"
label var _Idep_11 "Ica"
label var _Idep_12 "Junin"
label var _Idep_13 "La Libertad"
label var _Idep_14 "Lambayeque"
label var _Idep_15 "Lima"
label var _Idep_16 "Loreto"
label var _Idep_17 "Madre de Dios"
label var _Idep_18 "Moquegua"
label var _Idep_19 "Pasco"
label var _Idep_20 "Piura"
label var _Idep_21 "Puno"
label var _Idep_22 "San Martin"
label var _Idep_23 "Tacna"
label var _Idep_24 "Tumbes"
label var _Idep_25 "Ucayali"

save `sum_master'

********************************************************************************
*                             APPENDING RURAL DATA                             * 
********************************************************************************

forvalue j = 2004/2012 {
	use enaho01-`j'-100.dta, clear

	tempfile rural`j'
	keep ano mes conglome vivienda ubigeo estrato hogar factor07
	destring, replace
	
	save `rural`j''
	}

forvalue j = 2004/2011 {
	append using `rural`j''
	}

rename ano year
label variable year "Year of survey"
rename mes month
label variable month "Month of survey distribution"
rename conglome cong
label variable cong "Stratefied sampling unit 1 at conglomerado level"
rename vivienda hunit
label variable hunit "Stratefied sampling unit 2 at house/building level"
rename hogar hhold
label variable hhold "Household unit of measurement, level 3"
rename ubigeo geog
label variable geog "Geographic location"
rename estrato stratum
label variable stratum "Urban/Rural Stratum"

gen rural = 0 
replace rural = 1 if stratum == 7 | stratum == 8
label variable rural "rural == 1, urban == 0"

label define rural 1 "rural" 0 "urban"
label values rural rural

merge 1:1 year month cong hunit hhold using `sum_master', nogenerate

tempfile master
save `master'
********************************************************************************
*                             APPENDING AG DATA                                * 
********************************************************************************

forvalue j = 2004/2006 {
	use "enaho02-`j'-210a", clear
	tempfile ag_`j'

	keep a* mes conglome vivienda hogar ubigeo p20001a

	rename a* year
	label variable year "Year of survey"
	rename mes month
	label variable month "Month of survey distribution"
	rename conglome cong
	label variable cong "Stratefied sampling unit 1 at conglomerado level"
	rename vivienda hunit
	label variable hunit "Stratefied sampling unit 2 at house/building level"
	rename hogar hhold
	label variable hhold "Household unit of measurement, level 3"
	rename ubigeo geog
	label variable geog "Geographic location"
	rename p20001a agdummy
	label variable agdummy "1 = agriculture producer 0 = not" 

	save `ag_`j''

	}

forvalue j = 2007/2012 {
	use "enaho02-`j'-2000", clear
	tempfile ag_`j'

	keep a* mes conglome vivienda hogar ubigeo p20001a

	rename a* year
	label variable year "Year of survey"
	rename mes month
	label variable month "Month of survey distribution"
	rename conglome cong
	label variable cong "Stratefied sampling unit 1 at conglomerado level"
	rename vivienda hunit
	label variable hunit "Stratefied sampling unit 2 at house/building level"
	rename hogar hhold
	label variable hhold "Household unit of measurement, level 3"
	rename ubigeo geog
	label variable geog "Geographic location"
	rename p20001a agdummy
	label variable agdummy "1 = agriculture producer 0 = not" 

	save `ag_`j''

	}


**Append to make one master data set***

append using `ag_2004' `ag_2005' `ag_2006' `ag_2007' `ag_2008' `ag_2009' `ag_2010' ///
`ag_2011' `ag_2012'

tempfile ag_master

destring, replace

drop if agdummy != 1

gen dep = int(geog/10000)

xi i.dep

gen _Idep_1 = 0
replace _Idep_1 = 1 if dep == 1

drop dep

label var _Idep_1 "Amazonas"
label var _Idep_2 "Ancash"
label var _Idep_3 "Apurimac"
label var _Idep_4 "Arequipa"
label var _Idep_5 "Ayacucho"
label var _Idep_6 "Cajamarca"
label var _Idep_7 "Callao"
label var _Idep_8 "Cusco"
label var _Idep_9 "Huancavelica"
label var _Idep_10 "Huanuco"
label var _Idep_11 "Ica"
label var _Idep_12 "Junin"
label var _Idep_13 "La Libertad"
label var _Idep_14 "Lambayeque"
label var _Idep_15 "Lima"
label var _Idep_16 "Loreto"
label var _Idep_17 "Madre de Dios"
label var _Idep_18 "Moquegua"
label var _Idep_19 "Pasco"
label var _Idep_20 "Piura"
label var _Idep_21 "Puno"
label var _Idep_22 "San Martin"
label var _Idep_23 "Tacna"
label var _Idep_24 "Tumbes"
label var _Idep_25 "Ucayali"

collapse (max) agdummy, by(year month cong hunit hhold)

save `ag_master'

********************************************************************************
*            IMPORT AND MERGE QUINOA PRODUCTION and EXPORT DATA                *
********************************************************************************

import excel using "Quinoa Production.xlsx", sheet("Sheet1") firstrow clear

tempfile production_temp

destring, replace
rename depa dep
drop if dep == "Lima Metropolitana"
drop if dep == "peru"
label variable ton "total metric tons produced"
label variable area "total hectares cultivated"
label variable prod "kilograms per hectare"
label variable price "soles per kilogram"
label variable dep "department or nationwide" 

xi i.dep

gen _Idep_1 = 0
replace _Idep_1 = 1 if dep == "Amazonas"

label var _Idep_1 "Amazonas"
label var _Idep_2 "Ancash"
label var _Idep_3 "Apurimac"
label var _Idep_4 "Arequipa"
label var _Idep_5 "Ayacucho"
label var _Idep_6 "Cajamarca"
label var _Idep_7 "Callao"
label var _Idep_8 "Cusco"
label var _Idep_9 "Huancavelica"
label var _Idep_10 "Huanuco"
label var _Idep_11 "Ica"
label var _Idep_12 "Junin"
label var _Idep_13 "La Libertad"
label var _Idep_14 "Lambayeque"
label var _Idep_15 "Lima"
label var _Idep_16 "Loreto"
label var _Idep_17 "Madre de Dios"
label var _Idep_18 "Moquegua"
label var _Idep_19 "Pasco"
label var _Idep_20 "Piura"
label var _Idep_21 "Puno"
label var _Idep_22 "San Martin"
label var _Idep_23 "Tacna"
label var _Idep_24 "Tumbes"
label var _Idep_25 "Ucayali"

*generate mean variables for production of quinoa by department
tab dep, summarize(prod)
sort dep
by dep, sort: egen mean_prod = mean(prod)
gen quinoa_dep = 1
replace quinoa_dep = 0 if mean_prod == 0


save `production_temp'
********************************************************************************
*            MERGE QUINOA DATA WITH PRODUCTION DATA                            *
********************************************************************************

merge 1:m year _Idep* using `master'
tempfile master_prod_temp

drop if year == 2013
drop _merge

save `master_prod_temp'
********************************************************************************
*            MERGE QUINOA DATA WITH AG DUMMY DATA                            *
********************************************************************************
use `ag_master'

merge 1:1 year month cong hunit hhold using `master_prod_temp'
tempfile master

replace agdummy = 0 if agdummy == . // these are the non-farmers

drop if year == 2013 // we aren't looking at 2013

drop if _merge == 1 // this is dropping two unmerged observations

drop _merge 

merge m:1 year using "peru_exports.dta", nogenerate

********************************************************************************
*            MERGE QUINOA DATA WITH EXPORTS DATA                               *
********************************************************************************

merge m:1 year using "peru_exports.dta"

drop if year == 2013
drop _merge

save `master'

********************************************************************************
*			 MERGE QUINOA CONSUMPTION DATA 									   *
********************************************************************************
set more off
* clean 2004-20012 Quinua consumption data
forvalue j = 2004/2012 {

	tempfile quin_cons`j'

	use "enaho01-`j'-601.dta", clear

	rename a* year
	label variable year "Year of survey"
	rename mes month
	label variable month "Month of survey distribution"
	rename conglome cong
	label variable cong "Stratefied sampling unit 1 at conglomerado level"
	rename vivienda hunit
	label variable hunit "Stratefied sampling unit 2 at house/building level"
	rename hogar hhold
	label variable hhold "Household unit of measurement, level 3"
	rename ubigeo geog
	label variable geog "Geographic location"
	label variable p601a "Product Code"
	label variable p601b "Consumed product in last 15 days?"
	label variable p601a1 "Was the product purchased?"
	label variable p601a2 "Was the product own-consumption"
	label variable p601a3 "Was the product own-supply"
	label variable p601a4 "Was the product payment in-kind to household member?"
	label variable p601a5 "Was the product a gift from another household?"
	label variable p601a6 "Was the product donated by a social program?"
	label variable p601a7 "Was the product acquired by other means?"
	label variable p601b1 "With what frequency did you buy the product?"
	label variable p601b2 "What was the quantity of the product purchased?"
	label variable p601b3 "What was the unit of measurement of the product purchased?"
	label variable p601c "What was the total amount of the purchase?"
	label variable p601d1 "With what frequency did you consume the product?"
	label variable p601d2 "What was the quantity of the product consumed?"
	label variable p601d3 "What was the unit of measurement of the product consumed?"
	rename i601d2 quin_an_quant
	label variable quin_an_quant "Total Annualized quantity of quinoa was consumed?"
	rename d601c quin_an_exp
	label variable quin_an_exp "Total Annualized, deflated expenditure on Quinoa"

	* keep only the identifier variables and consumption variables
	keep year month cong hunit hhold geog p601a p601b p601a1 p601a2 p601a3 p601a4 ///
	p601a5 p601a6 p601a7 p601b1 p601b2 p601b3 p601c p601d1 p601d2 p601d3 quin_an_quant quin_an_exp

	destring, replace
	
	save `quin_cons`j''
	
	}
	
append using `quin_cons2004' `quin_cons2005' `quin_cons2006' `quin_cons2007' `quin_cons2008' ///
`quin_cons2009' `quin_cons2010' `quin_cons2011'

* keep only the quinoa lines for each HH
keep if p601a == 1700 | p601a == 1701 | p601a == 1702

* generate a dummy variable for quinoa consumption in last 15 days
gen quin_cons = 0
replace quin_cons = 1 if p601b == 1

label variable quin_cons "Equals 1 if HH consumed quinoa in last 15 days"

* generate a variable that == 1 if the household bought their quinoa, and 0 otherwise
generate quin_bought = 0
replace quin_bought = 1 if p601a1 == 1  & quin_cons == 1
label variable quin_bought "Equals 1 if HH bought quinoa in last 15 days"

* generate a variable that == 1 if the household "self-consumed" quinoa, and 0 otherwise
generate quin_self_cons = 0
replace quin_self_cons = 1 if p601a2 == 1 & quin_cons == 1
label variable quin_self_cons "Equals 1 if HH 'self-consumed' quinoa in last 15 days"

* generate a variable that == 1 if the household produced their own quinoa, and 0 otherwise
generate quin_self_supp = 0
replace quin_self_supp = 1 if p601a3 == 1 & quin_cons == 1
label variable quin_self_supp "Equals 1 if HH consumed own supply of quinoa in last 15 days"

* create an individual for the total expenditure of each type of quinoa product
forvalue j = 1700/1702 {
	generate quin_exp_`j' = quin_an_exp if p601a == `j'
	}

forvalue j = 1700/1702 {
	generate quin_quant_`j' = quin_an_quant if p601a == `j'
	
	}

collapse (max) geog quin_cons quin_bought quin_self_cons quin_self_supp /// 
p601a p601b p601a1 p601a2 p601a3 p601a4 p601a5 p601a6 p601a7 p601b1 p601b2 ///
p601b3 p601c quin_an_quant quin_an_exp p601d1 p601d2 p601d3 quin_quant_17* quin_exp_17*, by (year month cong hunit hhold)

* total quinoa quantity
generate quin_tot_an_quant = quin_quant_1700+quin_quant_1701+quin_quant_1702

generate quin_quant_flag = 1 if quin_quant_1700 == quin_quant_1701 & quin_quant_1700 != 0 ///
| quin_quant_1700 == quin_quant_1702 & quin_quant_1700 != 0 | ///
quin_quant_1701 == quin_quant_1702 & quin_quant_1701 != 0

replace quin_tot_an_quant = 0 if quin_quant_flag == 1

egen quin_tot_an_quant_temp = rowmax(quin_quant_1700 quin_quant_1701 quin_quant_1702) if quin_quant_flag == 1

replace quin_tot_an_quant = quin_tot_an_quant_temp if quin_quant_flag == 1

drop quin_quant_flag quin_tot_an_quant_temp quin_quant_17*

* total quinoa expenditure
forvalue j = 1700/1702 {
	replace quin_exp_`j' = 0 if quin_exp_`j' == .
	}
	
generate quin_tot_an_exp = quin_exp_1700+quin_exp_1701+quin_exp_1702

generate quin_exp_flag = 1 if quin_exp_1700 == quin_exp_1701 & quin_exp_1700 != 0 ///
| quin_exp_1700 == quin_exp_1702 & quin_exp_1700 != 0 | quin_exp_1701 == quin_exp_1702 & quin_exp_1701 != 0

replace quin_tot_an_exp = 0 if quin_exp_flag == 1

egen quin_tot_an_exp_temp = rowmax(quin_exp_1700 quin_exp_1701 quin_exp_1702) if quin_exp_flag == 1

replace quin_tot_an_exp = quin_tot_an_exp_temp if quin_exp_flag == 1

drop quin_exp_flag quin_tot_an_exp_temp quin_exp_17*

label variable quin_cons "Equals 1 if HH consumed quinoa in last 15 days"
label variable quin_bought "Equals 1 if HH bought quinoa in last 15 days"
label variable quin_self_cons "Equals 1 if HH 'self-consumed' quinoa in last 15 days"
label variable quin_self_supp "Equals 1 if HH consumed own supply of quinoa in last 15 days"
label variable quin_tot_an_exp "Total annualized, deflated household expenditure on Quinoa products"

merge 1:1 year month cong hunit hhold using `master', nogenerate

* merge exchange rate data

merge m:1 year using "PEN_USD_exrate.dta", nogen

*****************************************
* take the natural log of income and exp*
*****************************************
gen ln_exphhgross = ln(exphhgross)
gen ln_inchhgross = ln(inchhgross)
gen ln_moinchhnet = ln(moinchhnet)
gen ln_moexphh = ln(moexphh)

label variable ln_exp "nat log of gross annual HH expenditure"
label variable ln_inc "nat log of gross annual HH income"

****************************************
* convert income and expenditure to USD*
****************************************

gen exp_USD = exphhgross/ex_rate
gen ln_exp_USD = ln(exp_USD)
gen inc_USD = inchhgross/ex_rate
gen ln_inc_USD = ln(inc_USD)
gen inc_net_USD = inchhnet/ex_rate
gen ln_inc_net_USD = ln(inc_net_USD)
gen moexp_USD = moexphh/ex_rate
gen ln_moexp_USD = ln(moexp_USD)
gen moinc_USD = moinchhgross/ex_rate
gen ln_moinc_USD = ln(moinc_USD)
gen quin_tot_an_exp_USD = quin_tot_an_exp/ex_rate
gen ln_quin_tot_an_exp_USD = ln(quin_tot_an_exp_USD)

label variable exp_USD "gross annual HH expenditure in USD"
label variable inc_USD "gross annual HH income in USD"

label variable ln_exp_USD "nat log of gross annual HH expenditure in USD"
label variable ln_inc_USD "nat log of gross annual HH income in USD"

*************************************
* Include Price Variable from SIICEX*
*************************************
drop price

append using "peru_trade_price.dta"
rename price price_kg

sort year

by year: egen price = max(price_kg)

drop price_kg
label variable price "FOB price per kilo in USD"

* drop the old price_soles variable because I don't know where that came from
drop price_soles

* create a new price_soles variable
gen price_soles = price*ex_rate
label variable price_soles "FOB price per kilo in soles"

gen price_soles_def = price_soles/food_price_index
label variable price_soles_def "Deflated FOB price per kilo in soles"

gen ln_price = ln(price)
gen ln_price_soles_def = ln(price_soles_def)

label variable ln_price "nat. log of FOB price/kilo"
*************************************
* Add Peru Production Numbers       *
*************************************

replace ton = 26997 if dep == "Peru" & year == 2004
replace ton = 32590 if dep == "Peru" & year == 2005
replace ton = 30428 if dep == "Peru" & year == 2006
replace ton = 31824 if dep == "Peru" & year == 2007
replace ton = 29867 if dep == "Peru" & year == 2008
replace ton = 39397 if dep == "Peru" & year == 2009
replace ton = 41079 if dep == "Peru" & year == 2010
replace ton = 41182 if dep == "Peru" & year == 2011
replace ton = 44213 if dep == "Peru" & year == 2012

***************************************************************
* Creat a variable for Peru exports as a % of production      *
***************************************************************
sort year
gen peru_kg = ton if dep == "Peru"

rename peru_kg peru_kg_temp

by year: egen peru_kg = max(peru_kg_temp)

label variable peru_kg "peruvian production in 000s kilograms"

drop peru_kg_temp

gen exports_kg_1000 = exports_kg/1000

replace exports_kg = exports_kg_1000

label variable exports_kg "total peruvian exports of quinoa in 1000s kg"

gen exp_per_tot = exports_kg/peru_kg if dep != "Peru"

label variable exp_per_tot "peruvian exports as a percent of total production"

gen ln_exports_kg = ln(exports_kg)

label variable ln_exports_kg "log of exports of quinoa in 1000s kg"

*************************************
* Add Peru Productivity Numbers     *
*************************************

replace prod = 975 if dep == "Peru" & year == 2004
replace prod = 1138 if dep == "Peru" & year == 2005
replace prod = 1016 if dep == "Peru" & year == 2006
replace prod = 1047 if dep == "Peru" & year == 2007
replace prod = 958 if dep == "Peru" & year == 2008
replace prod = 1158 if dep == "Peru" & year == 2009
replace prod = 1163 if dep == "Peru" & year == 2010
replace prod = 1161 if dep == "Peru" & year == 2011
replace prod = 1148 if dep == "Peru" & year == 2012

*************************************
* Add Peru Area Cultivated Numbers  *
*************************************

replace area = 27676 if dep == "Peru" & year == 2004
replace area = 28632 if dep == "Peru" & year == 2005
replace area = 29949 if dep == "Peru" & year == 2006
replace area = 30381 if dep == "Peru" & year == 2007
replace area = 31163 if dep == "Peru" & year == 2008
replace area = 34026 if dep == "Peru" & year == 2009
replace area = 35313 if dep == "Peru" & year == 2010
replace area = 35475 if dep == "Peru" & year == 2011
replace area = 38498 if dep == "Peru" & year == 2012


*****************************************
* Add Peru Total Metric Tons Produced   *
*****************************************

replace ton = 26997 if dep == "Peru" & year == 2004
replace ton = 32590 if dep == "Peru" & year == 2005
replace ton = 30428 if dep == "Peru" & year == 2006
replace ton = 31824 if dep == "Peru" & year == 2007
replace ton = 29867 if dep == "Peru" & year == 2008
replace ton = 39397 if dep == "Peru" & year == 2009
replace ton = 41079 if dep == "Peru" & year == 2010
replace ton = 41182 if dep == "Peru" & year == 2011
replace ton = 44213 if dep == "Peru" & year == 2012

*****************************************
* Add Peru Domestic Price in Soles Data *
*****************************************

gen price_dom = 1.11 if dep == "Peru" & year == 2004
replace price_dom = 1.16 if dep == "Peru" & year == 2005
replace price_dom = 1.18 if dep == "Peru" & year == 2006
replace price_dom = 1.22 if dep == "Peru" & year == 2007
replace price_dom = 1.60 if dep == "Peru" & year == 2008
replace price_dom = 3.36 if dep == "Peru" & year == 2009
replace price_dom = 3.38 if dep == "Peru" & year == 2010
replace price_dom = 3.68 if dep == "Peru" & year == 2011
replace price_dom = 3.88 if dep == "Peru" & year == 2012

* convert price domestic to USD
replace price_dom = price_dom/ex_rate

label variable price_dom "Domestic Price per Kilo in USD"
********************************
* Add Peru % Change in GDP     *
********************************

merge m:1 year using "peru_gdp.dta", nogen 

******************************************************
* Add Change in Global Food Price Index for Cereals  *
******************************************************

generate cereal_change = .
replace cereal_change = 0.079637097 if year == 2004
replace cereal_change = -0.054154995 if year == 2005
replace cereal_change = 0.173741362 if year == 2006
replace cereal_change = 0.374264087 if year == 2007
replace cereal_change = 0.420440636 if year == 2008
replace cereal_change = -0.26669539 if year == 2009
replace cereal_change = 0.052878966 if year == 2010
replace cereal_change = 0.344308036 if year == 2011
replace cereal_change = -0.01992528 if year == 2012

*********************************************************
* Add Change in International Price of Quinoa per Kilo  *
*********************************************************

generate price_change = .
replace price_change = 0.115702479 if year == 2004
replace price_change = -0.081481481 if year == 2005
replace price_change = -0.016129032 if year == 2006
replace price_change = 0.057377049 if year == 2007
replace price_change = 0.875968992 if year == 2008
replace price_change = 0.099173554 if year == 2009
replace price_change = 0.022556391 if year == 2010
replace price_change = 0.147058824 if year == 2011
replace price_change = -0.076923077 if year == 2012

******************************************
* Add Global Imports of Peruvian Quinoa  *
******************************************

merge m:1 year using world_imports.dta, nogen

generate ln_world_imports = ln(world_imports)
label variable ln_world_imports "log of world imports of Peruvian quinoa"

***************************************************
* Generate Quinoa as a share of total expenditure *
***************************************************

gen quin_per_texp = quin_tot_an_exp/gru11hd
label variable quin_per_texp "Percent of total food expenditure on Quinoa"

gen quin_per_mexp = (quin_tot_an_exp)/moexphh
label variable quin_per_mexp "Percent of total annual expenditure on Quinoa"

gen quin_per_mincn = (quin_tot_an_exp)/moinchhnet
label variable quin_per_mincn "Percent of total annual net income on Quinoa"

gen quin_per_mincg = (quin_tot_an_exp)/moinchhgross
label variable quin_per_mincg "Percent of total annual gross income on Quinoa"

gen quin_unit_price_hh = quin_tot_an_exp/quin_tot_an_quant
label variable quin_unit_price_hh "household price of quinoa per kilo"

gen ln_quin_unit_price_hh = ln(quin_unit_price_hh)
label variable ln_quin_unit_price_hh "ln of household price of quinoa per kilo"

* generate ln_moexphh squared - total expenditure squared
gen ln_moexphh_sq = ln_moexphh^2

* generate ln_moinchh squared - total income squared
rename ln_moinchhnet ln_moinchh
gen ln_moinchh_sq = ln_moinchh^2

* generate ln_gru11hd - total food expenditure
gen ln_gru11hd = ln(gru11hd)

* generate ln_gru11hd_sq
gen ln_gru11hd_sq = ln_gru11hd^2

* generate food expenditure/total expenditure
gen food_per_tot_exp = gru11hd/moexphh

* generate a poor dummies
gen extreme_poor = 0
replace extreme_poor = 1 if poverty == 1

gen poor = 0
replace poor = 1 if poverty == 2

gen not_poor = 0
replace not_poor = 1 if poverty == 3

gen all_poor = 0
replace all_poor = 1 if poverty != 3

/* Append all food basket data files - in consumption basket by year

merge 1:1 year month cong hunit hhold using "food_basket_2004_2012.dta" 

* drop HHs from consumption data that do not merge to master data
drop if _merge == 2 */

********************
* Merge Price Data *
********************


*********************************************************
* Drop Food Expenditure Proportion and Unecessary Foods *
*********************************************************

drop *_per_totan_fexp
drop biscuit* bread* cake* other_cereal* alcohol* soft_drink* pasta* cow* ///
chicken* pig* fish* shellfish* animal* cheese* yogurt* cream* algae* blackberry* ///
guabana* tamarind* apricot* 

* drop the food variables with fewer than 1000 non 0 observations
drop eggplant* esparragos* lucuma* coconut* cherry* ///
guava* pecan* almond*

* rename some variables
*rename barley_rye_wheat_per_totan_texp barley_wheat_per_totan_texp
rename barley_rye_wheat_tot_an_exp barley_wheat_tot_an_exp
*rename grape_raisin_per_totan_texp grape_per_totan_texp
rename grape_raisin_tot_an_exp grape_tot_an_exp
rename quinua_producer quinoa_producer

rename quin_tot_an_exp quinoa_tot_an_exp

order quinoa_price, after(sweet_potato_price)

* replace .s in proportion variables with zeros 

local foods `" "rice" "oats" "barley_wheat" "corn_maize" "eggs" "chard" "artichoke" "celery" "peas" "beetroot" "broccoli" "caigua" "onion" "chileno_verde" "cabbage" "cauliflower" "spinach" "legume" "lettuce" "turnip" "cucumber" "alfalfa" "leek" "radish" "tomato" "carrot" "squash" "yuca" "olluco" "potato" "pineapple" "banana" "apple" "mango" "citrus_fruit" "avocado" "grape" "pear" "strawberry" "passion_fruit" "granadilla" "chirimoya" "papaya" "watermelon" "peanut" "lentil" "sweet_potato" "quinoa" "'
set more off

egen totan_fexp = rowtotal(rice_tot_an_exp-quinoa_tot_an_exp)
label variable totan_fexp "Total annual food expenditure"

gen quinoa_per_totan_texp = quinoa_tot_an_exp/moexphh
gen quinoa_per_totan_texp_def = quinoa_tot_an_exp_def/moexphh_def

gen totan_fexp_per_texp_def = totan_fexp_def/moexphh_def
label variable totan_fexp_per_texp_def "total deflated food basket expenditure by total expenditure"

foreach k of local foods {

	replace `k'_per_totan_texp = 0 if `k'_per_totan_texp == .
	
	gen `k'_per_totan_fexp_def = `k'_tot_an_exp_def/totan_fexp_def
	label variable `k'_per_totan_fexp "`k' expenditure as a proportion of total food expenditure"
	
	}
	
local foods `" "rice" "oats" "barley_wheat" "corn_maize" "eggs" "chard" "artichoke" "celery" "peas" "beetroot" "broccoli" "caigua" "onion" "chileno_verde" "cabbage" "cauliflower" "spinach" "legume" "lettuce" "turnip" "cucumber" "alfalfa" "leek" "radish" "tomato" "carrot" "squash" "yuca" "olluco" "potato" "pineapple" "banana" "apple" "mango" "citrus_fruit" "avocado" "grape" "pear" "strawberry" "passion_fruit" "granadilla" "chirimoya" "papaya" "watermelon" "peanut" "lentil" "sweet_potato" "quinoa" "'
set more off

foreach k of local foods {

	replace `k'_per_totan_texp = 0 if `k'_per_totan_texp == .
	
	gen `k'_per_totan_fexp_def = `k'_tot_an_exp_def/totan_fexp_def
	label variable `k'_per_totan_fexp "deflated `k' expenditure as a proportion of def total food expenditure"
	
	}


	
***************************************
* Calculate Quinoa Per HH Consumption *
***************************************

* drop 160 observations that are in producer data but not in any other data
drop if tothhmem == .

* drop outliers (i.e. if quinoa consumption is above 500 kilos per annum)
replace quin_tot_an_quant = 0 if quin_tot_an_quant == .
drop if quin_tot_an_quant >= 500

gen pc_quinoa = quin_tot_an_quant/tothhmem

egen pc_quinoa_avg_year = mean(pc_quinoa), by(year)
label variable pc_quinoa_avg_year "Avg annual pc consumption of quinoa in kilos"


gen earner_per_mem = hhearn/tothhmem
label variable earner_per_mem "Proportion of HH earners to HH members"

* deflate total household expenditure by food basket
gen moexphh_def = moexphh/food_price_index
label variable moexphh_def "Total annual deflated HH expenditure"

gen ln_moexphh_def = ln(moexphh_def)
label variable moexphh_def "ln of total annual deflated HH expenditure"

gen ln_totan_fexp_def = ln(totan_fexp_def)
label variable ln_totan_fexp_def "log of total annual food basket expenditure deflated"

* Identify producers
gen producer = 0
foreach var of varlist *_producer {
	replace producer = 1 if `var' == 1
	}
	
gen ln_quinoa_tot_an_exp_def = ln(quinoa_tot_an_exp_def)
label variable ln_quinoa_tot_an_exp_def "log of total HH quinoa expenditure"

* create quantiles for expenditure
xtile quart [w=factor07] = moexphh_def, nq(4)

* create quantiles for food basket expenditure
xtile quart_fbasket [w=factor07] = totan_fexp_def, nq(4)

save "master.dta", replace

/********************************************************************************
*				CREATE SUMMARY STATISTICS by QUINOA REGION or NON-QUINOA REGION*
********************************************************************************

generate poor = 1 if poverty == 1 | poverty == 2
replace poor = 0 if poverty == 3

label variable poor "poor or extremely poor"

**summary statistics

estpost ttest agdummy hhearn tothhmem inchhgross exphhgross poor, by(quinoa_dep)

esttab using sumstatsREGION.rtf, cell((mu_1(label(Non-Quinoa)) mu_2(label(Quinoa)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" inchhhgross "annual income" ///
exphhgross"annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1: Means and Differences for Quinoa Producing and Non-Quinoa Producing Departments") replace

********************************************************************************
*				CREATE SUMMARY STATISTICS by POST                              *
********************************************************************************
generate post = 1 if year >= 2007
replace post = 0 if post != 1

estpost ttest agdummy hhearn tothhmem inchhgross exphhgross poor, by(post)

esttab using sumstatsPOST.rtf, cell((mu_1(label(Pre-Spike)) mu_2(label(Post-Spike)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" inchhhgross "annual income" ///
exphhgross"annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 2: Means and Differences Before and After Price Spike") replace

********************************************************************************
*				CREATE SUMMARY STATISTICS by FARMER                            *
********************************************************************************
estpost ttest hhearn tothhmem inchhgross exphhgross poor, by(agdummy)

esttab using sumstatsFARM.rtf, cell((mu_1(label(Non-Farmer)) mu_2(label(Farmer)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(hhearn "no. earners" ///
tothhmem "no. members" inchhhgross "annual income" ///
exphhgross"annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 3: Means and Differences Between Non-Farmers and Farmers") replace

********************************************************************************
*				CREATE SUMMARY STATISTICS FOR EACH YEAR by Region			   *
********************************************************************************

* 2004
estpost ttest agdummy hhearn tothhmem inchhgross exphhgross poor if year == 2004, by(quinoa_dep)

esttab using sumstats04.rtf, cell((mu_1(label(Non-Quinoa)) mu_2(label(Quinoa)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1a: Means and Differences for Quinoa Producing and Non-Quinoa Producing Departments in 2004") replace

* 2005
estpost ttest agdummy hhearn tothhmem inchhgross exphhgross poor if year == 2005, by(quinoa_dep)

esttab using sumstats05.rtf, cell((mu_1(label(Non-Quinoa)) mu_2(label(Quinoa)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1b: Means and Differences for Quinoa Producing and Non-Quinoa Producing Departments in 2005") replace

* 2006
estpost ttest agdummy hhearn tothhmem inchhgross exphhgross poor if year == 2006, by(quinoa_dep)

esttab using sumstats06.rtf, cell((mu_1(label(Non-Quinoa)) mu_2(label(Quinoa)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1c: Means and Differences for Quinoa Producing and Non-Quinoa Producing Departments in 2006") replace

* 2007
estpost ttest agdummy hhearn tothhmem inchhgross exphhgross poor if year == 2007, by(quinoa_dep)

esttab using sumstats07.rtf, cell((mu_1(label(Non-Quinoa)) mu_2(label(Quinoa)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1d: Means and Differences for Quinoa Producing and Non-Quinoa Producing Departments in 2007") replace

* 2008
estpost ttest agdummy hhearn tothhmem inchhgross exphhgross poor if year == 2008, by(quinoa_dep)

esttab using sumstats08.rtf, cell((mu_1(label(Non-Quinoa)) mu_2(label(Quinoa)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1e: Means and Differences for Quinoa Producing and Non-Quinoa Producing Departments in 2008") replace

* 2009
estpost ttest agdummy hhearn tothhmem inchhgross exphhgross poor if year == 2009, by(quinoa_dep)

esttab using sumstats09.rtf, cell((mu_1(label(Non-Quinoa)) mu_2(label(Quinoa)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1f: Means and Differences for Quinoa Producing and Non-Quinoa Producing Departments in 2009") replace

* 2010
estpost ttest agdummy hhearn tothhmem inchhgross exphhgross poor if year == 2010, by(quinoa_dep)

esttab using sumstats10.rtf, cell((mu_1(label(Non-Quinoa)) mu_2(label(Quinoa)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1g: Means and Differences for Quinoa Producing and Non-Quinoa Producing Departments in 2010") replace

* 2011
estpost ttest agdummy hhearn tothhmem inchhgross exphhgross poor if year == 2011, by(quinoa_dep)

esttab using sumstats11.rtf, cell((mu_1(label(Non-Quinoa)) mu_2(label(Quinoa)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1h: Means and Differences for Quinoa Producing and Non-Quinoa Producing Departments in 2011") replace

* 2012
estpost ttest agdummy hhearn tothhmem inchhgross exphhgross poor if year == 2012, by(quinoa_dep)

esttab using sumstats12.rtf, cell((mu_1(label(Non-Quinoa)) mu_2(label(Quinoa)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1i: Means and Differences for Quinoa Producing and Non-Quinoa Producing Departments in 2012") replace

*** compare percentage of households that consume quinoa across years
sort year
by year: generate obs = _n
egen total_year = max(obs), by (year)
egen quin_cons_total = sum(quin_cons), by (year)

generate perc_quin_cons = quin_cons_total/total_year

label variable total_year "total number of households in year"
label variable quin_cons_total "total number of HHs that consumed quinoa in last 15 days in year"
label variable perc_quin_cons "Percentage of HHs that consumed quinoa in last 15 days"

drop obs

***********************************
* graph HH consumption and Exports*
***********************************

twoway (line perc_quin_cons year, c(l) yaxis(1)) (line exp_per_tot year, c(l) yaxis(2)), title("% of HHs consuming and Exports as % of Production") xtitle(Year) ytitle(% Households)

save "master.dta", replace

*****************************
* graph price against year  *
*****************************
line price year, title("Trend in International Price of Quinoa 2004-2012") xtitle("Year") ytitle("US Dollars")

****************************************************
* graph Quinoa Price Change and Cereal Price Change*
****************************************************

twoway (line cereal_change year, c(l) yaxis(1)) (line price_change year, c(l) yaxis(1)), title("Year-to-Year Price Change in Quinoa and Global Cereal CPI") xtitle(Year) ytitle(%)


********************************************************************************
*				REGRESSIONS 									               *
********************************************************************************
*** NAIVE ESTIMATION ***
reg ln_inc post hhearn tothhmem, robust
estimate store reg1

reg ln_exp post hhearn tothhmem, robust
estimate store reg2

esttab reg1 reg2 using "naive.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 2: Naive Regression of Log Income and Log Expenditure on Post") nonumbers ///
coeflabels(post "post price spike" hhearn "income earners" tothhmem "total members") ///
mtitle("Gross Annual Income" "Annual Expenditure") label replace

*** DIFF-IN-DIFF-IN-DIFF ESTIMATION ***

generate quinoa_depXpost = quinoa_dep*post
generate quinoa_depXagdummy = quinoa_dep*agdummy
generate postXagdummy = post*agdummy
generate quinoa_depXpostXagdummy = quinoa_dep*post*agdummy

reg ln_inc quinoa_dep post agdummy quinoa_depXpost quinoa_depXagdummy postXagdummy ///
quinoa_depXpostXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg3

reg ln_exp quinoa_dep post agdummy quinoa_depXpost quinoa_depXagdummy postXagdummy ///
quinoa_depXpostXagdummy ln_price hhearn tothhmem GDP_change cereal_change, robust
estimate store reg4

esttab reg3 reg4 using "diff_diff_diff.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 3: Difference-in-Difference-in-Difference") nonumbers ///
keep(quinoa_dep post agdummy quinoa_depXpostXagdummy) coeflabels(quinoa_dep "Quinoa Region" post "Post Price Spike" agdummy "Farmer" quinoa_depXpostXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

*** ALTERNATIVES TO MAIN ESTIMATING EQUATION ***
**********************************************
* use ln_price and ln_price^2 instead of post*
**********************************************

generate quinoa_depXln_price = quinoa_dep*ln_price
generate ln_priceXagdummy = ln_price*agdummy
generate quinoa_depXln_priceXagdummy = quinoa_dep*ln_price*agdummy

/*
generate ln_price_sq = ln_price**2

generate quinoa_depXln_price_sq = quinoa_dep*ln_price_sq
generate ln_price_sqXagdummy = ln_price_sq*agdummy
generate quinoa_depXln_price_sqXagdummy = quinoa_dep*ln_price_sq*agdummy
*/
reg ln_inc quinoa_dep ln_price agdummy quinoa_depXln_price quinoa_depXagdummy ln_priceXagdummy ///
quinoa_depXln_priceXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg5

reg ln_exp quinoa_dep ln_price agdummy quinoa_depXln_price quinoa_depXagdummy ln_priceXagdummy ///
quinoa_depXln_priceXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg6

esttab reg5 reg6 using "diff_diff_diff_alt_1.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 4: Difference-in-Difference-in-Difference with Price") nonumbers ///
keep(quinoa_dep ln_price agdummy quinoa_depXln_priceXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_price "Log of Price" agdummy "Farmer" quinoa_depXln_priceXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace


************************************************************
* use exports as a percent of production instead of post   *
************************************************************
generate quinoa_depXexp_per_tot = quinoa_dep*exp_per_tot
generate exp_per_totXagdummy = exp_per_tot*agdummy
generate quinoa_depXexp_per_totXagdummy = quinoa_dep*exp_per_tot*agdummy

reg ln_inc quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_tot quinoa_depXagdummy exp_per_totXagdummy ///
quinoa_depXexp_per_totXagdummy hhearn tothhmem, robust
estimate store reg7

reg ln_exp quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_tot quinoa_depXagdummy exp_per_totXagdummy ///
quinoa_depXexp_per_totXagdummy hhearn tothhmem, robust
estimate store reg8

esttab reg7 reg8 using "diff_diff_diff_alt_2.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 5: Difference-in-Difference-in-Difference with % Exports") nonumbers ///
keep(quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_totXagdummy) coeflabels(quinoa_dep "Quinoa Region" exp_per_tot "% Exports" agdummy "Farmer" quinoa_depXexp_per_totXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

**************************************
* use log of exports  instead of post*
**************************************
generate quinoa_depXln_exports_kg = quinoa_dep*ln_exports_kg
generate ln_exports_kgXagdummy = ln_exports_kg*agdummy
generate quinoa_depXln_exports_kgXagdummy = quinoa_dep*ln_exports_kg*agdummy

reg ln_inc quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kg quinoa_depXagdummy ln_exports_kgXagdummy ///
quinoa_depXln_exports_kgXagdummy hhearn tothhmem, robust
estimate store reg9

reg ln_exp quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kg quinoa_depXagdummy ln_exports_kgXagdummy ///
quinoa_depXln_exports_kgXagdummy hhearn tothhmem, robust
estimate store reg10

esttab reg9 reg10 using "diff_diff_diff_alt_3.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 6: Difference-in-Difference-in-Difference with Log Exports") nonumbers ///
keep(quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kgXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_exports_kg "Log of Exports" agdummy "Farmer" quinoa_depXln_exports_kgXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

***************************************************************
* use log of global imports of peruvian quinoa instead of post*
***************************************************************

generate quinoa_depXln_world_imports = quinoa_dep*ln_world_imports
generate ln_world_importsXagdummy = ln_world_imports*agdummy
generate quinoa_depXln_world_impXagdummy = quinoa_dep*ln_world_imports*agdummy

reg ln_inc quinoa_dep ln_world_imports agdummy quinoa_depXln_world_imports quinoa_depXagdummy ln_world_importsXagdummy ///
quinoa_depXln_world_impXagdummy hhearn tothhmem, robust
estimate store reg11

reg ln_exp quinoa_dep ln_world_imports agdummy quinoa_depXln_world_imports quinoa_depXagdummy ln_world_importsXagdummy ///
quinoa_depXln_world_impXagdummy hhearn tothhmem, robust
estimate store reg12

esttab reg11 reg12 using "diff_diff_diff_alt_4.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 7: Difference-in-Difference-in-Difference with Log Imports") nonumbers ///
keep(quinoa_dep ln_world_imports agdummy quinoa_depXln_world_impXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_world_imports "Log Global Peruvian Quinoa Imports" agdummy "Farmer" quinoa_depXln_world_impXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

*************************
* Section 6.2 Trim Data *
*************************

*** Drop top 1% of Income and Expenditure in USD

use master.dta, clear

* create percentiles of inc_USD
gen top_1_inc = 0

pctile pct = inc_USD [w=factor07], nq(100) genp(percent)

replace top_1_inc = 1 if inc_USD >= r(r99)

drop pct percent
* create percentiles of exp_USD
gen top_1_exp = 0

pctile pct = exp_USD [w=factor07], nq(100) genp(percent)

replace top_1_exp = 1 if exp_USD >= r(r99)

drop if top_1_inc == 1 | top_1_exp == 1

drop top_1_inc top_1_exp

save master_trim_1.dta, replace

* Measure median inc_USD
by year: egen inc_USD_median = median(inc_USD)

tab year inc_USD_median

* Measure median exp_USD
by year: egen exp_USD_median = median(exp_USD)

tab year exp_USD_median

* measure income and expenditure by pre/post
estpost ttest inc_USD exp_USD, by(post)

* measure income and expenditure by quinoa department
estpost ttest inc_USD exp_USD, by(quinoa_dep)

*****************************
* Keep only Poor Households *
*****************************

use master.dta, clear

* drop all non-poor households
keep if poor == 1

* Measure median inc_USD
by year: egen inc_USD_median = median(inc_USD)

tab year inc_USD_median

* Measure median exp_USD
by year: egen exp_USD_median = median(exp_USD)

tab year exp_USD_median

* measure income and expenditure by pre/post
estpost ttest inc_USD exp_USD, by(post)

* measure income and expenditure by quinoa department
estpost ttest inc_USD exp_USD, by(quinoa_dep)

save master_poor.dta, replace

*********************************
* Keep only Non-Poor Households *
*********************************

use master.dta, clear

* drop all non-poor households
keep if poor == 0

* Measure median inc_USD
by year: egen inc_USD_median = median(inc_USD)

tab year inc_USD_median

* Measure median exp_USD
by year: egen exp_USD_median = median(exp_USD)

tab year exp_USD_median

* measure income and expenditure by pre/post
estpost ttest inc_USD exp_USD, by(post)

* measure income and expenditure by quinoa department
estpost ttest inc_USD exp_USD, by(quinoa_dep)

save master_nonpoor.dta, replace

*************************************
* MAIN REGRESSION WITH TRIMMED DATA *
*************************************

******************
* TOP 1% TRIMMED *
******************

use master_trim_1.dta, clear

*** DIFF-IN-DIFF-IN-DIFF ESTIMATION ***

generate quinoa_depXpost = quinoa_dep*post
generate quinoa_depXagdummy = quinoa_dep*agdummy
generate postXagdummy = post*agdummy
generate quinoa_depXpostXagdummy = quinoa_dep*post*agdummy

reg ln_inc quinoa_dep post agdummy quinoa_depXpost quinoa_depXagdummy postXagdummy ///
quinoa_depXpostXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg3

reg ln_exp quinoa_dep post agdummy quinoa_depXpost quinoa_depXagdummy postXagdummy ///
quinoa_depXpostXagdummy ln_price hhearn tothhmem GDP_change cereal_change, robust
estimate store reg4

esttab reg3 reg4 using "diff_diff_diff.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 3: Difference-in-Difference-in-Difference") nonumbers ///
keep(quinoa_dep post agdummy quinoa_depXpostXagdummy) coeflabels(quinoa_dep "Quinoa Region" post "Post Price Spike" agdummy "Farmer" quinoa_depXpostXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

******************
* ONLY POOR      *
******************

use master_poor.dta, clear

*** DIFF-IN-DIFF-IN-DIFF ESTIMATION ***

generate quinoa_depXpost = quinoa_dep*post
generate quinoa_depXagdummy = quinoa_dep*agdummy
generate postXagdummy = post*agdummy
generate quinoa_depXpostXagdummy = quinoa_dep*post*agdummy

reg ln_inc quinoa_dep post agdummy quinoa_depXpost quinoa_depXagdummy postXagdummy ///
quinoa_depXpostXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg3

reg ln_exp quinoa_dep post agdummy quinoa_depXpost quinoa_depXagdummy postXagdummy ///
quinoa_depXpostXagdummy ln_price hhearn tothhmem GDP_change cereal_change, robust
estimate store reg4

esttab reg3 reg4 using "diff_diff_diff.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 3: Difference-in-Difference-in-Difference") nonumbers ///
keep(quinoa_dep post agdummy quinoa_depXpostXagdummy) coeflabels(quinoa_dep "Quinoa Region" post "Post Price Spike" agdummy "Farmer" quinoa_depXpostXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace


**********************
* ONLY Non-POOR      *
**********************

use master_nonpoor.dta, clear

*** DIFF-IN-DIFF-IN-DIFF ESTIMATION ***

generate quinoa_depXpost = quinoa_dep*post
generate quinoa_depXagdummy = quinoa_dep*agdummy
generate postXagdummy = post*agdummy
generate quinoa_depXpostXagdummy = quinoa_dep*post*agdummy

reg ln_inc quinoa_dep post agdummy quinoa_depXpost quinoa_depXagdummy postXagdummy ///
quinoa_depXpostXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg3

reg ln_exp quinoa_dep post agdummy quinoa_depXpost quinoa_depXagdummy postXagdummy ///
quinoa_depXpostXagdummy ln_price hhearn tothhmem GDP_change cereal_change, robust
estimate store reg4

esttab reg3 reg4 using "diff_diff_diff.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 3: Difference-in-Difference-in-Difference") nonumbers ///
keep(quinoa_dep post agdummy quinoa_depXpostXagdummy) coeflabels(quinoa_dep "Quinoa Region" post "Post Price Spike" agdummy "Farmer" quinoa_depXpostXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace


*********************************************
* ALTERNATIVE REGRESSIONS WITH TRIMMED DATA *
*********************************************

******************
* TOP 1% TRIMMED *
******************

use master_trim_1.dta, clear

generate quinoa_depXagdummy = quinoa_dep*agdummy

*** ALTERNATIVES TO MAIN ESTIMATING EQUATION ***
**********************************************
* use ln_price and ln_price^2 instead of post*
**********************************************



generate quinoa_depXln_price = quinoa_dep*ln_price
generate ln_priceXagdummy = ln_price*agdummy
generate quinoa_depXln_priceXagdummy = quinoa_dep*ln_price*agdummy

/*
generate ln_price_sq = ln_price**2

generate quinoa_depXln_price_sq = quinoa_dep*ln_price_sq
generate ln_price_sqXagdummy = ln_price_sq*agdummy
generate quinoa_depXln_price_sqXagdummy = quinoa_dep*ln_price_sq*agdummy
*/
reg ln_inc quinoa_dep ln_price agdummy quinoa_depXln_price quinoa_depXagdummy ln_priceXagdummy ///
quinoa_depXln_priceXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg5

reg ln_exp quinoa_dep ln_price agdummy quinoa_depXln_price quinoa_depXagdummy ln_priceXagdummy ///
quinoa_depXln_priceXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg6

esttab reg5 reg6 using "diff_diff_diff_alt_1.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 4: Difference-in-Difference-in-Difference with Price") nonumbers ///
keep(quinoa_dep ln_price agdummy quinoa_depXln_priceXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_price "Log of Price" agdummy "Farmer" quinoa_depXln_priceXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace


************************************************************
* use exports as a percent of production instead of post   *
************************************************************
generate quinoa_depXexp_per_tot = quinoa_dep*exp_per_tot
generate exp_per_totXagdummy = exp_per_tot*agdummy
generate quinoa_depXexp_per_totXagdummy = quinoa_dep*exp_per_tot*agdummy

reg ln_inc quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_tot quinoa_depXagdummy exp_per_totXagdummy ///
quinoa_depXexp_per_totXagdummy hhearn tothhmem, robust
estimate store reg7

reg ln_exp quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_tot quinoa_depXagdummy exp_per_totXagdummy ///
quinoa_depXexp_per_totXagdummy hhearn tothhmem, robust
estimate store reg8

esttab reg7 reg8 using "diff_diff_diff_alt_2.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 5: Difference-in-Difference-in-Difference with % Exports") nonumbers ///
keep(quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_totXagdummy) coeflabels(quinoa_dep "Quinoa Region" exp_per_tot "% Exports" agdummy "Farmer" quinoa_depXexp_per_totXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

**************************************
* use log of exports  instead of post*
**************************************
generate quinoa_depXln_exports_kg = quinoa_dep*ln_exports_kg
generate ln_exports_kgXagdummy = ln_exports_kg*agdummy
generate quinoa_depXln_exports_kgXagdummy = quinoa_dep*ln_exports_kg*agdummy

reg ln_inc quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kg quinoa_depXagdummy ln_exports_kgXagdummy ///
quinoa_depXln_exports_kgXagdummy hhearn tothhmem, robust
estimate store reg9

reg ln_exp quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kg quinoa_depXagdummy ln_exports_kgXagdummy ///
quinoa_depXln_exports_kgXagdummy hhearn tothhmem, robust
estimate store reg10

esttab reg9 reg10 using "diff_diff_diff_alt_3.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 6: Difference-in-Difference-in-Difference with Log Exports") nonumbers ///
keep(quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kgXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_exports_kg "Log of Exports" agdummy "Farmer" quinoa_depXln_exports_kgXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

***************************************************************
* use log of global imports of peruvian quinoa instead of post*
***************************************************************

generate quinoa_depXln_world_imports = quinoa_dep*ln_world_imports
generate ln_world_importsXagdummy = ln_world_imports*agdummy
generate quinoa_depXln_world_impXagdummy = quinoa_dep*ln_world_imports*agdummy

reg ln_inc quinoa_dep ln_world_imports agdummy quinoa_depXln_world_imports quinoa_depXagdummy ln_world_importsXagdummy ///
quinoa_depXln_world_impXagdummy hhearn tothhmem, robust
estimate store reg11

reg ln_exp quinoa_dep ln_world_imports agdummy quinoa_depXln_world_imports quinoa_depXagdummy ln_world_importsXagdummy ///
quinoa_depXln_world_impXagdummy hhearn tothhmem, robust
estimate store reg12

esttab reg11 reg12 using "diff_diff_diff_alt_4.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 7: Difference-in-Difference-in-Difference with Log Imports") nonumbers ///
keep(quinoa_dep ln_world_imports agdummy quinoa_depXln_world_impXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_world_imports "Log Global Peruvian Quinoa Imports" agdummy "Farmer" quinoa_depXln_world_impXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace


*****************************
* POOR HOUSEHOLDS ONLY DATA *
*****************************

use master_poor.dta, clear

generate quinoa_depXagdummy = quinoa_dep*agdummy

*** ALTERNATIVES TO MAIN ESTIMATING EQUATION ***

**********************************************
* use ln_price and ln_price^2 instead of post*
**********************************************



generate quinoa_depXln_price = quinoa_dep*ln_price
generate ln_priceXagdummy = ln_price*agdummy
generate quinoa_depXln_priceXagdummy = quinoa_dep*ln_price*agdummy

/*
generate ln_price_sq = ln_price**2

generate quinoa_depXln_price_sq = quinoa_dep*ln_price_sq
generate ln_price_sqXagdummy = ln_price_sq*agdummy
generate quinoa_depXln_price_sqXagdummy = quinoa_dep*ln_price_sq*agdummy
*/
reg ln_inc quinoa_dep ln_price agdummy quinoa_depXln_price quinoa_depXagdummy ln_priceXagdummy ///
quinoa_depXln_priceXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg5

reg ln_exp quinoa_dep ln_price agdummy quinoa_depXln_price quinoa_depXagdummy ln_priceXagdummy ///
quinoa_depXln_priceXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg6

esttab reg5 reg6 using "diff_diff_diff_alt_1.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 4: Difference-in-Difference-in-Difference with Price") nonumbers ///
keep(quinoa_dep ln_price agdummy quinoa_depXln_priceXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_price "Log of Price" agdummy "Farmer" quinoa_depXln_priceXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace


************************************************************
* use exports as a percent of production instead of post   *
************************************************************
generate quinoa_depXexp_per_tot = quinoa_dep*exp_per_tot
generate exp_per_totXagdummy = exp_per_tot*agdummy
generate quinoa_depXexp_per_totXagdummy = quinoa_dep*exp_per_tot*agdummy

reg ln_inc quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_tot quinoa_depXagdummy exp_per_totXagdummy ///
quinoa_depXexp_per_totXagdummy hhearn tothhmem, robust
estimate store reg7

reg ln_exp quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_tot quinoa_depXagdummy exp_per_totXagdummy ///
quinoa_depXexp_per_totXagdummy hhearn tothhmem, robust
estimate store reg8

esttab reg7 reg8 using "diff_diff_diff_alt_2.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 5: Difference-in-Difference-in-Difference with % Exports") nonumbers ///
keep(quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_totXagdummy) coeflabels(quinoa_dep "Quinoa Region" exp_per_tot "% Exports" agdummy "Farmer" quinoa_depXexp_per_totXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

**************************************
* use log of exports  instead of post*
**************************************
generate quinoa_depXln_exports_kg = quinoa_dep*ln_exports_kg
generate ln_exports_kgXagdummy = ln_exports_kg*agdummy
generate quinoa_depXln_exports_kgXagdummy = quinoa_dep*ln_exports_kg*agdummy

reg ln_inc quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kg quinoa_depXagdummy ln_exports_kgXagdummy ///
quinoa_depXln_exports_kgXagdummy hhearn tothhmem, robust
estimate store reg9

reg ln_exp quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kg quinoa_depXagdummy ln_exports_kgXagdummy ///
quinoa_depXln_exports_kgXagdummy hhearn tothhmem, robust
estimate store reg10

esttab reg9 reg10 using "diff_diff_diff_alt_3.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 6: Difference-in-Difference-in-Difference with Log Exports") nonumbers ///
keep(quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kgXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_exports_kg "Log of Exports" agdummy "Farmer" quinoa_depXln_exports_kgXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

***************************************************************
* use log of global imports of peruvian quinoa instead of post*
***************************************************************

generate quinoa_depXln_world_imports = quinoa_dep*ln_world_imports
generate ln_world_importsXagdummy = ln_world_imports*agdummy
generate quinoa_depXln_world_impXagdummy = quinoa_dep*ln_world_imports*agdummy

reg ln_inc quinoa_dep ln_world_imports agdummy quinoa_depXln_world_imports quinoa_depXagdummy ln_world_importsXagdummy ///
quinoa_depXln_world_impXagdummy hhearn tothhmem, robust
estimate store reg11

reg ln_exp quinoa_dep ln_world_imports agdummy quinoa_depXln_world_imports quinoa_depXagdummy ln_world_importsXagdummy ///
quinoa_depXln_world_impXagdummy hhearn tothhmem, robust
estimate store reg12

esttab reg11 reg12 using "diff_diff_diff_alt_4.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 7: Difference-in-Difference-in-Difference with Log Imports") nonumbers ///
keep(quinoa_dep ln_world_imports agdummy quinoa_depXln_world_impXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_world_imports "Log Global Peruvian Quinoa Imports" agdummy "Farmer" quinoa_depXln_world_impXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace


*********************************
* NON-POOR HOUSEHOLDS ONLY DATA *
*********************************

use master_nonpoor.dta, clear

generate quinoa_depXagdummy = quinoa_dep*agdummy

*** ALTERNATIVES TO MAIN ESTIMATING EQUATION ***
**********************************************
* use ln_price and ln_price^2 instead of post*
**********************************************

generate quinoa_depXln_price = quinoa_dep*ln_price
generate ln_priceXagdummy = ln_price*agdummy
generate quinoa_depXln_priceXagdummy = quinoa_dep*ln_price*agdummy

/*
generate ln_price_sq = ln_price**2

generate quinoa_depXln_price_sq = quinoa_dep*ln_price_sq
generate ln_price_sqXagdummy = ln_price_sq*agdummy
generate quinoa_depXln_price_sqXagdummy = quinoa_dep*ln_price_sq*agdummy
*/
reg ln_inc quinoa_dep ln_price agdummy quinoa_depXln_price quinoa_depXagdummy ln_priceXagdummy ///
quinoa_depXln_priceXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg5

reg ln_exp quinoa_dep ln_price agdummy quinoa_depXln_price quinoa_depXagdummy ln_priceXagdummy ///
quinoa_depXln_priceXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg6

esttab reg5 reg6 using "diff_diff_diff_alt_1.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 4: Difference-in-Difference-in-Difference with Price") nonumbers ///
keep(quinoa_dep ln_price agdummy quinoa_depXln_priceXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_price "Log of Price" agdummy "Farmer" quinoa_depXln_priceXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace


************************************************************
* use exports as a percent of production instead of post   *
************************************************************
generate quinoa_depXexp_per_tot = quinoa_dep*exp_per_tot
generate exp_per_totXagdummy = exp_per_tot*agdummy
generate quinoa_depXexp_per_totXagdummy = quinoa_dep*exp_per_tot*agdummy

reg ln_inc quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_tot quinoa_depXagdummy exp_per_totXagdummy ///
quinoa_depXexp_per_totXagdummy hhearn tothhmem, robust
estimate store reg7

reg ln_exp quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_tot quinoa_depXagdummy exp_per_totXagdummy ///
quinoa_depXexp_per_totXagdummy hhearn tothhmem, robust
estimate store reg8

esttab reg7 reg8 using "diff_diff_diff_alt_2.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 5: Difference-in-Difference-in-Difference with % Exports") nonumbers ///
keep(quinoa_dep exp_per_tot agdummy quinoa_depXexp_per_totXagdummy) coeflabels(quinoa_dep "Quinoa Region" exp_per_tot "% Exports" agdummy "Farmer" quinoa_depXexp_per_totXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

**************************************
* use log of exports  instead of post*
**************************************
generate quinoa_depXln_exports_kg = quinoa_dep*ln_exports_kg
generate ln_exports_kgXagdummy = ln_exports_kg*agdummy
generate quinoa_depXln_exports_kgXagdummy = quinoa_dep*ln_exports_kg*agdummy

reg ln_inc quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kg quinoa_depXagdummy ln_exports_kgXagdummy ///
quinoa_depXln_exports_kgXagdummy hhearn tothhmem, robust
estimate store reg9

reg ln_exp quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kg quinoa_depXagdummy ln_exports_kgXagdummy ///
quinoa_depXln_exports_kgXagdummy hhearn tothhmem, robust
estimate store reg10

esttab reg9 reg10 using "diff_diff_diff_alt_3.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 6: Difference-in-Difference-in-Difference with Log Exports") nonumbers ///
keep(quinoa_dep ln_exports_kg agdummy quinoa_depXln_exports_kgXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_exports_kg "Log of Exports" agdummy "Farmer" quinoa_depXln_exports_kgXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

***************************************************************
* use log of global imports of peruvian quinoa instead of post*
***************************************************************

generate quinoa_depXln_world_imports = quinoa_dep*ln_world_imports
generate ln_world_importsXagdummy = ln_world_imports*agdummy
generate quinoa_depXln_world_impXagdummy = quinoa_dep*ln_world_imports*agdummy

reg ln_inc quinoa_dep ln_world_imports agdummy quinoa_depXln_world_imports quinoa_depXagdummy ln_world_importsXagdummy ///
quinoa_depXln_world_impXagdummy hhearn tothhmem, robust
estimate store reg11

reg ln_exp quinoa_dep ln_world_imports agdummy quinoa_depXln_world_imports quinoa_depXagdummy ln_world_importsXagdummy ///
quinoa_depXln_world_impXagdummy hhearn tothhmem, robust
estimate store reg12

esttab reg11 reg12 using "diff_diff_diff_alt_4.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 7: Difference-in-Difference-in-Difference with Log Imports") nonumbers ///
keep(quinoa_dep ln_world_imports agdummy quinoa_depXln_world_impXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_world_imports "Log Global Peruvian Quinoa Imports" agdummy "Farmer" quinoa_depXln_world_impXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Income" "Gross Annual Expenditure") label replace

*********************
* ROBUSTNESS CHECKS *
*********************

xi: reg quinoa_dep i.month
estimate store regmonth

label variable _Imonth_2 "February"
label variable _Imonth_3 "March"
label variable _Imonth_4 "April"
label variable _Imonth_5 "May"
label variable _Imonth_6 "June"
label variable _Imonth_7 "July"
label variable _Imonth_8 "August"
label variable _Imonth_9 "September"
label variable _Imonth_10 "October"
label variable _Imonth_11 "November"
label variable _Imonth_12 "December"

esttab regmonth using "RobustMonth.rtf", label nogaps lines se ///
stats(r2 N) title(\b "Table 25: Regression of Quinoa Department on Month Dummies") nonumbers ///
mtitle("Quinoa Department") replace

xi: reg agdummy i.month
estimate store regmonth

esttab regmonth using "RobustMonth2.rtf", label nogaps lines se ///
stats(r2 N) title(\b "Table 26: Regression of Farmer on Month Dummies") nonumbers ///
mtitle("Farmer") replace

************************************************************
* Run the regression by omitting last 6 months of the year *
************************************************************

use master_poor.dta, clear

drop if month == 7| month == 8| month == 9| month == 10| month == 11| month == 12

generate quinoa_depXagdummy = quinoa_dep*agdummy

generate quinoa_depXln_price = quinoa_dep*ln_price
generate ln_priceXagdummy = ln_price*agdummy
generate quinoa_depXln_priceXagdummy = quinoa_dep*ln_price*agdummy

reg ln_exp quinoa_dep ln_price agdummy quinoa_depXln_price quinoa_depXagdummy ln_priceXagdummy ///
quinoa_depXln_priceXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg6

esttab reg6 using "diff_diff_diff_robust_1.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 27: Robustness Check: Omitting Last 6") nonumbers ///
keep(quinoa_dep ln_price agdummy quinoa_depXln_priceXagdummy) coeflabels(quinoa_dep "Quinoa Region" ln_price "Log of Price" agdummy "Farmer" quinoa_depXln_priceXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Expenditure") label replace

****************************************************************
* Run the regression by controlling for district fixed effects *
****************************************************************

use master_poor.dta, clear

generate quinoa_depXagdummy = quinoa_dep*agdummy

generate quinoa_depXln_price = quinoa_dep*ln_price
generate ln_priceXagdummy = ln_price*agdummy
generate quinoa_depXln_priceXagdummy = quinoa_dep*ln_price*agdummy

areg ln_exp ln_price agdummy quinoa_depXln_price quinoa_depXagdummy ln_priceXagdummy ///
quinoa_depXln_priceXagdummy hhearn tothhmem GDP_change cereal_change, absorb(geog) robust
estimate store reg6

esttab reg6 using "diff_diff_diff_robust_2.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 29: Robustness Check: District Fixed Effects") nonumbers ///
keep(ln_price agdummy quinoa_depXln_priceXagdummy) coeflabels(ln_price "Log of Price" agdummy "Farmer" quinoa_depXln_priceXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Expenditure") label replace

***************************************************************************
* Run the regression by controlling for log of Quinoa Production by dept. *
***************************************************************************

use master_poor.dta, clear

generate ln_quinoa = ln(ton)
label variable ln_quinoa "deparmental production of quinoa in 000s kg"

generate ln_quinoaXagdummy = ln_quinoa*agdummy

generate ln_quinoaXln_price = ln_quinoa*ln_price
generate ln_priceXagdummy = ln_price*agdummy
generate ln_quinoaXln_priceXagdummy = ln_quinoa*ln_price*agdummy

reg ln_exp ln_price agdummy ln_quinoa ln_quinoaXln_price ln_quinoaXagdummy ln_priceXagdummy ///
ln_quinoaXln_priceXagdummy hhearn tothhmem GDP_change cereal_change, robust
estimate store reg6

esttab reg6 using "diff_diff_diff_robust_3.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 30: Robustness Check: Log of Quinoa Production by Department") nonumbers ///
keep(ln_price ln_quinoa agdummy ln_quinoaXln_priceXagdummy) coeflabels(ln_price "Log of Price" ln_quinoa "Log of Quinoa" agdummy "Farmer" ln_quinoaXln_priceXagdummy "diff-in-diff-in-diff") ///
mtitle("Gross Annual Expenditure") label replace












