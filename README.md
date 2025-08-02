# uk-houseprice-ardl-stata
A self-designed, fully reproducible Stata workflow for an ARDL time-series analysis of UK house-price growth (1992 Q2 – 2024 Q4). I chose the research question independently and collected all raw data myself as part of my MSc Econometrics coursework.


# UK House-Price Dynamics (1992 Q2 – 2024 Q4)

*A fully reproducible Stata workflow for my MSc Econometrics coursework*

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md) 
[![Stata 18](https://img.shields.io/badge/Stata-17%2F18-lightgrey)](https://www.stata.com)

---

## 1 Motivation & Research Question

Real UK house prices have **tripled since the early-1990s recession**, yet the relative importance of income, financing costs and new supply remains contested:

| Theme                  | Mixed evidence                                 |
| ---------------------- | ---------------------------------------------- |
| **Income pressure**    | Hilber & Vermeulen (2016)                      |
| **Rate pass-through**  | Adams et al. (2022) find it weakened post-2008 |
| **Supply constraints** | Cheshire & Hilber (2021)                       |

> **Question:** *How do quarterly changes in real disposable income ( Y ), the Bank Rate ( r ), and housing completions ( S ) affect real UK house-price growth ( H ), and is there a long-run equilibrium binding them together?*

---

## 2 Data

| Series (log)                    | Source                        | Notes                              |
| ------------------------------- | ----------------------------- | ---------------------------------- |
| House-Price Index (HPI)         | ONS – Table 15                | CPI-deflated & seasonally adjusted |
| Bank Rate                       | BoE – IUDERB4                 | Daily → quarterly mean             |
| Real disposable income per head | ONS QNA                       | Chain-linked £2022                 |
| Housing completions             | ONS – House Building Table 1a | National total                     |

*Sample:* **1992 Q2 – 2024 Q4** (131 obs.; completions: 123)

> **Get the data**
>
> * Direct download links are listed at the bottom of this file.
> * If you just want to run the code, place the raw files in **`data/raw/`** and skip the download.

---

## 3 Method in 60 seconds

1. **Integration order:** ADF & PP tests → all variables are I(1).
2. **Cointegration check:** Pesaran bounds test → F = 0.72 < CV ⇒ *no* cointegration.
3. **Short-run model:** ARDL (1, 2, 3, 4) on Δln HPI with robust (Huber–White) SEs.
4. **Diagnostics:** RESET, BG-LM, Breusch–Pagan, Shapiro–Wilk, VIF → model well-specified.
5. **Robustness:** COVID & GFC dummies; Bank-Rate Wald test.

---

## 4 Key Results

| Driver (Δ log)        | Coefficient | p-value      | Interpretation                                      |
| --------------------- | ----------- | ------------ | --------------------------------------------------- |
| **Income (t-1)**      | **0.73**    | 0.009        | +1 % income → **+0.73 pp** HPI growth next quarter  |
| **Completions (t-3)** | 0.12        | 0.002        | Supply tempers prices **after three quarters**      |
| **Bank-Rate terms**   | —           | 0.44 (joint) | No short-run effect once income & supply controlled |

**How this lines up with the literature**

| Finding                     | Alignment                                                                                        |
| --------------------------- | ------------------------------------------------------------------------------------------------ |
| Income elasticity (0.73)    | Between Faccini & Hackworth (0.4, 2010–22) and Hilber & Vermeulen (\~1.0 in constrained regions) |
| Positive supply coefficient | Consistent with Cheshire & Hilber – completions cluster where demand is already strong           |
| Muted rate channel          | Matches Adams et al. – post-2008 fixed-rate mortgages & QE dampen pass-through                   |

---

## 5 Repo Structure

```
uk-house-price-ardl-analysis/
├── code/            # Stata .do files (01_… to master_run.do)
├── data/
│   ├── raw/         # Raw ONS & BoE files  ← put downloads here
│   └── clean/       # Generated houseprices_clean.dta
├── figures/         # PNG charts
├── logs/            # Stata run logs
├── output/          # Tables (.rtf)
├── LICENSE.md
├── .gitignore
└── README.md
```

---

## 6 Replicate in Two Steps

1. **Clone the repo**

   ```bash
   git clone [https://github.com/ely2ba/uk-houseprice-ardl-stata.git]
   cd uk-house-price-ardl-stata
   ```
2. **Run the master script in Stata 17/18**

   ```stata
   * if needed: ssc install estout
   do code/master_run.do
   ```

Everything—cleaned data, tables, figures, logs—recreates in ≤ 30 s.

---

## 7 Limitations & Next Steps

* **Rate proxy:** Bank Rate ≠ effective mortgage rate → future work will use quoted fixed-rate series.
* **Regime shifts:** Break tests (pre/post-2008) may reveal time-varying elasticities.
* **Regional heterogeneity:** London vs. Rest-of-UK split could clarify the supply sign.

---

## 8 Raw Data Links

*(all open-data under the UK Open Government Licence)*

* UK House-Price Index – Table 15: [https://www.ons.gov.uk/](https://www.ons.gov.uk/)
* Bank Rate (IUDERB4): [https://www.bankofengland.co.uk/](https://www.bankofengland.co.uk/)
* CPI (CZBH) & Real Disposable Income: [https://www.ons.gov.uk/](https://www.ons.gov.uk/)
* Housing Completions – Table 1a: [https://www.ons.gov.uk/](https://www.ons.gov.uk/)

---

## 9 How to Cite

```text
Cheikh, E. (2025). UK House-Price Dynamics (1992–2024): An ARDL Analysis. GitHub repository.
```

---

## 10 License

Released under the **MIT License** – see `LICENSE.md`.

---

## 11 Contact

Questions or suggestions welcome!
📧 founder@taci.ai | 🔗 (https://www.linkedin.com/in/ely2ch/)

---

*Last updated: May 2025*
