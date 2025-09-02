# REPORT — Data Science Take-Home

## Task 1: EDA 

In this task, I explored and assessed the quality of a real-world dataset containing suppliers, products, price lists, purchase orders, and deliveries. I began by merging the different tables into a single unified dataset, ensuring that each purchase order was enriched with supplier, product, and delivery details. This allowed me to investigate data consistency, identify missing or invalid values, and check for potential anomalies such as unmatched suppliers or products. I also carried out descriptive analysis on the key attributes, looking at country distributions, supplier performance, product categories, and delivery timeliness.

Building on this, I addressed data quality issues by handling missing values, standardizing formats, and constructing calculated fields such as late delivery rates and distance bands. I then integrated price list information through time-aware matching, applying both strict and fallback joins to capture valid unit prices at the order date. With the cleaned and enriched dataset, I generated insights through visualizations and metrics, including supplier performance comparisons, shipment mode patterns, and deviation analysis between planned and actual timelines. These steps prepared the data for further analysis and ensured it could support accurate decision-making.

## Task 2: Predicting Late Deliveries 

### Model & Calibration: 
- Gradient Boosting model, calibrated with Platt Scaling.

### Validation Performance:
- ROC-AUC: 0.655
- PR-AUC: 0.664
- Brier Score: 0.235
- F1-score @ 0.5 threshold: 0.658

### Thresholds:
- Best-F1: 0.41 → F1 = 0.684
- Top-15% capacity: 0.564 → F1 = 0.338 (operationally actionable for riskiest orders)
- Calibration: Probabilities slightly better aligned to outcomes; reliability diagram confirms mild over/under-confidence.

### Slice Analysis:
- Ship mode: Sea shipments are riskier.
- Supplier country: UK & US have higher late rates.
- Distance: Very short (51–200 km) and very long (1001+ km) deliveries show more delays.
- Actionable Insight: Use top-risk thresholds and slice analysis to prioritize interventions and improve delivery performance.

## Task 3: Price Anomaly Detection
### Data Overview:
- Prices dataset shape: (854, 6)
- Robust z-scores computed for price anomalies.
- Flagged extreme values using |z| >= 3.0: 80 anomalies detected.
- Isolation Forest was applied (iso_score column), and top anomalies were scored 0.0 (outliers).

### Observations:
- Some anomalies are extreme, e.g., SKU00007 with z ≈ 18885—likely data entry errors.
- Most of the top anomalies detected by Isolation Forest correspond to the highest absolute z-scores, indicating consistency between methods.
- Shapes of datasets indicate that after filtering, there are enough rows to train models or do further analysis.

## Task 4: SQL Excercise
### Key Tasks & Insights:
#### Task 1 – Monthly Late Rate by Ship Mode
- Computed overall and ship-mode–level late delivery rates between April–June 2025.
- Found variability across modes: sea shipments showed the highest lateness rates, while air was more reliable.

#### Task 2 – Top 5 Suppliers by Volume
- Ranked suppliers by order count during Apr–Jun 2025, then compared their late rates.
- Highlighted that even high-volume suppliers vary in reliability, with some exceeding 50% late deliveries.

#### Task 3 – Trailing 90-Day Supplier Late Rate
- For each order, calculated the supplier’s trailing 90-day late rate.
- Enabled dynamic, rolling reliability scores useful for proactive supplier management.

#### Task 4 – Overlapping Price Windows
- Detected suppliers with overlapping valid price windows for the same SKU.
- These overlaps suggest possible data integrity issues or inconsistent pricing policies.

#### Task 5 – Order Value in EUR
- Joined purchase orders to valid price records at order date.
- Normalized prices into EUR and computed total order values.
- Provided a consistent monetary view across mixed currencies (USD, EUR).

#### Task 6 – Price Anomalies
- Normalized all price records to EUR and flagged outliers using a z-score–like approach.
- Identified anomalous prices (both too high and too low), supporting procurement cost-control initiatives.

#### Task 7 – Delay by Incoterm × Distance
- Grouped orders into distance buckets (<100km, 100–499km, 500–999km, 1000km+).
- Analyzed average delays by incoterm.
- Certain incoterms (e.g., FOB, DAP) showed systematic differences in delays across distances.

#### Task 8 – Predicted Risk vs. Actual Late Rate
- Compared actual lateness for orders with high predicted lateness (top 10% p_late) vs. others.
- High-risk orders had a significantly higher late rate (~79%) compared to low-risk (~51%), validating the predictive model’s usefulness.

### Overall Findings:
- Delivery reliability is uneven across transport modes, suppliers, and contractual terms.
- Supplier performance monitoring benefits from trailing-window metrics to spot emerging risks.
- Data quality checks (overlapping prices, anomalies) are essential for robust procurement systems.
- Predictive analytics can meaningfully flag high-risk orders, supporting proactive logistics planning.