clear all
set more off
capture log close
log using "model.log", replace text

*=====================================================*
* 1. Load Cleaned Data
*=====================================================*
use "houseprices_clean.dta", clear
tsset qdate

* Ensure no missing values for full model sample
keep if !missing(ln_hpi, ln_bank_rate, ln_income, ln_completions)

*=====================================================*
* 2. ARDL Estimation with max lag 4 (1 year)
*=====================================================*
* Feel free to test with other lags later for BIC minimization
ardl ln_hpi ln_bank_rate ln_income ln_completions, lags(1/4) ec

*=====================================================*
* 3. Bounds Cointegration Test
*=====================================================*
estat ectest

* If F-stat > upper critical value → cointegration confirmed

*=====================================================*
* 4. Calculate Long-Run Coefficients (manually using nlcom)
*=====================================================*
* If cointegration exists, compute long-run effects as:
* LR_X = β_X / -α (lagged dependent var)

nlcom (_longrun_rate:     _b[LR:ln_bank_rate] / -_b[ADJ:L.ln_hpi])
nlcom (_longrun_income:   _b[LR:ln_income] / -_b[ADJ:L.ln_hpi])
nlcom (_longrun_complete: _b[LR:ln_completions] / -_b[ADJ:L.ln_hpi])


*=====================================================*
* 5. Model Fit & Specification Tests
*=====================================================*
estat ic          // AIC, BIC
estat ovtest      // Ramsey RESET test (non-linearity check)

* Optional: residuals for next stage
predict resid_ardl, residuals
predict fitted_ardl, xb

log close
