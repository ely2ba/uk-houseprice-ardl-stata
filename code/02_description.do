clear all
set more off
capture log close
log using "descriptive_v2.log", replace text

*=====================================================*
* 1. Load Dataset
*=====================================================*
use "houseprices_clean.dta", clear
tsset qdate

*=====================================================*
* 2. Summary Statistics
*=====================================================*
summarize ln_hpi ln_bank_rate ln_income ln_completions

*=====================================================*
* 3. Correlation Matrix
*=====================================================*
correlate ln_hpi ln_bank_rate ln_income ln_completions

*=====================================================*
* 4. Time Series Plots
*=====================================================*
tsline ln_hpi, title("Log Real House Price Index") ytitle("ln(HPI)")
graph export "graph_ln_hpi.png", replace

tsline ln_bank_rate, title("Log Bank Rate") ytitle("ln(Bank Rate)")
graph export "graph_ln_bank_rate.png", replace

tsline ln_income, title("Log Real Disposable Income") ytitle("ln(Income)")
graph export "graph_ln_income.png", replace

tsline ln_completions, title("Log Housing Completions") ytitle("ln(Completions)")
graph export "graph_ln_completions.png", replace

*=====================================================*
* 5. Combined Plot
*=====================================================*
twoway (tsline ln_hpi, lcolor(blue)) ///
       (tsline ln_bank_rate, lcolor(red)) ///
       (tsline ln_income, lcolor(green)) ///
       (tsline ln_completions, lcolor(orange)), ///
       legend(label(1 "ln(HPI)") label(2 "ln(Bank Rate)") ///
              label(3 "ln(Income)") label(4 "ln(Completions)")) ///
       title("Key Variables Over Time") xtitle("Quarter")
graph export "graph_combined_all_variables.png", replace

*=====================================================*
* 6. First Differences
*=====================================================*
gen d_ln_hpi = D.ln_hpi
gen d_ln_bank_rate = D.ln_bank_rate
gen d_ln_income = D.ln_income
gen d_ln_completions = D.ln_completions

tsline d_ln_hpi, title("Δ ln(HPI)")
graph export "graph_d_ln_hpi.png", replace

tsline d_ln_bank_rate, title("Δ ln(Bank Rate)")
graph export "graph_d_ln_bank_rate.png", replace

tsline d_ln_income, title("Δ ln(Income)")
graph export "graph_d_ln_income.png", replace

tsline d_ln_completions, title("Δ ln(Completions)")
graph export "graph_d_ln_completions.png", replace

*=====================================================*
* 7. Histograms + Kernel Densities
*=====================================================*
histogram ln_hpi, normal title("Histogram: ln(HPI)")
graph export "hist_ln_hpi.png", replace

kdensity ln_hpi, title("Density: ln(HPI)")
graph export "density_ln_hpi.png", replace

histogram ln_income, normal title("Histogram: ln(Income)")
graph export "hist_ln_income.png", replace

kdensity ln_income, title("Density: ln(Income)")
graph export "density_ln_income.png", replace

histogram ln_bank_rate, normal title("Histogram: ln(Bank Rate)")
graph export "hist_ln_bank_rate.png", replace

kdensity ln_bank_rate, title("Density: ln(Bank Rate)")
graph export "density_ln_bank_rate.png", replace

histogram ln_completions, normal title("Histogram: ln(Completions)")
graph export "hist_ln_completions.png", replace

kdensity ln_completions, title("Density: ln(Completions)")
graph export "density_ln_completions.png", replace

*=====================================================*
* 8. Boxplots
*=====================================================*
graph box ln_hpi ln_income ln_bank_rate ln_completions, ///
    title("Boxplots: Log Transformed Variables")
graph export "boxplots_all_variables.png", replace

*=====================================================*
* 9. Autocorrelation Plots (ACF)
*=====================================================*
ac ln_hpi, title("ACF: ln(HPI)")
graph export "acf_ln_hpi.png", replace

ac ln_income, title("ACF: ln(Income)")
graph export "acf_ln_income.png", replace

ac ln_bank_rate, title("ACF: ln(Bank Rate)")
graph export "acf_ln_bank_rate.png", replace

ac ln_completions, title("ACF: ln(Completions)")
graph export "acf_ln_completions.png", replace

*=====================================================*
* 10. Rolling Mean and Variance
*=====================================================*
tssmooth ma roll_mean_hpi = ln_hpi, window(5)
gen roll_var_hpi = (ln_hpi - roll_mean_hpi)^2

tsline ln_hpi roll_mean_hpi, ///
    title("Rolling Mean of ln(HPI) (5-Quarter MA)") ///
    legend(order(1 "ln(HPI)" 2 "Rolling Mean"))
graph export "rolling_mean_ln_hpi.png", replace

tsline roll_var_hpi, title("Rolling Variance of ln(HPI)") ytitle("Variance")
graph export "rolling_var_ln_hpi.png", replace

log close
