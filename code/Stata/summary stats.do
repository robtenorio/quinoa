generate poor = 1 if poverty == 1 | poverty == 2
replace poor = 0 if poverty == 3

**summary statistics
tabstat agdummy hhearn tothhmem moinchhnet moexphh exphhgross poverty, by (treatment)
ttest agdummy, by(treatment)
ttest hhearn, by(treatment)
ttest tothhmem, by(treatment)
ttest moinchhnet, by(treatment)
ttest moexphh, by(treatment)
ttest exphhgross, by(treatment)
ttest poor, by(treatment)

ereturn list

estpost ttest agdummy hhearn tothhmem moinchhnet moexphh exphhgross poor, by(treatment)

esttab using sumstats.rtf, cell((mu_1(label(Non-Quinoa)) mu_2(label(Quinoa)) b(label(Difference)) se(par label(Standard Error)))) nonumber nomtitle coeflabel(agdummy "farmer" ///
hhearn "no. earners" tothhmem "no. members" moinchhnet "monthly net income" ///
moexphh "monthly expenditure" exphhgross "gross expenditure" poor "poor") ///
modelwidth(10 20) title("Table 1: Means and Differences for Departments that Produce Quinoa and Departments that Do Not") replace

tabstat earner_per_mem rural moexphh_def, by (quart)

estpost tabstat earner_per_mem rural moexphh_def, by (quart)
eststo

esttab using quart_tot_exp.rtf, nonumber nomtitle coeflabel(earner_per_mem "Income earners per total HH members" ///
rural "Dummy equals one for rural" moexphh_def "Total annualized HH expenditure deflated") ///
modelwidth(10 20) title("Table 11: Means of Deflated Total Annualized HH Expenditure Quartiles") replace
