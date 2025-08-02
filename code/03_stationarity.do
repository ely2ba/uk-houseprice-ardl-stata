clear all
set more off
capture log close
log using "stationarity.log", replace text

*=====================================================*
* 1. Load Dataset
*=====================================================*
use "houseprices_clean.dta", clear
tsset qdate

*=====================================================*
* 2. ADF Tests (Augmented Dickey-Fuller)
*=====================================================*
display "=== ADF Tests at Levels ==="
dfuller ln_hpi, lags(4) trend
dfuller ln_bank_rate, lags(4) trend
dfuller ln_income, lags(4) trend
dfuller ln_completions, lags(4) trend

display "=== ADF Tests at First Differences ==="
dfuller D.ln_hpi, lags(4) trend
dfuller D.ln_bank_rate, lags(4) trend
dfuller D.ln_income, lags(4) trend
dfuller D.ln_completions, lags(4) trend

*=====================================================*
* 3. Phillips-Perron Tests (for robustness)
*=====================================================*
display "=== Phillips-Perron Tests at Levels ==="
pperron ln_hpi, trend
pperron ln_bank_rate, trend
pperron ln_income, trend
pperron ln_completions, trend

display "=== Phillips-Perron Tests at First Differences ==="
pperron D.ln_hpi, trend
pperron D.ln_bank_rate, trend
pperron D.ln_income, trend
pperron D.ln_completions, trend


log close
