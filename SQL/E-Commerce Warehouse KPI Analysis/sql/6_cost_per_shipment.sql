# ===========================================================================
# COST PER SHIPMENT ANALYSIS
# Cost per Shipment = total shipping cost / number of shipments
# Key metric for logistics scalability and profitability
# Rising CPS with rising volume = inefficient scaling
# ===========================================================================

# ===========================================================================
# STEP 1: OVERALL COST PER SHIPMENT
# ===========================================================================

SELECT
    COUNT(*) AS total_shipments,
    ROUND(SUM(shipping_cost), 2) AS total_shipping_cost,
    ROUND(AVG(shipping_cost), 2) AS avg_cost_per_shipment,
    ROUND(MIN(shipping_cost), 2) AS min_cost,
    ROUND(MAX(shipping_cost), 2) AS max_cost,
    ROUND(AVG(weight_kg), 3) AS avg_weight_kg
FROM shipments;

# FINDINGS:
# - Total shipments:       13 526
# - Total shipping cost:   198 520 zł
# - Avg Cost per Shipment: 14.68 zł
# - Min cost: 6.00 zł (InPost) | Max cost: 34.97 zł (UPS)
# - Avg package weight: 4.015 kg

# RECOMMENDATION:
# - Baseline CPS of 14.68 zł should be monitored monthly
# - Wide range between min (6.00 zł) and max (34.97 zł) suggests
#   carrier mix optimization potential
# - Target average CPS reduction to 13.50 zł through carrier rebalancing

# ===========================================================================
# STEP 2: COST PER SHIPMENT BY CARRIER
# Compares carriers by cost efficiency and reliability
# Best carrier = lowest cost + highest on-time rate
# ===========================================================================

SELECT
    carrier,
    COUNT(*) AS total_shipments,
    ROUND(SUM(shipping_cost), 2) AS total_cost,
    ROUND(AVG(shipping_cost), 2) AS avg_cost_per_shipment,
    ROUND(AVG(weight_kg), 3) AS avg_weight_kg,
    ROUND(AVG(is_on_time) * 100, 2) AS on_time_rate_pct,
    ROUND(SUM(shipping_cost) / COUNT(*), 2) AS cost_per_shipment
FROM shipments
GROUP BY carrier
ORDER BY avg_cost_per_shipment ASC;

# FINDINGS:
# - InPost: 10.01 zł | 90.78% on-time | cheapest carrier
# - DPD:    12.95 zł | 88.09% on-time | cheapest courier
# - DHL:    18.51 zł | 93.16% on-time
# - UPS:    24.95 zł | 94.76% on-time | most expensive
# - UPS costs 2.5x more than InPost but delivers only 4% more reliably
# - DPD is only 2.94 zł cheaper than InPost but 2.69% less reliable

# RECOMMENDATION:
# - Shift volume from DPD to InPost - better reliability at lower cost
# - Reserve UPS for high-value orders where reliability justifies premium
# - DHL is viable middle ground for standard orders requiring >91% on-time

# ===========================================================================
# STEP 3: COST PER SHIPMENT BY CATEGORY
# Heavier categories should have higher shipping costs
# If not - carrier pricing may not reflect actual weight
# ===========================================================================

SELECT
    s.category,
    COUNT(*) AS total_shipments,
    ROUND(AVG(sh.shipping_cost), 2) AS avg_cost_per_shipment,
    ROUND(AVG(sh.weight_kg), 3) AS avg_weight_kg,
    ROUND(AVG(co.total_value), 2) AS avg_order_value,
    ROUND(AVG(sh.shipping_cost) 
        / AVG(co.total_value) * 100, 2) AS shipping_cost_pct_of_value
FROM shipments sh
JOIN customer_orders co ON sh.order_id = co.order_id
JOIN skus s ON co.sku_id = s.sku_id
GROUP BY s.category
ORDER BY avg_cost_per_shipment DESC;

# FINDINGS:
# - CPS range: 14.59 zł (Electronics) to 14.77 zł (Home & Garden)
# - Weight range: 1.287 kg (Beauty) to 7.706 kg (Home & Garden)
# - Despite 6x weight difference CPS varies by only 0.18 zł
# - Carrier pricing does not reflect actual weight differences
#
# - Shipping cost as % of order value:
#   Beauty:        6.46% - highest margin erosion
#   Clothing:      4.42%
#   Home & Garden: 2.97%
#   Sports:        2.56%
#   Electronics:   1.10% - lowest margin erosion

# RECOMMENDATION:
# - Negotiate weight-based pricing with carriers
#   Home & Garden at 7.706 kg should cost significantly more than
#   Beauty at 1.287 kg - current flat pricing benefits heavy categories
# - Beauty category requires attention - 6.46% shipping cost
#   significantly reduces already thin cosmetics margins
# - Consider minimum order value for Beauty category (e.g. 150 zł)
#   to reduce shipping cost impact on margin

# ===========================================================================
# STEP 4: COST PER SHIPMENT TREND BY MONTH
# Identifies if shipping costs scale efficiently with volume
# Rising CPS with rising volume = inefficient scaling
# Falling CPS with rising volume = good economies of scale
# ===========================================================================

SELECT
    DATE_FORMAT(sh.ship_date, '%Y-%m') AS ship_month,
    COUNT(*) AS total_shipments,
    ROUND(SUM(sh.shipping_cost), 2) AS total_cost,
    ROUND(AVG(sh.shipping_cost), 2) AS avg_cost_per_shipment,
    ROUND(AVG(sh.weight_kg), 3) AS avg_weight_kg
FROM shipments sh
GROUP BY ship_month
ORDER BY ship_month ASC;

# FINDINGS:
# - CPS stable between 14.41 zł (July) and 14.91 zł (March) all year
# - Volume grew from 807 shipments (January) to 1 876 (December)
# - Despite 2.3x volume increase CPS did not decrease in Q4
# - No economies of scale achieved with higher shipment volumes
# - Total cost grew proportionally with volume (flat CPS)

# RECOMMENDATION:
# - Renegotiate carrier contracts to include volume discount tiers
#   e.g. >1 500 shipments/month should trigger lower rate per shipment
# - Q4 volume increase is predictable - use as leverage in annual
#   carrier contract negotiations
# - Target 5% CPS reduction in Q4 through volume-based pricing

# ===========================================================================
# STEP 5: SHIPPING COST VS ORDER VALUE
# Low order value with high shipping cost = margin erosion
# Identifies orders where shipping cost exceeds acceptable threshold
# ===========================================================================

SELECT
    CASE
        WHEN co.total_value < 50  THEN 'Under 50 zł'
        WHEN co.total_value < 100 THEN '50-100 zł'
        WHEN co.total_value < 200 THEN '100-200 zł'
        WHEN co.total_value < 500 THEN '200-500 zł'
        ELSE 'Over 500 zł'
    END AS order_value_bucket,
    COUNT(*) AS total_orders,
    ROUND(AVG(co.total_value), 2) AS avg_order_value,
    ROUND(AVG(sh.shipping_cost), 2) AS avg_shipping_cost,
    ROUND(AVG(sh.shipping_cost) 
        / AVG(co.total_value) * 100, 2) AS shipping_pct_of_value
FROM shipments sh
JOIN customer_orders co ON sh.order_id = co.order_id
GROUP BY order_value_bucket
ORDER BY avg_order_value ASC;

# FINDINGS:
# - Under 50 zł:   583 orders  | shipping = 42.93% of order value
# - 50-100 zł:   1 200 orders  | shipping = 19.36% of order value
# - 100-200 zł:  2 239 orders  | shipping =  9.91% of order value
# - 200-500 zł:  4 148 orders  | shipping =  4.42% of order value
# - Over 500 zł: 5 356 orders  | shipping =  1.33% of order value
# - 1 783 orders below 100 zł where shipping exceeds 19% of value
# - Orders under 50 zł are almost certainly unprofitable after
#   shipping, picking and packaging costs are included

# RECOMMENDATION:
# - Introduce free shipping threshold at 100 zł minimum order value
#   to eliminate most unprofitable small basket orders
# - For orders under 50 zł consider flat shipping fee charged to customer
#   or remove free shipping eligibility entirely
# - Focus marketing promotions on increasing basket value above 200 zł
#   where shipping cost drops to 4.42% - acceptable margin impact

# ===========================================================================
# STEP 6: CARRIER EFFICIENCY SCORE
# Combines cost and on-time rate into single efficiency metric
# Higher score = better value for money
# Score = on_time_rate / avg_cost_per_shipment * 10
# ===========================================================================

SELECT
    carrier,
    COUNT(*) AS total_shipments,
    ROUND(AVG(shipping_cost), 2) AS avg_cost,
    ROUND(AVG(is_on_time) * 100, 2) AS on_time_rate_pct,
    ROUND(AVG(weight_kg), 3) AS avg_weight_kg,
    ROUND((AVG(is_on_time) * 100) 
        / AVG(shipping_cost) * 10, 2) AS efficiency_score
FROM shipments
GROUP BY carrier
ORDER BY efficiency_score DESC;

# FINDINGS:
# - Efficency score per carrier:
# - InPost: 90.69 - clear efficiency leader
# - DPD:    68.03 - second but significantly behind InPost
# - DHL:    50.34 - good quality but high cost reduces score
# - UPS:    37.98 - lowest efficiency despite best reliability
#
# - InPost efficiency score is 2.4x higher than UPS
# - Gap between InPost (90.69) and DPD (68.03) confirms
#   DPD volume should be shifted to InPost

# RECOMMENDATION:
# - Increase InPost volume share from current 29.7% to 40%+
# - Reduce DPD share as it offers worst on-time rate at second lowest cost
# - Maintain UPS for premium/high-value shipments only
# - Target carrier mix: InPost 40% | DHL 25% | DPD 20% | UPS 15%
#   estimated CPS reduction: +/-0.80 zł per shipment = +/-10 800 zł annually