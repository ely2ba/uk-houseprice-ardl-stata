log using master_run.log, replace text
/***************************************************************************/
/* 1. CLEANING & DATA CONSTRUCTION */
/***************************************************************************/
display as text "=== 1. CLEANING ==="
*-------------------------------------------------*
* 1.1 Import nominal HPI *
*-------------------------------------------------*
import excel using "HPI.xlsx", ///
sheet("Table 15") cellrange(A3:J300) firstrow clear
keep if Region == "United Kingdom"
rename Period period
rename AlldwellingsPrice hpi_nominal
replace hpi_nominal = subinstr(hpi_nominal, ",", "", .)
replace hpi_nominal = "" if inlist(hpi_nominal, ".", "X", "N/A", "na", "NA",
"…")
destring hpi_nominal, replace force
gen qdate = quarterly(period, "YQ")
format qdate %tq
keep qdate hpi_nominal
keep if qdate >= yq(1992, 2)
tempfile hpi
save `hpi'
*-------------------------------------------------*
* 1.2 Import CPI *
*-------------------------------------------------*
import delimited using "CPI.csv", clear
gen row = _n
keep if inrange(row,62,193)
drop row
rename v1 period
rename v2 cpi
replace cpi = subinstr(cpi, ",", "", .)
replace cpi = "" if inlist(cpi,".","N/A","na","NA","…")
destring cpi, replace force
gen qdate = quarterly(period,"YQ")
format qdate %tq
keep qdate cpi
keep if qdate >= yq(1992, 2)
tempfile cpi
save `cpi'
*-------------------------------------------------*
* 1.3 Import Bank Rate (daily → quarterly mean) *
*-------------------------------------------------*
import delimited using "bankrate.csv", clear
rename date rawdate
rename rate rate
gen start = date(rawdate,"YMD")
format start %td
sort start
gen end = start[_n+1]-1
replace end = td(31dec2024) if missing(end)
keep if end >= td(01jan1992)
gen duration = end-start+1
expand duration
bysort start: gen date = start+_n-1
format date %td
gen qdate = qofd(date)
format qdate %tq
collapse (mean) rate, by(qdate)
rename rate bank_rate
keep if qdate >= yq(1992, 2)
tempfile br
save `br'
*-------------------------------------------------*
* 1.4 Import Real Disposable Income *
*-------------------------------------------------*
import delimited using "income.csv", clear
gen row=_n
keep if inrange(row,227,358)
drop row
rename v1 period
rename v2 income_real
replace income_real = subinstr(income_real,",","",.)
replace income_real = "" if inlist(income_real,".","N/A","na","NA","…")
destring income_real, replace force
gen qdate = quarterly(period,"YQ")
format qdate %tq
keep qdate income_real
keep if qdate >= yq(1992, 2)
gen ln_income = ln(income_real)
tempfile inc
save `inc'
*-------------------------------------------------*
* 1.5 Import Completions *
*-------------------------------------------------*
import excel using "completions.xlsx", ///
sheet("1a") cellrange(B63:G194) clear
rename B period
rename G completions
drop C D E F
replace completions = subinstr(completions,",","",.)
replace completions = "" if inlist(completions,".","N/A","na","NA","…")
destring completions, replace force
gen year = real(substr(period,-4,4))
gen qtr = .
replace qtr=1 if strpos(period,"Jan")>0
replace qtr=2 if strpos(period,"Apr")>0
replace qtr=3 if strpos(period,"Jul")>0
replace qtr=4 if strpos(period,"Oct")>0
gen qdate = yq(year,qtr)
format qdate %tq
keep qdate completions
keep if qdate >= yq(1992, 2)
gen ln_completions = ln(completions)
tempfile comp
save `comp'
*-------------------------------------------------*
* 1.6 Merge & create final dataset *
*-------------------------------------------------*/
use `hpi', clear
merge 1:1 qdate using `cpi', nogen
merge 1:1 qdate using `br', nogen
merge 1:1 qdate using `inc', nogen
merge 1:1 qdate using `comp',nogen
gen hpi_real = hpi_nominal/cpi*100
gen ln_hpi = ln(hpi_real)
gen ln_bank_rate = ln(bank_rate)
order qdate ln_hpi ln_bank_rate ln_income ln_completions ///
hpi_nominal hpi_real bank_rate income_real completions cpi
save "houseprices_clean.dta", replace
display as text " → houseprices_clean.dta saved."
/***************************************************************************/
/* 2. DESCRIPTIVE STATISTICS & FIGURES */
/***************************************************************************/
display as text "=== 2. DESCRIPTION ==="
use "houseprices_clean.dta", clear
tsset qdate
* Summary stats
estpost summarize ln_hpi ln_bank_rate ln_income ln_completions
esttab using output/Table1_SummaryStats.rtf, ///
cells("count mean sd min max") replace
* Correlation matrix
pwcorr ln_hpi ln_bank_rate ln_income ln_completions, sig
matrix C=r(C)
matrix colnames C = ln_hpi ln_bank_rate ln_income ln_completions
matrix rownames C = ln_hpi ln_bank_rate ln_income ln_completions
esttab matrix(C) using output/Table2_Correlation.rtf, replace
* Time-series plots
tsline ln_hpi ln_bank_rate ln_income ln_completions, ///
legend(order(1 "ln(HPI)" 2 "ln(Bank Rate)" 3 "ln(Income)" 4
"ln(Completions)") cols(2)) ///
title("Log-transformed variables, 1992Q2–2024Q4")
graph export figures/graph_combined_all_variables.png, replace
* Rolling variance figure
tssmooth ma roll_mean_hpi = ln_hpi, window(5)
gen roll_var_hpi = (ln_hpi-roll_mean_hpi)^2
tsline roll_var_hpi, title("Rolling variance of ln(HPI)") ytitle("Variance")
graph export figures/rolling_var_ln_hpi.png, replace
/***************************************************************************/
/* 3. STATIONARITY TESTS */
/***************************************************************************/
display as text "=== 3. STATIONARITY ==="
log using stationarity.log, replace text
foreach v in ln_hpi ln_bank_rate ln_income ln_completions {
display "ADF: `v'"
dfuller `v', lags(4) trend
dfuller D.`v', lags(4) trend
display "PP: `v'"
pperron `v', trend
pperron D.`v', trend
}
log close
/***************************************************************************/
/* 4. ARDL MODEL & BOUNDS TEST */
/***************************************************************************/
display as text "=== 4. MODEL ==="
use "houseprices_clean.dta", clear
tsset qdate
keep if !missing(ln_hpi ln_bank_rate ln_income ln_completions)
ardl ln_hpi ln_bank_rate ln_income ln_completions, lags(1/4) ec
esttab using output/ARDL_Core.rtf, replace
estat ectest
estat ic
estat ovtest
* Calculate long-run multipliers (only if cointegration confirmed; kept for
reference)
capture confirm matrix e(b)
if !_rc {
nlcom (_longrun_rate: _b[LR:ln_bank_rate] / -_b[ADJ:L.ln_hpi])
nlcom (_longrun_income: _b[LR:ln_income] / -_b[ADJ:L.ln_hpi])
nlcom (_longrun_complete: _b[LR:ln_completions] / -_b[ADJ:L.ln_hpi])
}
/***************************************************************************/
/* 5. DIAGNOSTICS, WALD, VIF, ROBUSTNESS */
/***************************************************************************/
display as text "=== 5. DIAGNOSTICS ==="
* Robust SE re-estimate
reg D.ln_hpi L.ln_hpi ///
D.ln_bank_rate L.D.ln_bank_rate ///
D.ln_income L.D.ln_income L2.D.ln_income ///
D.ln_completions L.D.ln_completions L2.D.ln_completions
L3.D.ln_completions, ///
vce(robust)
esttab using output/ARDL_Robust.rtf, replace
* Wald test
test D.ln_bank_rate L.D.ln_bank_rate
* VIF
vif
estpost vif
esttab using output/VIF_Table.rtf, replace cells("vif(fmt(2))")
* Serial correlation & heterosk.
estat bgodfrey, lags(1)
estat bgodfrey, lags(4)
dwstat
estat hettest
* Normality
predict resid_ardl, residuals
swilk resid_ardl
/* --- Robustness: COVID & GFC dummies --- */
gen covid = inrange(qdate, yq(2020,1), yq(2021,4))
gen gfc = inrange(qdate, yq(2008,4), yq(2009,4))
reg D.ln_hpi L.ln_hpi ///
D.ln_bank_rate L.D.ln_bank_rate ///
D.ln_income L.D.ln_income L2.D.ln_income ///
D.ln_completions L.D.ln_completions L2.D.ln_completions
L3.D.ln_completions ///
covid gfc, vce(robust)
esttab using output/Robustness_Dummies.rtf, replace
/***************************************************************************/
log close
display as text "=== ALL STEPS FINISHED. Tables in /output, figs in
/figures. ==="
/***************************************************************************/
