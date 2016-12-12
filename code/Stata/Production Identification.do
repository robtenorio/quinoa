*cd "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Data/master data and merge"
set more off

********************************************************************************
*                            APPENDING HH PRODUCTION DATA                      * 
********************************************************************************

*Cleaning and translating individual summary data*

forvalues year = 2004/2012 {

* clean individual food consumption data

use "enaho02-`year'-2100.dta", clear
tempfile food_prod_`year'

rename a* year
rename mes month
rename conglome cong
rename vivienda hunit
rename hogar hhold
rename ubigeo geog

* keep only the identifier variables and production variables
keep year month cong hunit hhold geog p2100b	

label variable year "Year of survey"
label variable month "Month of survey distribution"
label variable hunit "Stratefied sampling unit 2 at house/building level"
label variable hhold "Household unit of measurement, level 3"
label variable geog "Geographic location"
label variable p2100b "Food Code"

destring, replace

* what is the food group and what are the codes for variable p6100b?																																																																																																																																																																									
local rice	1302																																																																																								
local oats	1303 1701																																																																																																																																																																																							
local barley_wheat	1310 1305 1703																																																																											
local corn_maize 1307 1424 1706 4202
local eggs 4113																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																	
local chard	1401																																																																																																																																																																														
local artichoke	1405																																																																																																																																																																																					
local celery	1406																																																																																											
local peas	1501																																																																																					
local eggplant	1407																																																																																											
local beetroot	1409																																																																																								
local broccoli	1410																																																																																										
local caigua	1411																																																																																												
local onion		1413 1414																																																																																		
local chileno_verde	1818																																																																																											
local cabbage	1415																																																																																								
local cauliflower	1416																																																																																																																																																																																					
local esparragos	1418																																																																																										
local spinach	1419																																																																																											
local legume	1504 1506 4205																																																																																																																						
local lettuce	1423																																																																																						
local turnip	1425																																																																																																																																																																																					
local cucumber	1426 1150																																																																																																																																																																																						
local alfalfa	1802																																																																																												
local leek	1429																																																																																												
local radish	1430																																																																																												
local tomato	1432 4123																																																																																							
local carrot	1433																																																																																										
local squash	1434																																																																																								
local yuca	1617																																																																																											
local olluco	1609																																																																																											
local potato	1610 4210																																																																
local pineapple	1154																																																																																											
local banana	1152																																																																																				
local apple	1135																																																																																									
local mango	1133																																																																																											
local citrus_fruit	1132 1142 1127 1128																																																																																																																																																																										
local lucuma	1129																																																																																																																																																																																						
local avocado	1147																																																																																									
local grape	1167																																																																																								
local pear	1151																																																																																										
local coconut	1116																																																																																											
local cherry	1111																																																																																											
local strawberry	1119																																																																																																																																																																																					
local guava	1145																																																																																																																																																																																					
local passion_fruit	1136																																																																																											
local granadilla	1120																																																																																												
local chirimoya	1112																																																																																												
local papaya	1148																																																																																												
local pecan	1149																																																																																											
local watermelon 1157																																																																																																																																																																																																																																																																																																																																																																						
local almond 1103																																																																																											
local peanut 1134																																																																																										
local lentil 1507																																																																																									
local sweet_potato	1603 1702		
local quinua 1308																																																																																																																																																																																																																																																																																																																																																																																																																																																					

* create a list of all the food local names
local foods `" "rice" "oats" "barley_wheat" "corn_maize" "eggs" "chard" "artichoke" "celery" "peas" "eggplant" "beetroot" "broccoli" "caigua" "onion" "chileno_verde" "cabbage" "cauliflower" "esparragos" "spinach" "legume" "lettuce" "turnip" "cucumber" "alfalfa" "leek" "radish" "tomato" "carrot" "squash" "yuca" "olluco" "potato" "pineapple" "banana" "apple" "mango" "citrus_fruit" "lucuma" "avocado" "grape" "pear" "coconut" "cherry" "strawberry" "guava" "passion_fruit" "granadilla" "chirimoya" "papaya" "pecan" "watermelon" "almond" "peanut" "lentil" "sweet_potato" "quinua" "'

foreach k of local foods {

	generate `k'_producer = 0

		foreach l of local `k' {
			
			* create a dummy variable that equals one if the HH produced food item
			replace `k'_producer = 1 if p2100b == `l'
		}


}
	
collapse (max) rice_producer-quinua_producer, by(year month cong hunit hhold geog)

foreach k of local foods {
	
	label variable `k'_producer "HH Produced food `k'"

	}

save `food_prod_`year'.dta'
}

append using `food_prod_2004.dta' `food_prod_2005.dta' `food_prod_2006.dta' ///
`food_prod_2007.dta' `food_prod_2008.dta' `food_prod_2009.dta' `food_prod_2010.dta' ///
`food_prod_2011.dta'

save "food_prod.dta", replace


