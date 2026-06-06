# ===========================================================================
# FILL RATE ANALYSIS
# Fill Rate = received_qty / ordered_qty * 100
# Measures how well suppliers fulfill purchase orders
# Low Fill Rate = stockout risk, lost sales, backorders
# ===========================================================================

# ===========================================================================
# STEP 1: OVERALL FILL RATE
# ===========================================================================

SELECT
    SUM(po.ordered_qty) AS total_ordered,
    SUM(rl.received_qty) AS total_received,
    ROUND(SUM(rl.received_qty) 
        / SUM(po.ordered_qty) * 100, 2) AS fill_rate_pct,
    SUM(po.ordered_qty - rl.received_qty) AS total_unfulfilled
FROM purchase_orders po
JOIN receiving_log rl ON po.po_id = rl.po_id;

# FINDINGS:
# - Total ordered:      328 836 units
# - Total received:     314 284 units
# - Overall Fill Rate:  95.57% - below industry benchmark of 98%
# - Total unfulfilled:  14 552 units across all suppliers

# RECOMMENDATION:
# - Gap of 2.43% below benchmark represents significant supply risk
# - Immediate supplier performance review required
# - Set minimum Fill Rate threshold of 97% in supplier contracts

# ===========================================================================
# STEP 2: FILL RATE BY SUPPLIER
# Identifies which suppliers fail to fulfill orders completely
# Low fill rate supplier = risk to inventory levels
# ===========================================================================

SELECT
    sup.supplier_name,
    sup.country,
    COUNT(*) AS total_orders,
    SUM(po.ordered_qty) AS total_ordered,
    SUM(rl.received_qty) AS total_received,
    ROUND(SUM(rl.received_qty)
        / SUM(po.ordered_qty) * 100, 2) AS fill_rate_pct,
    SUM(po.ordered_qty - rl.received_qty) AS unfulfilled_qty
FROM purchase_orders po
JOIN receiving_log rl ON po.po_id = rl.po_id
JOIN suppliers sup ON po.supplier_id = sup.supplier_id
GROUP BY sup.supplier_id, sup.supplier_name, sup.country
ORDER BY fill_rate_pct ASC;


# FINDINGS:
# - ShanghaiGoods Ltd.:  	93.78% - worst performer 	| 1 430 units unfulfilled
# - MilanExport S.r.l.:  	94.32% - second worst   	| 1 090 units unfulfilled
# - KrakówHurt Sp. z o.o.: 	94.67%                		| 1 379 units unfulfilled
# - RomaTrade S.r.l.:    	97.25% - best performer  	| 	603 units unfulfilled
#
# - Only RomaTrade exceeds 	97% threshold
# - ShanghaiGoods also has worst Lead Time delay (+2.7 days from file 4),
#   making it the highest overall supply chain risk

# RECOMMENDATION:
# - Priority review for ShanghaiGoods:
#   combines worst Fill Rate AND worst Lead Time delay - consider alternative Chinese supplier
# - Negotiate Fill Rate SLA clauses with bottom 5 suppliers
# - RomaTrade S.r.l. is best practice example - analyze their process

# ===========================================================================
# STEP 3: FILL RATE BY CATEGORY
# Identifies which product categories have supply issues
# Low fill rate category = potential lost sales in that segment
# ===========================================================================

SELECT
    s.category,
    COUNT(*) AS total_orders,
    SUM(po.ordered_qty) AS total_ordered,
    SUM(rl.received_qty) AS total_received,
    ROUND(SUM(rl.received_qty)
        / SUM(po.ordered_qty) * 100, 2) AS fill_rate_pct,
    SUM(po.ordered_qty - rl.received_qty) AS unfulfilled_qty
FROM purchase_orders po
JOIN receiving_log rl ON po.po_id = rl.po_id
JOIN skus s ON po.sku_id = s.sku_id
GROUP BY s.category
ORDER BY fill_rate_pct ASC;

# FINDINGS:
# - Sports:        94.10% - lowest Fill Rate 	| 4 253 units unfulfilled
# - Electronics:   95.50%                   	| 2 822 units unfulfilled
# - Home & Garden: 95.64%                   	| 2 699 units unfulfilled
# - Beauty:        96.14%                   	| 2 761 units unfulfilled
# - Clothing:      96.67% - best category   	| 2 017 units unfulfilled
#
# - Sports also had highest Return Rate (5.50%) in file 3,
#   which makes it the most problematic category overall

# RECOMMENDATION:
# - Sports category requires urgent attention - supply gaps combined
#   with high return rate create double margin pressure
# - Review Sports supplier mix and consider diversifying supply sources
# - Clothing shows best performance across both Fill Rate and Return Rate
#   use as benchmark for other categories

# ===========================================================================
# STEP 4: FILL RATE BY ABC CLASS
# A-class SKUs are top revenue drivers
# Low fill rate on A-class = highest business impact
# ===========================================================================

SELECT
    s.abc_class,
    COUNT(*) AS total_orders,
    SUM(po.ordered_qty) AS total_ordered,
    SUM(rl.received_qty) AS total_received,
    ROUND(SUM(rl.received_qty)
        / SUM(po.ordered_qty) * 100, 2) AS fill_rate_pct,
    SUM(po.ordered_qty - rl.received_qty) AS unfulfilled_qty
FROM purchase_orders po
JOIN receiving_log rl ON po.po_id = rl.po_id
JOIN skus s ON po.sku_id = s.sku_id
GROUP BY s.abc_class
ORDER BY s.abc_class ASC;

# FINDINGS:
# - Class A: 95.82% | 2 529 units unfulfilled
# - Class B: 95.97% | 4 013 units unfulfilled
# - Class C: 95.25% | 8 010 units unfulfilled - largest absolute gap
# - Fill Rate is similar across all classes (95.25% - 95.97%)
# - Class A at 95.82% means top revenue-driving products have supply gaps
#   directly impacting 80% of revenue (Pareto principle)

# RECOMMENDATION:
# - Prioritize Fill Rate improvement for Class A SKUs
# - Increase safety stock for Class A to buffer supplier shortfalls
# - Class C large unfulfilled qty (8 010) is less critical financially
#   but monitor to avoid long-tail stockouts affecting customer experience

# ===========================================================================
# STEP 5: TOP 10 SKU WITH LOWEST FILL RATE
# Identifies specific products with supply issues
# Minimum 3 orders to avoid statistical noise
# ===========================================================================

SELECT
    s.sku_code,
    s.product_name,
    s.category,
    s.abc_class,
    COUNT(*) AS total_orders,
    SUM(po.ordered_qty) AS total_ordered,
    SUM(rl.received_qty) AS total_received,
    ROUND(SUM(rl.received_qty)
        / SUM(po.ordered_qty) * 100, 2) AS fill_rate_pct,
    SUM(po.ordered_qty - rl.received_qty) AS unfulfilled_qty
FROM purchase_orders po
JOIN receiving_log rl ON po.po_id = rl.po_id
JOIN skus s ON po.sku_id = s.sku_id
GROUP BY s.sku_id, s.sku_code, s.product_name, s.category, s.abc_class
HAVING total_orders >= 3
ORDER BY fill_rate_pct ASC
LIMIT 10;

# FINDINGS:
# - SKU-0500 Clothing B:      74.28% - worst Fill Rate in dataset
# - SKU-0038 Sports C:        74.45%
# - SKU-0259 Home & Garden A: 77.90% - Class A product with critical gap
# - SKU-0278 Clothing A:      78.40% - Class A product with critical gap
# - SKU-0136 Sports A:        80.62% - Class A product with critical gap
# - 3 out of 10 worst SKUs are Class A - direct revenue impact
# - Sports dominates with 4 SKUs in bottom 10

# RECOMMENDATION:
# - Immediately increase safety stock for SKU-0259, SKU-0278, SKU-0136
#   as Class A products cannot afford supply gaps
# - Escalate SKU-0500 and SKU-0038 to supplier account managers
# - Set SKU-level Fill Rate alerts for any product dropping below 85%

# ===========================================================================
# STEP 6: FILL RATE TREND BY MONTH
# Identifies if supply issues are getting better or worse over time
# Declining trend = growing supply chain problems
# ===========================================================================

SELECT
    DATE_FORMAT(po.order_date, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders,
    SUM(po.ordered_qty) AS total_ordered,
    SUM(rl.received_qty) AS total_received,
    ROUND(SUM(rl.received_qty)
        / SUM(po.ordered_qty) * 100, 2) AS fill_rate_pct,
    SUM(po.ordered_qty - rl.received_qty) AS unfulfilled_qty
FROM purchase_orders po
JOIN receiving_log rl ON po.po_id = rl.po_id
GROUP BY order_month
ORDER BY order_month ASC;

# FINDINGS:
# - Fill Rate fluctuates between 94.25% (April) and 96.99% (June, December)
# - No consistent declining trend detected throughout the year
# - Worst months: April (94.25%), September (94.37%), October (94.36%)
# - Best months:  June (96.99%), December (96.99%), January (96.84%)
# - Supply issues appear random rather than structural or seasonal

# RECOMMENDATION:
# - No systemic supply chain deterioration detected - positive signal
# - Monitor April, September and October more closely in following year
#   as these months show recurring Fill Rate dips
# - Investigate if specific suppliers drive monthly fluctuations
#   by cross-referencing with Step 2 supplier data