USE warehouse_db;

# ===========================================================================
#	DATA IMPORT
# 	Loads CSV files from data/raw/ into warehouse_db tables
#
# 	SETUP INSTRUCTIONS FOR NEW MACHINE:
# 	1. Run schema.sql first to create the database and tables
# 	2. Check your MySQL secure_file_priv path by running:
#    	SHOW VARIABLES LIKE 'secure_file_priv';
# 	3. Copy all CSV files from /data/raw/ to the path from step 2
# 	4. Replace the path in each LOAD DATA INFILE statement below
#    	with your own secure_file_priv path
# 	NOTE: Boolean columns (is_active, is_correct, is_on_time) are stored
# 	as True/False in CSV but converted to 1/0 during import
# ===========================================================================

# 1. SUPPLIERS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/suppliers.csv'
INTO TABLE suppliers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(supplier_id, supplier_name, country, lead_time_days, reliability_pct, created_at);

# 2. SKUS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/skus.csv'
INTO TABLE skus
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(sku_id, sku_code, product_name, category, unit_cost, unit_price, weight_kg, abc_class, supplier_id, created_at);

# 3. EMPLOYEES
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(employee_id, employee_code, first_name, last_name, role, shift, 
 hire_date, @is_active, created_at)
SET is_active = IF(@is_active = 'True', 1, 0);

# 4. PURCHASE ORDERS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/purchase_orders.csv'
INTO TABLE purchase_orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(po_id, supplier_id, sku_id, ordered_qty, unit_cost, status, order_date, expected_date, actual_date, created_at);

# 5. RECEIVING LOG
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/receiving_log.csv'
INTO TABLE receiving_log
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(receiving_id, po_id, sku_id, employee_id, received_qty, damaged_qty, received_at, putaway_at, location_code, notes, created_at);

# 6. INVENTORY
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/inventory.csv'
INTO TABLE inventory
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(inventory_id, sku_id, quantity_on_hand, quantity_reserved, quantity_available, reorder_point, last_updated);

# 7. CUSTOMER ORDERS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer_orders.csv'
INTO TABLE customer_orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, order_code, customer_id, sku_id, quantity, unit_price, total_value, channel, status, order_date, required_date, created_at);

# 8. PICK ORDERS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/pick_orders.csv'
INTO TABLE pick_orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(pick_id, order_id, employee_id, sku_id, qty_requested, qty_picked, 
 @is_correct, error_type, started_at, completed_at, lines_picked, created_at)
SET is_correct = IF(@is_correct = 'True', 1, 0);

# 9. SHIPMENTS
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/shipments.csv'
INTO TABLE shipments
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(shipment_id, order_id, carrier, tracking_number, shipping_cost, weight_kg, 
 ship_date, estimated_date, actual_date, sla_days, @is_on_time, created_at)
SET is_on_time = IF(@is_on_time = 'True', 1, 0);

# Data validation
SELECT 'suppliers'AS tbl, COUNT(*) AS n FROM suppliers
UNION ALL
SELECT 'skus', COUNT(*) FROM skus
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'purchase_orders', COUNT(*) FROM purchase_orders
UNION ALL
SELECT 'receiving_log', COUNT(*) FROM receiving_log
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'customer_orders', COUNT(*) FROM customer_orders
UNION ALL
SELECT 'pick_orders', COUNT(*) FROM pick_orders
UNION ALL
SELECT 'shipments', COUNT(*) FROM shipments;