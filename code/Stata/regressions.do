
set more off

use "master.dta", clear


* NOW TEST ENGEL WITH TOTAL EXPENDITURE FOR ALL FOOD
* first see if Engel's law holds for non-producers
reg ln_totan_fexp_def ln_moexphh_def rural earner_per_mem ///
if producer != 1 [pweight=factor07], robust

/* now test for homothetic preferences by seeing if Engel's law holds for different
expenditure quantiles */

* test engel's law by quartile of households by expenditure
forvalues quartile = 1/4 {
	reg ln_totan_fexp ln_moexphh_def rural earner_per_mem ///
	if producer != 1 & quart == `quartile' [pweight=factor07], robust
	estimate store engel_a1_quartile_`quartile'
	}

esttab engel_a1_quartile_1 engel_a1_quartile_2 engel_a1_quartile_3 engel_a1_quartile_4 using "Engel_A1.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 3: Engel Estimation For All Foods Expenditure") nonumbers ///
keep(ln_moexphh_def rural earner_per_mem) coeflabels(moexphh_def "def. HH annual exp." rural "rural=1" earner_per_mem "proportion of HH earners to members") ///
mtitle("1st Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile") label replace

* NOW TEST ENGEL WITH A SHARE OF EXPENDITURE FOR ALL FOOD 

* first see if Engel's law holds for non-producers
reg totan_fexp_per_texp_def ln_moexphh_def rural earner_per_mem ///
if producer != 1 [pweight=factor07], robust

/* now test for homothetic preferences by seeing if Engel's law holds for different
expenditure quantiles */

* test engel's law by quartile of households by expenditure
forvalues quartile = 1/4 {
	reg totan_fexp_per_texp_def ln_moexphh_def rural earner_per_mem ///
	if producer != 1 & quart == `quartile' [pweight=factor07], robust
	estimate store engel_a2_quartile_`quartile'
	}
	
esttab engel_a2_quartile_1 engel_a2_quartile_2 engel_a2_quartile_3 engel_a2_quartile_4 using "Engel_A2.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 4: Engel Estimation For Food Expenditure as Share of Total Expenditure") nonumbers ///
keep(ln_moexphh_def rural earner_per_mem) coeflabels(ln_moexphh_def "ln of def. HH annual exp." rural "rural=1" earner_per_mem "proportion of HH earners to members") ///
mtitle("1st Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile") label replace


****************************
* NOW DO ABOVE WITH QUINOA *
****************************


* NOW TEST ENGEL WITH TOTAL EXPENDITURE FOR QUINOA
* first see if Engel's law holds for non-producers
reg ln_quinoa_tot_an_exp_def ln_totan_fexp_def rural earner_per_mem ///
if quinoa_producer != 1 [pweight=factor07], robust

/* now test for homothetic preferences by seeing if Engel's law holds for different
expenditure quantiles */

* test engel's law by quartile of households by food basket expenditure
forvalues quartile = 1/4 {
	reg ln_quinoa_tot_an_exp_def ln_totan_fexp_def rural earner_per_mem  ///
	if quinoa_producer != 1 & quart_fbasket == `quartile' [pweight=factor07], robust
	estimate store engel_q1_quartile_`quartile'
	}
	
esttab engel_q1_quartile_1 engel_q1_quartile_2 engel_q1_quartile_3 engel_q1_quartile_4 using "Engel_Q1.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 6: Engel Estimation For Quinoa Expenditure") nonumbers ///
keep(ln_totan_fexp_def rural earner_per_mem) coeflabels(totan_fexp_def "def. HH annual exp. on 48 foods basket" rural "rural=1" earner_per_mem "proportion of HH earners to members") ///
mtitle("1st Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile") label replace


* NOW TEST ENGEL WITH A SHARE OF EXPENDITURE FOR QUINOA

* quinoa consumption as proportion of total basket expenditure
reg quinoa_per_totan_fexp ln_totan_fexp_def rural earner_per_mem ///
if quinoa_producer != 1 [pweight=factor07], robust

/* now test for homothetic preferences by seeing if Engel's law holds for different
expenditure quantiles */

* examine quinoa per total consumption by quartile of households by food basket expenditure
forvalues quartile = 1/4 {
	reg quinoa_per_totan_fexp ln_totan_fexp_def rural earner_per_mem ///
	if quinoa_producer != 1 & quart_fbasket == `quartile' [pweight=factor07], robust
	estimate store engel_q2_quartile_`quartile'
	}

esttab engel_q2_quartile_1 engel_q2_quartile_2 engel_q2_quartile_3 engel_q2_quartile_4 using "Engel_Q2.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 7: Engel Estimation For Quinoa Expenditure as Share of Total Food Basket Expenditure") nonumbers ///
keep(ln_totan_fexp_def rural earner_per_mem) coeflabels(ln_totan_fexp_def "ln of def. HH annual exp. on 48 foods basket" rural "rural=1" earner_per_mem "proportion of HH earners to members") ///
mtitle("1st Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile") label replace



****************************************************************************************
* NOW DO ABOVE WITH QUINOA AND USING TOTAL HH EXPENDITURE AS THE INDEPENDENT REGRESSOR *
****************************************************************************************


* NOW TEST ENGEL WITH TOTAL EXPENDITURE FOR QUINOA
* first see if Engel's law holds for non-producers
reg ln_quinoa_tot_an_exp_def ln_moexphh_def rural earner_per_mem ///
if quinoa_producer != 1 [pweight=factor07], robust

/* now test for homothetic preferences by seeing if Engel's law holds for different
expenditure quantiles */

* test engel's law by quartile of households by food basket expenditure
forvalues quartile = 1/4 {
	reg ln_quinoa_tot_an_exp_def ln_moexphh_def rural earner_per_mem  ///
	if quinoa_producer != 1 & quart_fbasket == `quartile' [pweight=factor07], robust
	estimate store engel_q1_quartile_`quartile'
	}
	
esttab engel_q1_quartile_1 engel_q1_quartile_2 engel_q1_quartile_3 engel_q1_quartile_4 using "Engel_Q1a.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 6: Engel Estimation For Quinoa Expenditure") nonumbers ///
keep(ln_moexphh_def rural earner_per_mem) coeflabels(ln_moexphh_def "def. HH total annualized HH exp." rural "rural=1" earner_per_mem "proportion of HH earners to members") ///
mtitle("1st Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile") label replace


* NOW TEST ENGEL WITH A SHARE OF EXPENDITURE FOR QUINOA

* quinoa consumption as proportion of total basket expenditure
reg quinoa_per_totan_fexp ln_moexphh_def rural earner_per_mem ///
if quinoa_producer != 1 [pweight=factor07], robust

/* now test for homothetic preferences by seeing if Engel's law holds for different
expenditure quantiles */

* examine quinoa per total consumption by quartile of households by food basket expenditure
forvalues quartile = 1/4 {
	reg quinoa_per_totan_fexp ln_moexphh_def rural earner_per_mem ///
	if quinoa_producer != 1 & quart_fbasket == `quartile' [pweight=factor07], robust
	estimate store engel_q2_quartile_`quartile'
	}

esttab engel_q2_quartile_1 engel_q2_quartile_2 engel_q2_quartile_3 engel_q2_quartile_4 using "Engel_Q2a.rtf", nogaps lines se ///
stats(r2 N) title(\b "Table 7: Engel Estimation For Quinoa Expenditure as Share of Total Food Basket Expenditure") nonumbers ///
keep(ln_moexphh_def rural earner_per_mem) coeflabels(ln_moexphh_def "ln of def. total annualized HH exp." rural "rural=1" earner_per_mem "proportion of HH earners to members") ///
mtitle("1st Quartile" "2nd Quartile" "3rd Quartile" "4th Quartile") label replace













