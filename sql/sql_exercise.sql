-- ============================================
-- SQL Exercise
-- Database: exercise.db (SQLite)
-- Output: one single file with separators
-- ============================================

-- ============================================
-- Task 1: Monthly late rate overall and by ship_mode (Apr–Jun 2025)
-- ============================================
SELECT '=== Task 1: Monthly late rate overall and by ship_mode (Apr-Jun 2025) ===';
WITH late_orders AS (
    SELECT
        po.order_id,
        po.ship_mode,
        d.actual_delivery_date,
        po.promised_date,
        CAST(d.late_delivery AS INTEGER) AS late_delivery,
        strftime('%Y-%m', po.order_date) AS order_month
    FROM purchase_orders po
    JOIN deliveries d ON po.order_id = d.order_id
    WHERE CAST(d.cancelled AS INTEGER) = 0
)
SELECT
    order_month,
    ship_mode,
    COUNT(*) AS total_orders,
    SUM(late_delivery) * 1.0 / COUNT(*) AS late_rate
FROM late_orders
WHERE order_month BETWEEN '2025-04' AND '2025-06'
GROUP BY order_month, ship_mode
ORDER BY order_month, ship_mode;
SELECT '--------------------------------------------';

-- ============================================
-- Task 2: Top 5 suppliers by volume with late_rate (Apr–Jun 2025)
-- ============================================
SELECT '=== Task 2: Top 5 suppliers by volume with late_rate (Apr-Jun 2025) ===';
WITH late_orders AS (
    SELECT
        po.supplier_id,
        po.order_id,
        CAST(d.late_delivery AS INTEGER) AS late_delivery
    FROM purchase_orders po
    JOIN deliveries d ON po.order_id = d.order_id
    WHERE CAST(d.cancelled AS INTEGER) = 0
      AND strftime('%Y-%m', po.order_date) BETWEEN '2025-04' AND '2025-06'
)
SELECT
    lo.supplier_id,
    s.name,
    COUNT(*) AS total_orders,
    SUM(late_delivery) * 1.0 / COUNT(*) AS late_rate
FROM late_orders lo
JOIN suppliers s ON lo.supplier_id = s.supplier_id
GROUP BY lo.supplier_id
ORDER BY total_orders DESC
LIMIT 5;
SELECT '--------------------------------------------';

-- ============================================
-- Task 3: Trailing 90-day supplier late rate per order
-- ============================================
SELECT '=== Task 3: Trailing 90-day supplier late rate per order ===';
WITH order_with_date AS (
    SELECT
        po.order_id,
        po.supplier_id,
        po.order_date,
        CAST(d.late_delivery AS INTEGER) AS late_delivery
    FROM purchase_orders po
    JOIN deliveries d ON po.order_id = d.order_id
    WHERE CAST(d.cancelled AS INTEGER) = 0
)
SELECT
    o1.order_id,
    o1.supplier_id,
    o1.order_date,
    (SELECT AVG(o2.late_delivery)
     FROM order_with_date o2
     WHERE o2.supplier_id = o1.supplier_id
       AND o2.order_date < o1.order_date
       AND o2.order_date >= date(o1.order_date, '-90 day')
    ) AS trailing_90d_late_rate
FROM order_with_date o1
ORDER BY o1.order_date;
SELECT '--------------------------------------------';

-- ============================================
-- Task 4: Detect overlapping price windows per (supplier_id, sku)
-- ============================================
SELECT '=== Task 4: Detect overlapping price windows per (supplier_id, sku) ===';
SELECT p1.supplier_id, p1.sku, p1.valid_from AS start1, p1.valid_to AS end1,
       p2.valid_from AS start2, p2.valid_to AS end2
FROM price_list p1
JOIN price_list p2
  ON p1.supplier_id = p2.supplier_id
 AND p1.sku = p2.sku
 AND p1.rowid < p2.rowid
WHERE p1.valid_to >= p2.valid_from
  AND p1.valid_from <= p2.valid_to
ORDER BY p1.supplier_id, p1.sku;
SELECT '--------------------------------------------';

-- ============================================
-- Task 5: Attach valid price at order date, normalize to EUR, compute order_value_eur
-- ============================================
SELECT '=== Task 5: Order value in EUR (with valid price) ===';
WITH valid_price AS (
    SELECT po.order_id, po.supplier_id, po.sku, CAST(po.qty AS INTEGER) AS qty, po.currency,
           po.order_date,
           pl.price_per_uom,
           pl.currency AS price_currency
    FROM purchase_orders po
    JOIN price_list pl
      ON po.supplier_id = pl.supplier_id
     AND po.sku = pl.sku
     AND CAST(po.qty AS INTEGER) >= CAST(pl.min_qty AS INTEGER)
     AND po.order_date BETWEEN pl.valid_from AND pl.valid_to
)
SELECT *,
       CASE 
           WHEN price_currency = 'USD' THEN CAST(price_per_uom AS REAL) * 0.92
           ELSE CAST(price_per_uom AS REAL)
       END AS price_eur,
       qty * CASE WHEN price_currency = 'USD' THEN CAST(price_per_uom AS REAL)*0.92 ELSE CAST(price_per_uom AS REAL) END AS order_value_eur
FROM valid_price;
SELECT '--------------------------------------------';

-- ============================================
-- Task 6: Flag price anomalies via z-score 
-- ============================================
SELECT '=== Task 6: Price anomalies via z-score ===';

WITH eur_prices AS (
    SELECT 
        pl.supplier_id,
        pl.sku,
        pl.valid_from,
        pl.valid_to,
        CAST(pl.price_per_uom AS REAL) * 
            CASE pl.currency
                WHEN 'USD' THEN 0.9   -- adjust as per conversion rate to EUR
                WHEN 'GBP' THEN 1.15
                ELSE 1.0              -- EUR stays the same
            END AS price_per_eur
    FROM price_list pl
)

SELECT 
    supplier_id,
    sku,
    price_per_eur,
    CASE 
        WHEN price_per_eur > 
            (AVG(price_per_eur) OVER (PARTITION BY supplier_id, sku) * 1.5)
        OR price_per_eur < 
            (AVG(price_per_eur) OVER (PARTITION BY supplier_id, sku) * 0.5)
        THEN 1 ELSE 0
    END AS is_anomaly
FROM eur_prices
ORDER BY supplier_id, sku, valid_from;

SELECT '--------------------------------------------';

-- ============================================
-- Task 7: Incoterm × distance buckets: avg delay_days & counts
-- ============================================
SELECT '=== Task 7: Delay by incoterm x distance bucket ===';
WITH orders_with_delay AS (
    SELECT po.order_id, po.incoterm, CAST(po.distance_km AS REAL) AS distance_km,
           CAST(d.delay_days AS REAL) AS delay_days
    FROM purchase_orders po
    JOIN deliveries d ON po.order_id = d.order_id
    WHERE CAST(d.cancelled AS INTEGER) = 0
)
SELECT incoterm,
       CASE 
           WHEN distance_km < 100 THEN '<100km'
           WHEN distance_km < 500 THEN '100-499km'
           WHEN distance_km < 1000 THEN '500-999km'
           ELSE '1000km+'
       END AS distance_bucket,
       AVG(delay_days) AS avg_delay_days,
       COUNT(*) AS order_count
FROM orders_with_delay
GROUP BY incoterm, distance_bucket
ORDER BY incoterm, distance_bucket;
SELECT '--------------------------------------------';

-- ============================================
-- Task 8 (Bonus): Compare late rate by predicted risk (top 10% p_late)
-- ============================================
SELECT '=== Task 8: Compare late rate by predicted risk (top 10% p_late) ===';
WITH risk AS (
    SELECT order_id, CAST(p_late AS REAL) AS p_late,
           CASE WHEN CAST(p_late AS REAL) >= (SELECT MAX(CAST(p_late AS REAL)) * 0.9 FROM predictions) THEN 'high' ELSE 'low' END AS risk_bucket
    FROM predictions
),
orders_with_late AS (
    SELECT po.order_id, CAST(d.late_delivery AS INTEGER) AS late_delivery
    FROM purchase_orders po
    JOIN deliveries d ON po.order_id = d.order_id
    WHERE CAST(d.cancelled AS INTEGER) = 0
)
SELECT r.risk_bucket, COUNT(*) AS total_orders, SUM(o.late_delivery)*1.0/COUNT(*) AS late_rate
FROM risk r
JOIN orders_with_late o ON r.order_id = o.order_id
GROUP BY r.risk_bucket;
SELECT '--------------------------------------------';
