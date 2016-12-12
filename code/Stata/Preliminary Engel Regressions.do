*** Engel Curve Regressions ***
log using "preliminary.log", replace
set more off

* first see if Engel's law holds
reg food_per_tot_exp ln_moexphh ln_moexphh_sq agdummy rural tothhmem, robust

* expenditure as independent variable by poverty status
reg food_per_tot_exp ln_moexphh ln_moexphh_sq agdummy rural tothhmem extreme_poor poor not_poor [pweight=factor07], robust noconstant

* income as independent variable by poverty status
reg food_per_tot_exp ln_moinchh ln_moinchh_sq agdummy rural tothhmem extreme_poor poor not_poor [pweight=factor07], robust noconstant

* Quinoa expenditure in soles as the dependent variable
reg quin_tot_an_exp ln_moexphh ln_moexphh_sq agdummy rural tothhmem all_poor [pweight=factor07], robust

* Quinoa expenditure in soles as the dependent variable w/income as an independent variable
reg quin_tot_an_exp ln_moinchh ln_moinchh_sq agdummy rural tothhmem all_poor [pweight=factor07], robust

* Quinoa expenditure as a proportion of total food expenditure
reg quin_per_texp ln_moexphh ln_moexphh_sq agdummy rural tothhmem all_poor [pweight=factor07], robust

* Quinoa expenditure as a proportion of total expenditure
reg quin_per_mexp ln_moexphh ln_moexphh_sq agdummy rural tothhmem all_poor [pweight=factor07], robust

* Quinoa expenditure as the dependent variable with other food expenditure
reg quin_tot_an_exp ln_moexphh ln_moexphh_sq agdummy rural tothhmem all_poor *_tot_an_exp [pweight=factor07], robust

* Quinoa expenditure as a proportion of total food expenditure with other food expenditure proportions
reg quin_per_texp ln_moexphh ln_moexphh_sq agdummy rural tothhmem all_poor *_per_totan_fexp [pweight=factor07], robust

* Quinoa expenditure as a proportion of total expenditure with other food expenditure proportions
reg quin_per_mexp ln_moexphh ln_moexphh_sq agdummy rural tothhmem all_poor *_per_totan_texp [pweight=factor07], robust

****************
* Rank 3 Model *
****************

gen ln_moexphh_inv = 1/ln_moexphh

gen ln_moinchh_inv = 1/ln_moinchh

* Quinoa expenditure in soles as the dependent variable
reg quin_tot_an_exp ln_moexphh ln_moexphh_sq ln_moexphh_inv agdummy rural tothhmem all_poor [pweight=factor07], robust

* Quinoa expenditure in soles as the dependent variable w/income as an independent variable
reg quin_tot_an_exp ln_moinchh ln_moinchh_sq ln_moinchh_inv agdummy rural tothhmem all_poor [pweight=factor07], robust

* Quinoa expenditure as a proportion of total food expenditure
reg quin_per_texp ln_moexphh ln_moexphh_sq ln_moexphh_inv agdummy rural tothhmem all_poor [pweight=factor07], robust

* Quinoa expenditure as a proportion of total expenditure
reg quin_per_mexp ln_moexphh ln_moexphh_sq ln_moexphh_inv agdummy rural tothhmem all_poor [pweight=factor07], robust

* Quinoa expenditure as the dependent variable with other food expenditure
reg quin_tot_an_exp ln_moexphh ln_moexphh_sq ln_moexphh_inv agdummy rural tothhmem all_poor *_tot_an_exp [pweight=factor07], robust

* Quinoa expenditure as a proportion of total food expenditure with other food expenditure proportions
reg quin_per_texp ln_moexphh ln_moexphh_sq ln_moexphh_inv agdummy rural tothhmem all_poor *_per_totan_fexp [pweight=factor07], robust

* Quinoa expenditure as a proportion of total expenditure with other food expenditure proportions
reg quin_per_mexp ln_moexphh ln_moexphh_sq ln_moexphh_inv agdummy rural tothhmem all_poor *_per_totan_texp [pweight=factor07], robust



log close








