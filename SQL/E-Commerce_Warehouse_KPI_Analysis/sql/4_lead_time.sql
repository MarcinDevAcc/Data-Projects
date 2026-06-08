# ===========================================================================
# LEAD TIME & ORDER CYCLE TIME ANALYSIS
# Lead Time = order_date to actual delivery (includes transport)
# Order Cycle Time = order_date to ship_date (warehouse only)
# Separating these two helps identifying potential delays
# ===========================================================================

# ===========================================================================
# STEP 1: OVERALL LEAD TIME & ORDER CYCLE TIME
# ===========================================================================

SELECT
    ROUND(AVG(DATEDIFF(s.actual_date, co.order_date)), 2) AS avg_lead_time_days,
    ROUND(AVG(DATEDIFF(s.ship_date, co.order_date)), 2) AS avg_oct_days,
    ROUND(AVG(DATEDIFF(s.actual_date, s.ship_date)), 2) AS avg_transport_days,
    MIN(DATEDIFF(s.actual_date, co.order_date)) AS min_lead_time,
    MAX(DATEDIFF(s.actual_date, co.order_date)) AS max_lead_time
FROM customer_orders co
JOIN shipments s ON co.order_id = s.order_id;

# FINDINGS:
# - Avg Lead Time:      2.96 days (order to delivery)
# - Avg OCT:            0.48 days (+/- 12 hours, warehouse processing only)
# - Avg Transport:      2.48 days (carrier delivery time)
# - Transport accounts for 84% of total Lead Time
# - Min Lead Time: 1 day | Max Lead Time: 9 days

# RECOMMENDATION:
# - Warehouse processing is highly efficient at +/- 12 hours
# - To reduce Lead Time focus on carrier negotiations, not warehouse
# - Investigate orders with 9 day Lead Time - likely carrier delays

# ===========================================================================
# STEP 2: LEAD TIME BY CARRIER
# Identifies which carrier delivers the fastest
# Combines reliability with speed
# ===========================================================================

SELECT
    s.carrier,
    COUNT(*) AS total_shipments,
    ROUND(AVG(DATEDIFF(s.actual_date, co.order_date)), 2) AS avg_lead_time_days,
    ROUND(AVG(DATEDIFF(s.actual_date, s.ship_date)), 2) AS avg_transport_days,
    MIN(DATEDIFF(s.actual_date, co.order_date)) AS min_lead_time,
    MAX(DATEDIFF(s.actual_date, co.order_date)) AS max_lead_time,
    ROUND(AVG(CASE WHEN s.is_on_time = 1 
        THEN 1 ELSE 0 END) * 100, 2) AS on_time_rate_pct
FROM customer_orders co
JOIN shipments s ON co.order_id = s.order_id
GROUP BY s.carrier
ORDER BY avg_lead_time_days ASC;

# FINDINGS:
# - UPS:    2.84 days avg | 94.76% on-time | fastest and most reliable
# - DHL:    2.90 days avg | 93.16% on-time
# - InPost: 2.95 days avg | 90.78% on-time
# - DPD:    3.04 days avg | 88.09% on-time | slowest and least reliable
# - All carriers share same min (1-2 days) and max (9 days) Lead Time

# RECOMMENDATION:
# - UPS is the best performer and the most costly one
# - DPD should be reviewed - slowest and least reliable
# - Consider shifting DPD volume to InPost for better Lead Time and Cost Efficency

# ===========================================================================
# STEP 3: LEAD TIME PERCENTILES BY CARRIER
# Average can be misleading - percentiles show full picture
# P90 = 90% of orders delivered within X days
# High P90 vs average = carrier has occasional severe delays
# ===========================================================================

SELECT
    carrier,
    ROUND(AVG(DATEDIFF(actual_date, ship_date)), 2) AS avg_transport_days,
    MAX(CASE WHEN pct_rank <= 0.50 
        THEN DATEDIFF(actual_date, ship_date) END) AS p50_days,
    MAX(CASE WHEN pct_rank <= 0.90 
        THEN DATEDIFF(actual_date, ship_date) END) AS p90_days,
    MAX(CASE WHEN pct_rank <= 0.95 
        THEN DATEDIFF(actual_date, ship_date) END) AS p95_days
FROM (
    SELECT
        carrier,
        actual_date,
        ship_date,
        PERCENT_RANK() OVER (
            PARTITION BY carrier 
            ORDER BY DATEDIFF(actual_date, ship_date)
        ) AS pct_rank
    FROM shipments
) ranked
GROUP BY carrier
ORDER BY avg_transport_days ASC;

# FINDINGS:
# - P50 (median): all carriers deliver in 2 days
# - P90: UPS and DHL deliver in 3 days | DPD already at 4 days
# - P95: UPS delivers in 3 days | InPost 5 days | DPD reaches 6 days
# - Averages are similar but P95 reveals DPD has severe tail delays
# - Every 20th DPD shipment takes 6 days - 2x longer than UPS at P95

# RECOMMENDATION:
# - Use P95 as SLA monitoring metric, not average
# - DPD P95 of 6 days is unacceptable for customer experience
# - Set carrier SLA threshold at P95 <= 4 days and review DPD contract accordingly

# ===========================================================================
# STEP 4: ORDER CYCLE TIME BY MONTH
# Identifies warehouse bottlenecks over time
# Stable OCT with rising Lead Time = carrier problem, not warehouse
# Rising OCT = warehouse capacity issue (e.g. Black Friday)
# ===========================================================================

SELECT
    DATE_FORMAT(co.order_date, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders,
    ROUND(AVG(DATEDIFF(s.ship_date, co.order_date) * 24 
        + HOUR(TIMEDIFF(s.ship_date, co.order_date))), 1) AS avg_oct_hours,
    ROUND(AVG(DATEDIFF(s.actual_date, co.order_date)), 2) AS avg_lead_time_days
FROM customer_orders co
JOIN shipments s ON co.order_id = s.order_id
GROUP BY order_month
ORDER BY order_month ASC;

# FINDINGS:
# - OCT remains stable at 19.0 - 20.1 hours throughout the year
# - Volume doubled from 807 orders (Jan) to 1 876 orders (Dec)
# - Despite 2x volume increase, OCT did not rise in Q4
# - Lead Time sits stable at 2.89 - 3.03 days across all months
# - No warehouse bottlenecks detected even during peak season

# RECOMMENDATION:
# - Warehouse operations are well scaled - current staffing model performs best
# - January shows slightly higher OCT (20.1h) - monitor post-holiday returns
#   processing which may compete with new order fulfillment
# - Document current warehouse processes as best practice

# ===========================================================================
# STEP 5: LEAD TIME BY CATEGORY
# Heavier or larger products may take longer to process and ship
# ===========================================================================

SELECT
    s.category,
    COUNT(*) AS total_orders,
    ROUND(AVG(DATEDIFF(sh.actual_date, co.order_date)), 2) AS avg_lead_time_days,
    ROUND(AVG(DATEDIFF(sh.ship_date, co.order_date) * 24
        + HOUR(TIMEDIFF(sh.ship_date, co.order_date))), 1) AS avg_oct_hours,
    ROUND(AVG(s.weight_kg), 3) AS avg_weight_kg
FROM customer_orders co
JOIN shipments sh ON co.order_id = sh.order_id
JOIN skus s ON co.sku_id = s.sku_id
GROUP BY s.category
ORDER BY avg_lead_time_days DESC;

# FINDINGS:
# - Lead Time range: 2.92 - 3.00 days across all categories
# - Weight range: 0.267 kg (Beauty) to 2.365 kg (Home & Garden)
# - Despite 9x weight difference Lead Time difference is only 0.08 days
# - Home & Garden: heaviest (2.365 kg) but second fastest Lead Time (2.92)
# - No correlation between product weight and Lead Time

# RECOMMENDATION:
# - Current carrier pricing likely does not penalize heavier shipments
#   in terms of delivery speed - verify in carrier contracts
# - Uniform Lead Time across categories simplifies customer communication
#   - use single SLA promise of 3 days for all categories

# ===========================================================================
# STEP 6: SUPPLIER LEAD TIME
# Time from Purchase Order to actual delivery from supplier
# Different from customer Lead Time - this is replenishment side
# High supplier Lead Time = risk of stockouts
# ===========================================================================

SELECT
    sup.supplier_name,
    sup.country,
    sup.lead_time_days AS declared_lead_time,
    COUNT(*) AS total_orders,
    ROUND(AVG(DATEDIFF(po.actual_date, po.order_date)), 1) AS avg_actual_lead_time,
    ROUND(AVG(DATEDIFF(po.actual_date, po.order_date))
        - sup.lead_time_days, 1) AS avg_delay_days,
    ROUND(AVG(CASE WHEN po.actual_date <= po.expected_date
        THEN 1 ELSE 0 END) * 100, 1) AS on_time_rate_pct
FROM purchase_orders po
JOIN suppliers sup ON po.supplier_id = sup.supplier_id
GROUP BY sup.supplier_id, sup.supplier_name, 
         sup.country, sup.lead_time_days
ORDER BY avg_delay_days DESC;

# FINDINGS:
# - ShanghaiGoods Ltd.:  +2.7 days delay | 51.1% on-time | highest risk
# - AnkaraSupply Co.:    +2.5 days delay | 58.7% on-time
# - ShenzhenTech Ltd.:   +1.9 days delay | 57.3% on-time
# - KrakówHurt Sp. z o.o.: -0.1 days | 74.5% on-time | only supplier
#                           delivering ahead of declared lead time
# - Chinese suppliers (3) average on-time rate: 55.8% - critically low
# - BerlinLogistics AG: +1.4 days on 7 day lead time = 20% delay ratio
#   higher relative impact than ShanghaiGoods +2.7 on 24 days (11%)

# RECOMMENDATION:
# - Immediately renegotiate SLA with ShanghaiGoods and AnkaraSupply
# - For Chinese suppliers increase safety stock to cover avg delay of 2+ days
# - BerlinLogistics short lead time with 20% delay ratio poses
#   high stockout risk - consider alternative German supplier
# - KrakówHurt is the most reliable supplier - prioritize
#   for A-class SKUs where stockout risk is highest