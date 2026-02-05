# RegPulse – Regulatory Risk Tracker (R)

RegPulse is a small R project that converts regulatory updates into a structured change log for risk and compliance review.

It maps each update to a defined risk taxonomy, tags common obligation types (e.g. reporting, governance, record keeping), and assigns a simple, explainable impact score.

## Why this project
Regulatory change arrives as long, unstructured text. This project demonstrates a transparent workflow for turning that text into prioritised, auditable signals.

## Outputs
- `outputs/change_log.csv` – taxonomy-mapped change log with obligation tags and an impact score

## How it works
1. Read metadata and raw text files from `data/raw/`
2. Apply keyword-based mapping using `taxonomy/risk_taxonomy.csv`
3. Identify obligation tags from `taxonomy/obligation_tags.csv`
4. Score impact using clear severity cues (e.g. “must”, “deadline”)
5. Write the change log to `outputs/`

## Run
Open the project in RStudio and run:
- `R/02_taxonomy_map.R`

## Notes / limitations
This is intentionally simple and explainable (rules + taxonomy), prioritising traceability over automation.
## Regulators covered
- Central Bank of Ireland (CBI)
- European Banking Authority (EBA)
- European Securities and Markets Authority (ESMA)
