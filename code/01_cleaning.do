clear all
set more off
capture log close
log using "cleaning.log", replace text

*=====================================================*
* 1. Import HPI (Nominal UK House Prices)
*=====================================================*
import excel using "HPI.xlsx", ///
    sheet("Table 15") cellrange(A3:J300) firstrow clear

keep if Region == "United Kingdom"
rename Period period
rename AlldwellingsPrice hpi_nominal

replace hpi_nominal = subinstr(hpi_nominal, ",", "", .)
replace hpi_nominal = "" if inlist(hpi_nominal, ".", "X", "N/A", "na", "NA", "…", "…")
destring hpi_nominal, replace force

gen qdate = quarterly(period, "YQ")
format qdate %tq
keep qdate hpi_nominal
keep if qdate >= yq(1992, 2)
tempfile hpi
save `hpi'

*=====================================================*
* 2. Import CPI (Index, 2015=100)
*=====================================================*
import delimited using "CPI.csv", clear

gen row = _n
keep if row >= 62 & row <= 193
drop row

rename v1 period
rename v2 cpi
replace cpi = subinstr(cpi, ",", "", .)
replace cpi = "" if inlist(cpi, ".", "N/A", "na", "NA", "…", "…")
destring cpi, replace force

gen qdate = quarterly(period, "YQ")
format qdate %tq
keep qdate cpi
keep if qdate >= yq(1992, 2)
tempfile cpi
save `cpi'

*=====================================================*
* 3. Import Bank Rate (Daily → Quarterly Avg)
*=====================================================*
import delimited using "bankrate.csv", clear
rename date rawdate
rename rate rate

gen start = date(rawdate, "YMD")
format start %td
sort start
gen end = start[_n+1] - 1
replace end = td(31dec2024) if missing(end)
keep if end >= td(01jan1992)

gen duration = end - start + 1
expand duration
bysort start (duration): gen date = start + _n - 1
format date %td

gen qdate = qofd(date)
format qdate %tq
collapse (mean) rate, by(qdate)
rename rate bank_rate
keep if qdate >= yq(1992, 2)
tempfile br
save `br'

*=====================================================*
* 4. Import Income (Real Disposable Income per Head)
*=====================================================*
import delimited using "income.csv", clear

gen row = _n
keep if row >= 227 & row <= 358
drop row

rename v1 period
rename v2 income_real
replace income_real = subinstr(income_real, ",", "", .)
replace income_real = "" if inlist(income_real, ".", "N/A", "na", "NA", "…", "…")
destring income_real, replace force

gen qdate = quarterly(period, "YQ")
format qdate %tq
keep qdate income_real
keep if qdate >= yq(1992, 2)
gen ln_income = ln(income_real)
tempfile inc
save `inc'

*=====================================================*
* 5. Import Completions (Housing Supply)
*=====================================================*
import excel using "completions.xlsx", ///
    sheet("1a") cellrange(B63:G194) clear

rename B period
rename G completions
drop C D E F

replace completions = subinstr(completions, ",", "", .)
replace completions = "" if inlist(completions, ".", "N/A", "na", "NA", "…", "…")
destring completions, replace force

gen year = real(substr(period, -4, 4))
gen qtr = .
replace qtr = 1 if strpos(period, "Jan") > 0
replace qtr = 2 if strpos(period, "Apr") > 0
replace qtr = 3 if strpos(period, "Jul") > 0
replace qtr = 4 if strpos(period, "Oct") > 0

gen qdate = yq(year, qtr)
format qdate %tq
keep qdate completions
keep if qdate >= yq(1992, 2)
gen ln_completions = ln(completions)
tempfile comp
save `comp'

*=====================================================*
* 6. Merge All Datasets by qdate
*=====================================================*
use `hpi', clear
merge 1:1 qdate using `cpi'
drop if _merge != 3
drop _merge

merge 1:1 qdate using `br'
drop if _merge != 3
drop _merge

merge 1:1 qdate using `inc'
drop if _merge != 3
drop _merge

merge 1:1 qdate using `comp'
drop if _merge != 3
drop _merge

*=====================================================*
* 7. Generate Real & Log Variables
*=====================================================*
gen hpi_real = hpi_nominal / cpi * 100
gen ln_hpi = ln(hpi_real)
gen ln_bank_rate = ln(bank_rate)

order qdate ln_hpi ln_bank_rate ln_income ln_completions ///
      hpi_nominal hpi_real bank_rate income_real completions cpi

*=====================================================*
* 8. Save Final Dataset
*=====================================================*
save "houseprices_clean.dta", replace
log close
