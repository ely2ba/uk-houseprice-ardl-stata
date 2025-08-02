
# UK House-Price Dynamics, 1992 Q2 – 2024 Q4  
*This project was developed independently for my ECM314 Econometrics coursework, where I selected the research question, sourced the data, and carried out the full analysis workflow using Stata.*

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)&nbsp;
[![Stata 18](https://img.shields.io/badge/Stata-17%2F18-lightgrey)](https://www.stata.com)

---

## 1 Motivation & Research Question  
Real UK house prices have **tripled since the early-1990s recession**, yet the roles of income, financing costs and new supply remain contested.

| Theme | Mixed evidence |
|-------|----------------|
| **Income pressure** | Hilber & Vermeulen (2016) |
| **Rate pass-through** | Adams et al. (2022) find it weakened post-2008 |
| **Supply constraints** | Cheshire & Hilber (2021) |

> **Question:** *How do quarterly changes in real disposable income ( Y ), the Bank Rate ( r ), and housing completions ( S ) affect real UK house-price growth ( H ), and is there a long-run equilibrium binding them together?*

---

## 2 Data  
| Series (log) | Source | Notes |
|--------------|--------|-------|
| House-Price Index (HPI) | ONS – Table 15 | CPI-deflated, seasonally adjusted |
| Bank Rate | BoE – IUDERB4 | Daily → quarterly mean |
| Real disposable income per head | ONS QNA | Chain-linked £2022 |
| Housing completions | ONS – House Building Table 1a | National total |

**Sample:** 1992 Q2 – 2024 Q4 (131 quarters; completions 123)  

*Approx. download size: ~5 MB*

> **Get the data:**  
> • Direct links are in § 8.  
> • If you only want to run the code, drop the raw files into **`data/raw/`** and skip the download.

---

## 3 Method in 60 s  
* **Integration order:** ADF & PP → all variables are **I(1)**  
* **Cointegration check:** Pesaran bounds test → F = 0.72 < 2.72 ⇒ *no* cointegration  
* **Short-run model:** ARDL (1, 2, 3, 4) on Δ ln HPI with Huber-White SEs  
* **Diagnostics:** RESET p = 0.67, BG-LM(1) p = 0.98, **BG-LM(4) detects seasonal AR but is absorbed by the four lags**, Breusch–Pagan p = 0.08 → robust SEs, Shapiro–Wilk p = 0.36, VIF < 5 → model sound  
* **Robustness:** COVID-19 (2020-21) & GFC (2008-09) dummies leave elasticities unchanged; Wald test on Bank-Rate lags (F = 0.82, p = 0.44)

---

## 4 Key Results  
| Driver (Δ log) | Coefficient | p-value | Interpretation |
|----------------|-------------|---------|----------------|
| **Income (t-1)** | **0.73** | 0.009 | +1 % income → **+0.73 pp** HPI growth next quarter |
| **Completions (t-3)** | 0.12 | 0.002 | New supply tempers prices **after three quarters** |
| **Bank-Rate lags** | — | 0.44 (joint) | No short-run effect once income & supply included |

*Joint Wald: F(2, 104) = 0.82, p = 0.44*

---

### How this fits prior work  
| Finding | Alignment |
|---------|-----------|
| Income elasticity 0.73 | Between Faccini & Hackworth (0.4, 2010-22) and Hilber & Vermeulen (~1.0 in constrained regions) |
| Positive supply sign | Mirrors Cheshire & Hilber – completions cluster in high-demand areas |
| Muted rate channel | Matches Adams et al. – post-2008 fixed-rate mortgages & QE blunt pass-through |

---

## 5 Repo Structure
```

uk-houseprice-ardl-stata/
├── code/            # Stata .do files (01\_… to master\_run.do)
├── data/
│   ├── raw/         # Raw ONS & BoE files  ← put downloads here
│   └── clean/       # Generated houseprices\_clean.dta
├── figures/         # PNG charts
├── logs/            # Stata run logs
├── output/          # Tables (.rtf)
├── LICENSE.md
├── .gitignore
└── README.md

````

---

## 6 Replicate in Two Steps
```bash
# 1 Clone
git clone https://github.com/ely2ba/uk-houseprice-ardl-stata.git
cd uk-houseprice-ardl-stata

# 2 Run in Stata 17/18
* if needed: ssc install estout
do code/master_run.do
````

Cleaned data, tables, figures and logs regenerate in ≤ 30 s.

---

## 7 Limitations & Next Steps

* **Rate proxy:** Bank Rate ≠ effective mortgage rate → future work will use quoted fixed-rate series.
* **Regime shifts:** Structural-break ARDL may reveal pre-/post-2008 parameter changes.
* **Regional heterogeneity:** London vs. Rest-of-UK split could clarify the positive supply sign.

---

## 8 Raw Data Links

*(all under the UK Open Government Licence)*

* UK HPI – Table 15 [https://www.ons.gov.uk/](https://www.ons.gov.uk/)
* CPI (CZBH) & Real Income [https://www.ons.gov.uk/](https://www.ons.gov.uk/)
* Housing Completions – Table 1a [https://www.ons.gov.uk/](https://www.ons.gov.uk/)
* Bank Rate (IUDERB4) [https://www.bankofengland.co.uk/](https://www.bankofengland.co.uk/)

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
📧 [founder@taci.ai](mailto:founder@taci.ai) | 🔗 [https://www.linkedin.com/in/ely2ch/](https://www.linkedin.com/in/ely2ch/)

*Last updated: May 2025*

