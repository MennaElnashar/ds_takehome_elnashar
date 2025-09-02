# Data Science Take-Home — Procurement & Supply Analytics

This repository contains my submission for the Data Science Take-Home Exercise.
The project covers exploratory data analysis, late delivery prediction, price anomaly detection, and SQL-based analytics using a real-world style procurement and supply dataset.

📂 Repository Structure
```text
ds_takehome_full_package_extracted/
│
├── autograde_metrics.py            # Script for automated grading/evaluation
├── exercise.db                     # SQLite database file
├── README.md                       # Main project documentation
├── REPORT.md                       # Report of findings/analysis
├── requirements.txt                # Python dependencies
├── update_requirements.py           # Script to update requirements file
│
├── dataset/                        # Raw datasets provided for the exercise
│   ├── deliveries.csv
│   ├── predictions.csv             # Predictions from Model_Anomaly.ipynb
│   ├── price_lists.csv
│   ├── products.csv
│   ├── purchase_orders.csv
│   └── suppliers.csv
│
├── notebooks/                      # Jupyter notebooks for exploration & modeling
│   ├── EDA.ipynb                   # Exploratory Data Analysis & Data Quality checks
│   └── Model_Anomaly.ipynb         # Late Delivery Prediction + Price Anomaly Detection
│
└── sql/                            # SQL-based exercise and outputs
    ├── all_tasks_output.csv        # Results exported from SQL queries
    └── sql_exercise.sql            # SQL queries for the exercise
```

🚀 How to Run
1. Setup Environment
Clone the repo and install the required dependencies:
```bash
git clone <repo-url>
cd ds_takehome_full_package_extracted
pip install -r requirements.txt
```
>Requires Python 3.10+.

2. Explore the Notebooks
```text
EDA.ipynb → Join data, assess quality, generate visuals, and prepare features.

Model_Anomaly.ipynb → Train/evaluate late delivery prediction model and run price anomaly detection.
```
>To run:
```bash
jupyter notebook notebooks/EDA.ipynb
jupyter notebook notebooks/Model_Anomaly.ipynb
```

3. Run SQL Exercises
The SQL tasks are in sql/sql_exercise.sql

>To execute and export results (example using SQLite3 in PowerShell):
```bash
sqlite3 exercise.db ^
  ".headers on" ^
  ".mode csv" ^
  ".output sql/all_tasks_output.csv" ^
  ".read sql/sql_exercise.sql"
```
>This will generate the output file: sql/all_tasks_output.csv.

📊 Deliverables

- EDA & Data Quality → Clean joins, missing values, seasonality, supplier & mode patterns.

- Late Delivery Prediction → Gradient Boosting model, calibrated, evaluated with PR-AUC, ROC-AUC, F1, calibration, and slice analysis.

- Price Anomaly Detection → Normalized to EUR, z-score and Isolation Forest methods applied, anomalies flagged with plots.

- SQL Exercise → Queries to compute late rates, supplier performance, trailing reliability, overlapping prices, anomalies, and order values.

- REPORT.md → 2-page executive summary of approach, metrics, insights, and recommendations.

📈 Evaluation Metrics (Highlights)

- Late Delivery Model: PR-AUC = 0.664, ROC-AUC = 0.655, F1 (best) = 0.684

- Calibration: Brier score = 0.235, mild over/under-confidence corrected

- Anomaly Detection: ~80 anomalies flagged, consistent across methods

- SQL Outputs: All queries executed against exercise.db and exported

🛠 Requirements

- Python 3.10+

- pandas, numpy, scikit-learn, matplotlib, seaborn

- SQLite 3 (for SQL exercise)

Install with:
```bash
pip install -r requirements.txt
```
📑 References
```text
REPORT.md
 for executive summary of results.