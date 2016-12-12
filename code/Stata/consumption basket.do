set more off

cd "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Data/master data and merge"
set more off

********************************************************************************
*                            APPENDING HH SUMMARY DATA                         * 
********************************************************************************

*Cleaning and translating 2004-2012 summary data*

forvalue j = 2004/2012 {
	use "sumaria-`j'.dta", clear
	tempfile sum_`j'

	destring ubigeo, replace

	keep a—o mes conglome vivienda hogar ubigeo gru11hd ///
	gashog1d factor07      

	rename a—o year
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
	label variable gru11hd "Total Food expenditures"
	rename gashog1d  moexphh
	label variable moexphh "Annualized Monetary Expenditure counting Investment and not counting In-Kind Donations"

	save `sum_`j'' 

}

***Append to make one master data set***

append using `sum_2004' `sum_2005' `sum_2006' `sum_2007' `sum_2008' `sum_2009' ///
`sum_2010' `sum_2011'

tempfile sum_master

destring, replace

save `sum_master'

* clean 2004-20012 food consumption data
forvalue j = 2004/2012 {

	tempfile food_cons`j'

	use "enaho01-`j'-601.dta", clear

	rename a* year
	rename mes month
	rename conglome cong
	rename vivienda hunit
	rename hogar hhold
	rename ubigeo geog

	* keep only the identifier variables and consumption variables
	keep year month cong hunit hhold geog p601a produc61 p601b p601c i601d2 d601c
	
	save `food_cons`j''
	
	}
	
append using `food_cons2004' `food_cons2005' `food_cons2006' `food_cons2007' `food_cons2008' ///
`food_cons2009' `food_cons2010' `food_cons2011'

label variable year "Year of survey"
label variable month "Month of survey distribution"
label variable hunit "Stratefied sampling unit 2 at house/building level"
label variable hhold "Household unit of measurement, level 3"
label variable geog "Geographic location"
label variable p601a "Product Code"
label variable p601b "Consumed product in last 15 days?"
label variable p601c "What was the total amount of the purchase?"
label variable i601d2 "Total Annualized quantity of food k was consumed?"
label variable d601c "Total Annualized, deflated expenditure on food k"
label variable produc61 "Product Code - INEI Classification"

destring, replace

merge m:1 year month cong hunit hhold using `sum_master', nogenerate

* what is the food group and what are the codes for variable produc61?
local biscuit 110051 110053
local bread	110062	110063 110068 110069 110074	110076	110091	110093 110090																																																						
local cake	110086																																																																																																																																																																														
local rice	110100	110101	110102	110103																																																																																								
local oats	110105	110106																																																																																																																																																																																							
local barley_rye_wheat	110113	110114	110118	110139	110142																																																																												
local corn_maize	110116	110123	110125	110126	110129	110130	110624	110625	190103																																																																						
local other_cereals	110155																																																																																												
local alcohol	130106	130118	130120	130127																																																																			
local soft_drinks	120103	120104																																																																																											
local pasta_noodles	110156																																																																																												
local cow_meat	110244	110245	110246	110247	110250	110251	110253	110255	110256	110257																																																																					
local chicken	110222	110235	110236	110237	110238																																																																								
local pig	110216																																																																																																																																																																																																																								
local fish	110386	110389	110400	110410 110413 110418 110443	110451	110452	110456 110460 110461
local shellfish	110354	110356	110358																																																																																																																																																															
local animal_milk	110504	110506	110511																																																																																		
local cheese	110513	110514	110515	110517	110522																																																																																
local yogurt	110524																																																																																												
local cream	110525																																																																																												
local eggs	110526	110531	110532																																																																																			
local algae	110350	110351																																																																																											
local chard	110601																																																																																																																																																																														
local artichoke	110609																																																																																																																																																																																						
local celery	110610																																																																																												
local peas	110611																																																																																												
local eggplant	110613																																																																																												
local beetroot	110615																																																																																												
local broccoli	110616																																																																																												
local caigua	110617																																																																																												
local onion	110619	110620	110621																																																																																								
local chileno_verde	110623																																																																																												
local cabbage	110626	110627	110628																																																																																								
local cauliflower	110629																																																																																																																																																																																						
local esparragos	110631	110632																																																																																											
local spinach	110633	111305																																																																																											
local legume	110802	110808	110823	110824																																																																																																																																
local lettuce	110640	110641																																																																																						
local turnip	110642																																																																																																																																																																																							
local cucumber	110644	110756																																																																																																																																																																																							
local alfalfa	190102																																																																																												
local leek	110647																																																																																												
local radish	110648																																																																																												
local tomato	110650	110651	110672																																																																																								
local carrot	110654	110679																																																																																											
local squash	110655	110657																																																																																								
local yuca	110907																																																																																												
local olluco	110912																																																																																												
local potato	110913	110915	110918	110927																																																																		
local pineapple	110761																																																																																												
local banana	110763	110764																																																																																				
local apple	110737																																																																																										
local mango	110736																																																																																												
local citrus_fruit	110730	110735	110745																																																																																																																																																																												
local lucuma	110732																																																																																																																																																																																							
local avocado	110750																																																																																									
local grape_raisin	110781																																																																																								
local pear	110757	110758																																																																																											
local coconut	110713																																																																																												
local cherry	110708																																																																																												
local strawberry	110720																																																																																											
local blackberry	110743																																																																																												
local guava	110724																																																																																												
local guabana	110723																																																																																												
local passion_fruit	110740																																																																																												
local granadilla	110722																																																																																												
local chirimoya	110709																																																																																												
local papaya	110754																																																																																												
local pecan	110755																																																																																												
local watermelon 110770																																																																																												
local tamarind 110771																																																																																												
local apricot 110702	110717																																																																																																																																																																																		
local almond 110703																																																																																												
local peanut 110845																																																																																												
local lentil 110827	110828	110829																																																																																										
local sweet_potato	110902	110903																																																																																																																																																																																																																																																																																																																																																																																																																																																										

* create a list of all the food local names
local foods `" "biscuit" "bread" "cake" "rice" "oats" "barley_rye_wheat" "corn_maize" "other_cereals" "alcohol" "soft_drinks" "pasta_noodles" "cow_meat" "chicken" "pig" "fish" "shellfish" "animal_milk" "cheese" "yogurt" "cream" "eggs" "algae" "chard" "artichoke" "celery" "peas" "eggplant" "beetroot" "broccoli" "caigua" "onion" "chileno_verde" "cabbage" "cauliflower" "esparragos" "spinach" "legume" "lettuce" "turnip" "cucumber" "alfalfa" "leek" "radish" "tomato" "carrot" "squash" "yuca" "olluco" "potato" "pineapple" "banana" "apple" "mango" "citrus_fruit" "lucuma" "avocado" "grape_raisin" "pear" "coconut" "cherry" "strawberry" "blackberry" "guava" "guabana" "passion_fruit" "granadilla" "chirimoya" "papaya" "pecan" "watermelon" "tamarind" "apricot" "almond" "peanut" "lentil" "sweet_potato" "'

foreach k of local foods {
	
	* generate a dummy variable for food l consumption in last 15 days
	gen `k'_cons = 0

		foreach l of local `k' {
			replace `k'_cons = 1 if p601b == 1 & produc61 == `l'
			
			* create an individual variable for the total expenditure of each type of food product
			generate `k'_exp_`l' = d601c if produc61 == `l'
			* create an individual variable for the total quantity consumed of each type of food product
			generate `k'_quant_`l' = i601d2 if produc61 == `l'
			
			}
	
	* generate total food quantity
	egen `k'_tot_an_quant = rowtotal(`k'_quant_*)

	* generate total food expenditure
	egen `k'_tot_an_exp = rowtotal(`k'_exp_*)
	
	drop `k'_quant_* `k'_exp_*
	
	* generate total annual expenditure on food k as a proportion of total annual food expenditure
	gen `k'_per_totan_fexp = `k'_tot_an_exp/gru11hd
	
	* generate total annual expenditure on food k as a proportion of total annual expenditure
	gen `k'_per_totan_texp = `k'_tot_an_exp/moexphh
	
	label variable `k'_per_totan_fexp "Percent of total food expenditure on `k' products"
	label variable `k'_per_totan_texp "Percent of total annual expenditure on `k' products"
	label variable `k'_cons "Equals 1 if HH consumed `k' in last 15 days"
	label variable `k'_tot_an_quant "Total annualized quantity of `k' consumed by household"
	label variable `k'_tot_an_exp "Total annualized, deflated household expenditure on `k' products"
	
	}


save "food_basket.dta", replace



















