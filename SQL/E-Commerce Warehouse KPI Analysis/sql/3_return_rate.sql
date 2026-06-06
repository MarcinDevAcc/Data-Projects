# ===========================================================================
# RETURN RATE ANALYSIS
# Return Rate = returned orders / total orders * 100
# High return rate = hidden costs: double shipping, repicking, repackaging
# Industry benchmark for e-commerce: 5-10%
# ===========================================================================

USE warehouse_db;

# ===========================================================================
# STEP 1: OVERALL RETURN RATE (In Percentage)
# ===========================================================================

SELECT
    COUNT(*) AS total_orders,
    SUM(
		CASE WHEN status = 'returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(
		SUM(
			CASE WHEN status = 'returned' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS return_rate_pct
FROM customer_orders;

# FINDINGS:
# - Total orders: 15 000 | Returned: 759 | Return Rate: 5.06%
# - Result is at the lower end of e-commerce benchmark (5-10%)
# - Operation is performing well overall

# RECOMMENDATION:
# - Monitor return rate % monthly to detect any upward trend early
# - Target to maintain Return Rate below 6% as volume grows in Q4

# ===========================================================================
# STEP 2: RETURN RATE BY CATEGORY
# Which product category generates most returns
# ===========================================================================

SELECT
    s.category,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN co.status = 'returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(
        SUM(CASE WHEN co.status = 'returned' THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2) AS return_rate_pct
FROM customer_orders co
JOIN skus s ON co.sku_id = s.sku_id
GROUP BY s.category
ORDER BY return_rate_pct DESC;

# FINDINGS:
# - Home & Garden: 5.53% - highest return rate
# - Sports:        5.50% - second highest
# - Electronics:   5.06% - at overall average
# - Beauty:        4.76%
# - Clothing:      4.29% - lowest return rate

# RECOMMENDATION:
# - Investigate Home & Garden and Sports product listings
#   customers may struggle to assess fit/size/compatibility online
# - Improve products description and photos for these categories
# - Consider adding size guides or compatibility checkers

# ===========================================================================
# STEP 3: RETURN RATE BY CHANNEL
# Which sales channel generates most returns
# Different channels may have different customer behavior
# ===========================================================================

SELECT
    channel,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(
        SUM(CASE WHEN status = 'returned' THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2) AS return_rate_pct
FROM customer_orders
GROUP BY channel
ORDER BY return_rate_pct DESC;

# FINDINGS:
# - Website:     5.17% - highest return rate
# - Mobile App:  5.11% - similar to website
# - Marketplace: 4.59% - lowest return rate

# RECOMMENDATION:
# - Marketplace customers research products more carefully before buying
#   resulting in fewer returns - apply same approach to website
# - Improve product pages on website and mobile app with:
#   better descriptions, photos and customer reviews

# ===========================================================================
# STEP 4: RETURN RATE BY MONTH
# Identifies seasonal trends in returns
# Spikes may indicate product quality issues or campaign side effects
# ===========================================================================

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(
        SUM(CASE WHEN status = 'returned' THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2) AS return_rate_pct
FROM customer_orders
GROUP BY order_month
ORDER BY order_month ASC;

# FINDINGS:
# - Highest Return Rate: July (5.75%), December (5.67%), September (5.42%)
# - Lowest Return Rate: April (3.90%) and May (4.17%)
# - Q4 shows rising volume (1800-2100 orders) with higher return rate
# - No dramatic spikes suggesting systemic product quality issues

# RECOMMENDATION:
# - Prepare additional returns processing capacity for July and December
# - Analyze Q4 promotional campaigns - impulse purchases during
#   Black Friday and Christmas result in higher return rates
# - Consider stricter return policy for promotional items if possible

# ===========================================================================
# STEP 5: FINANCIAL IMPACT OF RETURNS
# Returns generate hidden costs - lost revenue + double shipping
# ===========================================================================

SELECT
    s.category,
    SUM(CASE WHEN co.status = 'returned' 
        THEN co.total_value ELSE 0 END) AS lost_revenue,
    COUNT(CASE WHEN co.status = 'returned' 
        THEN 1 END) AS returned_orders,
    ROUND(AVG(CASE WHEN co.status = 'returned' 
        THEN co.total_value END), 2)  AS avg_returned_order_value,
    ROUND(
        SUM(CASE WHEN co.status = 'returned' THEN co.total_value ELSE 0 END)
        / SUM(co.total_value) * 100, 2) AS lost_revenue_pct
FROM customer_orders co
JOIN skus s ON co.sku_id = s.sku_id
GROUP BY s.category
ORDER BY lost_revenue DESC;

# FINDINGS:
# - Electronics:    164 705 zł lost | avg returned order: 1 229 zł
# - Sports:         118 119 zł lost | avg returned order:   609 zł
# - Home & Garden:   79 204 zł lost | avg returned order:   492 zł
# - Beauty:          37 380 zł lost | avg returned order:   225 zł
# - Clothing:        30 642 zł lost | avg returned order:   295 zł
#
# Electronics has low return rate % (5.06%) but highest financial impact
# due to high product value - each return costs 1 229 zł on average
# Sports has both high return rate AND high order value = double problem

# RECOMMENDATION:
# - Prioritize return reduction for Electronics and Sports
# - For Electronics: improve technical specifications in product listings
#   to reduce incompatibility returns
# - For Sports: add size guides and compatibility information
# - Consider restocking fee for high-value Electronics returns

# ===========================================================================
# STEP 6: TOP 10 SKU BY RETURN RATE
# Identifies specific products driving returns
# Showing 10 orders to avoid statistical noise
# ===========================================================================

SELECT
    s.sku_code,
    s.product_name,
    s.category,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN co.status = 'returned' THEN 1 ELSE 0 END) AS returned_orders,
    ROUND(
        SUM(CASE WHEN co.status = 'returned' THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2) AS return_rate_pct,
    ROUND(
		AVG(co.total_value), 2) AS avg_order_value
FROM customer_orders co
JOIN skus s ON co.sku_id = s.sku_id
GROUP BY s.sku_id, s.sku_code, s.product_name, s.category
HAVING total_orders >= 10
ORDER BY return_rate_pct DESC
LIMIT 10;

# FINDINGS:
# - SKU-0320 Sports:       27.27% return rate | avg order: 929 zł
# - SKU-0086 Electronics:  21.74% return rate | avg order: 1 217 zł (most costly)
# - Top 10 dominated by Sports (4 SKUs) and Electronics (4 SKUs)
# - All top problematic SKUs have return rate 4x higher than overall average

# RECOMMENDATION:
# - Immediately review product listings for SKU-0320 and SKU-0086
# - SKU-0086 Electronics is the highest financial risk:
#   21.74% return rate on 1 217 zł average order value
# - Consider temporarily removing worst performers pending listing improvement
# - Add customer return reason tracking to identify root causes per SKU