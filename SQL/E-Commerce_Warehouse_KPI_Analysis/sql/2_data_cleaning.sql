USE warehouse_db;

# ===========================================================================
# STEP 1: Quick lookup at top 10 rows from each table
# ===========================================================================

SELECT * FROM suppliers LIMIT 10;
SELECT * FROM skus LIMIT 10;
SELECT * FROM purchase_orders LIMIT 10;
SELECT * FROM receiving_log LIMIT 10;
SELECT * FROM customer_orders LIMIT 10;
SELECT * FROM pick_orders LIMIT 10;
SELECT * FROM shipments LIMIT 10;

# FINDINGS:
# - All tables loaded correctly with expected column structure
# - Correct data types across all tables
# - No visible anomalies in sample rows
# - receiving_log.notes column is empty as expected (optional field)

# ===========================================================================
# STEP 2: Searching for unwanted NULL values
# ===========================================================================

# customer_orders
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN sku_id IS NULL THEN 1 ELSE 0 END) AS null_sku_id,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) AS null_status
FROM customer_orders;

# shipments
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN carrier IS NULL THEN 1 ELSE 0 END) AS null_carrier,
    SUM(CASE WHEN shipping_cost IS NULL THEN 1 ELSE 0 END) AS null_shipping_cost,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS null_ship_date,
    SUM(CASE WHEN actual_date IS NULL THEN 1 ELSE 0 END) AS null_actual_date,
    SUM(CASE WHEN is_on_time IS NULL THEN 1 ELSE 0 END) AS null_is_on_time
FROM shipments;

# purchase_orders
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN actual_date IS NULL THEN 1 ELSE 0 END) AS null_actual_date
FROM purchase_orders;

# FINDINGS:
# - No NULL values found in important columns
# - All key fields (order_id, sku_id, quantity, dates, status) are complete
# - Data integrity confirmed across customer_orders, shipments, purchase_orders

# ===========================================================================
# STEP 3: Date rows validation
# Dates should be in given hierarchy:
# order_date < ship_date < actual_date
# Dates in wrong hierarchy will give data error
# ===========================================================================

# Did shipment occur before order was placed?
SELECT COUNT(*) AS ship_before_order_error_flag
FROM shipments s
JOIN customer_orders co ON s.order_id = co.order_id
WHERE s.ship_date < co.order_date;

# Did delivery occur before shipment?
SELECT COUNT(*) AS delivery_before_ship_error_flag
FROM shipments
WHERE actual_date < ship_date;

# Did supplier delivery occur before PO was placed?
SELECT COUNT(*) AS delivery_before_PO__error_flag
FROM purchase_orders
WHERE actual_date < order_date;

# Did putaway occur before receiving?
SELECT COUNT(*) AS putaway_error_flag
FROM receiving_log
WHERE putaway_at < received_at;

# FINDINGS:
# - All date hierarchy checks returned 0 errors
# - No shipments occurred before orders were placed
# - No deliveries occurred before shipments
# - No supplier deliveries occurred before purchase orders
# - No putaway events occurred before receiving
# - Date logic is fully consistent across all tables

# ===========================================================================
# STEP 4: DUPLICATE REMOVAL
# Each order should appear only once in each table
# Duplicates indicate data quality issues
# ===========================================================================

# Remove duplicates from customer_orders keeping lowest order_id
DELETE co1 FROM customer_orders co1
INNER JOIN customer_orders co2
WHERE co1.order_id > co2.order_id
AND co1.order_code = co2.order_code;

# Remove duplicates from shipments keeping lowest shipment_id
DELETE s1 FROM shipments s1
INNER JOIN shipments s2
WHERE s1.shipment_id > s2.shipment_id
AND s1.order_id = s2.order_id;

# Remove duplicates from pick_orders keeping lowest pick_id
DELETE p1 FROM pick_orders p1
INNER JOIN pick_orders p2
WHERE p1.pick_id > p2.pick_id
AND p1.order_id = p2.order_id;

# Verify no duplicates remain
# Verify customer_orders
SELECT order_code, COUNT(*) AS cnt
FROM customer_orders
GROUP BY order_code
HAVING cnt > 1;

# Verify shipments
SELECT order_id, COUNT(*) AS cnt
FROM shipments
GROUP BY order_id
HAVING cnt > 1;

# Verify pick_orders
SELECT order_id, COUNT(*) AS cnt
FROM pick_orders
GROUP BY order_id
HAVING cnt > 1;

# FINDINGS:
# - No duplicates found in customer_orders, shipments or pick_orders
# - Verification queries returned empty results confirming no duplicates were left

# ===========================================================================
# STEP 5: BUSINESS LOGIC VALIDATION
# Checking if values make sense from business perspective
# ===========================================================================

# Negative or zero quantity in customer_orders
SELECT COUNT(*) AS invalid_quantity
FROM customer_orders
WHERE quantity <= 0;

# Negative prices in customer_orders
SELECT COUNT(*) AS invalid_price
FROM customer_orders
WHERE unit_price <= 0 OR total_value <= 0;

# Negative shipping cost in shipments
SELECT COUNT(*) AS invalid_shipping_cost
FROM shipments
WHERE shipping_cost < 0;

# received_qty greater than ordered_qty (supplier sent more than ordered)
SELECT COUNT(*) AS invalid_received_qty
FROM receiving_log rl
JOIN purchase_orders po ON rl.po_id = po.po_id
WHERE rl.received_qty > po.ordered_qty;

# FINDINGS:
# - No negative/zero quantities found in customer_orders
# - No negative prices/order values found
# - No negative shipping costs found
# - No supplier over-deliveries found (received_qty never exceeds ordered_qty)
# - All business logic checks passed successfully

# ===========================================================================
# STEP 6: CATEGORICAL VALUES VALIDATION
# Checking if categorical columns contain only expected values
# Unexpected values indicate data entry errors or system issues
# ===========================================================================

# Statuses validation in customer_orders
SELECT status, COUNT(*) AS cnt
FROM customer_orders
GROUP BY status
ORDER BY cnt DESC;

# Channels validation in customer_orders
SELECT channel, COUNT(*) AS cnt
FROM customer_orders
GROUP BY channel
ORDER BY cnt DESC;

# Carriers validation in shipments
SELECT carrier, COUNT(*) AS cnt
FROM shipments
GROUP BY carrier
ORDER BY cnt DESC;

# Roles validation in employees
SELECT role, COUNT(*) AS cnt
FROM employees
GROUP BY role
ORDER BY cnt DESC;

# ABC classes validation in skus
SELECT abc_class, COUNT(*) AS cnt
FROM skus
GROUP BY abc_class
ORDER BY cnt DESC;

# FINDINGS:
# - customer_orders statuses: delivered, shipped, returned, cancelled
# - customer_orders channels: website, mobile_app, marketplace
# - shipments carriers: DPD, DHL, InPost, UPS
# - employees roles: picker, receiver, packer, supervisor
# - skus ABC classes: A, B, C, distributed 100/150/250
# - all categorical values were succesfully validated

# ===========================================================================

# SUMMARY:
# - Dataset passed all 6 validation checks
# - No critical data quality issues found
# - Data is ready for KPI analysis
# - Total records validated: +/- 45,000 across 9 tables
