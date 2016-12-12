set more off

cd "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Data/master data and merge"


********************************************************************************
*                            APPENDING HH SUMMARY DATA                         * 
********************************************************************************

*Cleaning and translating individual summary data*

local year = 2012

tempfile price_`year'

use "enaho01-`year'-601.dta", clear

rename a* year
rename mes month
rename conglome cong
rename vivienda hunit
rename hogar hhold
rename ubigeo geog

* keep only the identifier variables and price variables
keep year month cong hunit hhold geog p601a produc61 p601b p601b3 i601c i601b2

label variable year "Year of survey"
label variable month "Month of survey distribution"
label variable hunit "Stratefied sampling unit 2 at house/building level"
label variable hhold "Household unit of measurement, level 3"
label variable geog "Geographic location"

destring, replace

* what is the food group and what are the codes for variable produc61?																																																																																																																																																																													
local rice	110100	110101	110102	110103																																																																																								
local oats	110105	110106																																																																																																																																																																																							
local barley_wheat	110113	110114	110118	110139	110142																																																																												
local corn_maize	110116	110123	110125	110126	110129	110130	110624	110625	190103																																																																																																																																																																																																																																																																																																																																																																																																																																																																																
local eggs	110526	110531	110532																																																																																																																																																																													
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
local grape	110781																																																																																								
local pear	110757	110758																																																																																											
local coconut	110713																																																																																												
local cherry	110708																																																																																												
local strawberry	110720																																																																																																																																																																																						
local guava	110724																																																																																																																																																																																							
local passion_fruit	110740																																																																																												
local granadilla	110722																																																																																												
local chirimoya	110709																																																																																												
local papaya	110754																																																																																												
local pecan	110755																																																																																												
local watermelon 110770																																																																																																																																																																																																																																																																													
local almond 110703																																																																																												
local peanut 110845																																																																																												
local lentil 110827	110828	110829																																																																																										
local sweet_potato	110902	110903
local quinua 110111	110136 110137																																																																																																																																																																																																																																																																																																																																																																																																																																																							

* create a list of all the food local names
local foods `" "rice" "oats" "barley_wheat" "corn_maize" "eggs" "chard" "artichoke" "celery" "peas" "eggplant" "beetroot" "broccoli" "caigua" "onion" "chileno_verde" "cabbage" "cauliflower" "esparragos" "spinach" "legume" "lettuce" "turnip" "cucumber" "alfalfa" "leek" "radish" "tomato" "carrot" "squash" "yuca" "olluco" "potato" "pineapple" "banana" "apple" "mango" "citrus_fruit" "lucuma" "avocado" "grape" "pear" "coconut" "cherry" "strawberry" "guava" "passion_fruit" "granadilla" "chirimoya" "papaya" "pecan" "watermelon" "almond" "peanut" "lentil" "sweet_potato" quinua "'

foreach k of local foods {

		foreach l of local `k' {
			
			* create an individual variable for the price of each type of food product
			generate `k'_price_`l'_temp = i601c/i601b2 if produc61 == `l' & p601b == 1
			bysort year month cong hunit hhold: egen `k'_price_`l' = max(`k'_price_`l'_temp)
			drop `k'_price_`l'_temp
		}

	* generate total food expenditure
	egen `k'_price = rowmean(`k'_price_*)
	
	drop `k'_price_*
	

	}

collapse (max) rice_price-sweet_potato_price, by(year month cong hunit hhold geog)

save price_`year', replace


/*
cd "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Data/master data and merge"
set more off

use "price_2012.dta", clear
append using price_2004 price_2005 price_2006 price_2007 price_2008 ///
price_2009 price_2010 price_2011

merge 1:1 year month cong hunit hhold geog using "master.dta", nogenerate

save "master_v1.dta", replace





