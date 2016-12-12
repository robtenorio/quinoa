
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

	* keep only the identifier variables and consumption variables
	keep year month cong hunit hhold geog p601a p601b p601a1 p601a2 p601a3 p601a4 ///
	p601a5 p601a6 p601a7 p601b1 p601b2 p601b3 p601c p601d1 p601d2 p601d3

	destring, replace
	
	save `quin_cons`j''
	
	}

append using `quin_cons2004' `quin_cons2005' `quin_cons2006' `quin_cons2007' `quin_cons2008' ///
`quin_cons2009' `quin_cons2010' `quin_cons2011'

codebookout "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Data/Quinua_consumption.xlsx"








