* Difference between Quinoa consumers and non-Quinoa consumers

generate poor = 1 if poverty == 1 | poverty == 2
replace poor = 0 if poverty == 3

label variable poor "poor or extremely poor"

set more off

* compare Quinoa consumers and non_Quinoa consumers across all years
estpost ttest agdummy rural hhearn tothhmem inchhgross exphhgross poor, by(quin_cons)

esttab using "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Tables/sumstatQuin_cons_Allyr.rtf", cell((mu_1(label(Non-Consumer)) mu_2(label(Consumer)) b(label(Difference)) se(par label(Standard Error)))) /// 
nonumber nomtitle coeflabel(agdummy "farmer" rural "rural" hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1: Means and Differences for Quinoa Consumers and non-Quinoa Consumers") replace

* compare Quinoa consumers and non_Quinoa consumers across all years
estpost ttest agdummy rural hhearn tothhmem inchhgross exphhgross poor if quin_cons == 1, by(quin_self_cons)

esttab using "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Tables/sumstatQuin_self_Allyr.rtf", cell((mu_1(label(Non-Own Consumption)) mu_2(label(Own Consumption)) b(label(Difference)) se(par label(Standard Error)))) /// 
nonumber nomtitle coeflabel(agdummy "farmer" rural "rural" hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 2: Means and Differences for Quinoa Own Consumption and non-Quinoa Own Consumption for All Years Among Quinoa Consumers") replace

* compare Quinoa consumers and non_Quinoa consumers across all years
estpost ttest agdummy rural hhearn tothhmem inchhgross exphhgross poor if quin_cons == 1, by(quin_bought)

esttab using "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Tables/sumstatQuin_bought_Allyr.rtf", cell((mu_1(label(Non-Buyer)) mu_2(label(Buyer)) b(label(Difference)) se(par label(Standard Error)))) /// 
nonumber nomtitle coeflabel(agdummy "farmer" rural "rural" hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
exphhgross "annual expenditure" poor "poor") ///
modelwidth(10 20) title("Table 3: Means and Differences for Quinoa Buyers and non-Quinoa Buyers for All Years Among Quinoa Consumers") replace


forvalue j = 2004/2012 {
	* compare Quinoa consumers and non_Quinoa consumers in year j
	estpost ttest agdummy rural hhearn tothhmem inchhgross exphhgross poor if year == `j', by(quin_cons) 

	esttab using "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Tables/sumstatQuin_cons_`j'.rtf", cell((mu_1(label(Non-Consumer)) mu_2(label(Consumer)) b(label(Difference)) se(par label(Standard Error)))) /// 
	nonumber nomtitle coeflabel(agdummy "farmer" rural "rural" hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
	exphhgross "annual expenditure" poor "poor") ///
	modelwidth(10 20) title("Table 1A: Means and Differences for Quinoa Consumers and non-Quinoa Consumers for `j'") replace
}

forvalue j = 2004/2012 {
	* compare Quinoa self-consumers and non_Quinoa self-consumers in year j
	estpost ttest agdummy rural hhearn tothhmem inchhgross exphhgross poor if year == `j' & quin_cons == 1, by(quin_self_cons) 

	esttab using "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Tables/sumstatQuin_self_`j'.rtf", cell((mu_1(label(Non-Own Consumption)) mu_2(label(Own-Consumption)) b(label(Difference)) se(par label(Standard Error)))) /// 
	nonumber nomtitle coeflabel(agdummy "farmer" rural "rural" hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
	exphhgross "annual expenditure" poor "poor") ///
	modelwidth(10 20) title("Table 2A: Means and Differences for Quinoa Own-Consumption and non-Quinoa Own-Consumption for `j' Among Quinoa Consumers") replace
}

forvalue j = 2004/2012 {
	* compare Quinoa buyers and non_Quinoa buyers in year j
	estpost ttest agdummy rural hhearn tothhmem inchhgross exphhgross poor if year == `j' & quin_cons == 1, by(quin_bought) 

	esttab using "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Tables/sumstatQuin_bought_`j'.rtf", cell((mu_1(label(Non-Buyer)) mu_2(label(Buyer)) b(label(Difference)) se(par label(Standard Error)))) /// 
	nonumber nomtitle coeflabel(agdummy "farmer" rural "rural" hhearn "no. earners" tothhmem "no. members" inchhgross "annual income" ///
	exphhgross "annual expenditure" poor "poor") ///
	modelwidth(10 20) title("Table 3A: Means and Differences for Quinoa Buyers and non-Quinoa Buyers for `j' Among Quinoa Consumers") replace
}

* Calculate Percentages of People who Consume Quinoa by Department

bysort year: gen obs_id_yr = _n

label variable obs_id "Observation ID number by Year"

order obs_id_yr

bysort year dep: gen obs_id_yr_dp = _n
label variable obs_id_yr_dp "Observation ID bumber by Year and Department"
order obs_id_yr_dp

* create a variable of the total number of people in the department
bysort year dep: egen total_pop_dp = count(obs_id_yr_dp)
bysort year dep: egen quin_cons_dp = sum(quin_cons)
gen quin_perc_dp = quin_cons_dp/total_pop_dp
replace quin_perc_dp = . if dep == "Peru"

* find the percentage of all peruvians who consume quinoa
bysort year: egen total_pop_per = count(obs_id_yr)
bysort year: egen quin_cons_per = sum(quin_cons)
bysort year: gen quin_perc_per = quin_cons_per/total_pop_per

* find the top 10 consuming quinoa departments
* generate a variable that sorts quin_perc_dp in descending order
gen asc_quin_perc_dp = - quin_perc_dp

* create a new variable that assigns the new variable a ranking within departments and years
sort year asc_quin_perc_dp obs_id_yr_dp
by year asc_quin_perc_dp obs_id_yr_dp: gen newid = 1 if obs_id_yr_dp == 1 & dep != "Peru"

log using "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Tables/cons_table.log", replace
forvalue j = 2004/2012 {
	replace newid = sum(newid) if year == `j' & dep != "Peru"
	
	* Now create a table showing the top 10 departments in year j
tabdisp newid if newid <= 10 & year == `j', c(year dep quin_perc_dp)
}

log close

drop newid

* find the top 10 producing quinoa departments
* generate a variable that sorts tonnage produced in descending order
gen asc_ton = - ton

* create a new variable that assigns the new variable a ranking within departments and years
sort year asc_ton obs_id_yr_dp
by year asc_ton obs_id_yr_dp: gen newid = 1 if obs_id_yr_dp == 1 & dep != "Peru"

log using "/Users/rtenorio/Google Drive/Ind Study Powerhouse/Tables/prod_table.log", replace
forvalue j = 2004/2012 {
	replace newid = sum(newid) if year == `j' & dep != "Peru"
	
* Now create a table showing the top 10 departments in year j
tabdisp newid if newid <= 10 & year == `j', c(year dep ton)
}

log close
drop newid










