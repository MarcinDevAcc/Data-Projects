CREATE DATABASE IF NOT EXISTS warehouse_db;
USE warehouse_db;

-- 1. SUPPLIERS

CREATE TABLE suppliers (
    supplier_id     INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name   VARCHAR(100) NOT NULL,
    country         VARCHAR(50)  NOT NULL,
    lead_time_days  INT          NOT NULL,
    reliability_pct DECIMAL(5,2) NOT NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP
);

# 	2. SKUS

CREATE TABLE skus (
    sku_id          INT AUTO_INCREMENT PRIMARY KEY,
    sku_code        VARCHAR(50)  NOT NULL UNIQUE,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50)  NOT NULL,
    unit_cost       DECIMAL(10,2) NOT NULL,
    unit_price      DECIMAL(10,2) NOT NULL,
    weight_kg       DECIMAL(6,3) NOT NULL,
    abc_class       CHAR(1)      NOT NULL,
    supplier_id     INT,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

#	3. PURCHASE_ORDERS (PO)

CREATE TABLE purchase_orders (
    po_id           INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id     INT          NOT NULL,
    sku_id          INT          NOT NULL,
    ordered_qty     INT          NOT NULL,
    unit_cost       DECIMAL(10,2) NOT NULL,
    status          VARCHAR(20)  NOT NULL DEFAULT 'pending',
    order_date      DATETIME     NOT NULL,
    expected_date   DATETIME     NOT NULL,
    actual_date     DATETIME     NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (sku_id)      REFERENCES skus(sku_id)
);

#	4. EMPLOYEES

CREATE TABLE employees (
    employee_id     INT AUTO_INCREMENT PRIMARY KEY,
    employee_code   VARCHAR(20)  NOT NULL UNIQUE,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    role            VARCHAR(20)  NOT NULL,
    shift           VARCHAR(20)  NOT NULL,
    hire_date       DATE         NOT NULL,
    is_active       BOOLEAN      DEFAULT TRUE,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP
);

-- 5. RECEIVING_LOG

CREATE TABLE receiving_log (
    receiving_id    INT AUTO_INCREMENT PRIMARY KEY,
    po_id           INT          NOT NULL,
    sku_id          INT          NOT NULL,
    employee_id     INT          NOT NULL,  -- kto przyjął towar
    received_qty    INT          NOT NULL,  -- ile faktycznie przyjęto
    damaged_qty     INT          NOT NULL DEFAULT 0,  -- ile było uszkodzone
    received_at     DATETIME     NOT NULL,  -- kiedy przyjęto
    putaway_at      DATETIME     NULL,      -- kiedy odłożono na miejsce (NULL = w trakcie)
    location_code   VARCHAR(20)  NULL,      -- np. 'A-01-03' (rząd A, regał 01, półka 03)
    notes           TEXT         NULL,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (po_id)         REFERENCES purchase_orders(po_id),
    FOREIGN KEY (sku_id)        REFERENCES skus(sku_id),
    FOREIGN KEY (employee_id)   REFERENCES employees(employee_id)
);

-- 6. INVENTORY

CREATE TABLE inventory (
    inventory_id        INT AUTO_INCREMENT PRIMARY KEY,
    sku_id              INT          NOT NULL UNIQUE,
    quantity_on_hand    INT          NOT NULL DEFAULT 0,
    quantity_reserved   INT          NOT NULL DEFAULT 0,
	quantity_available  INT          NULL,
    reorder_point       INT          NOT NULL DEFAULT 10,
    last_updated        DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (sku_id) REFERENCES skus(sku_id)
);

-- 7. CUSTOMER_ORDERS

CREATE TABLE customer_orders (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    order_code      VARCHAR(20)  NOT NULL UNIQUE,  -- np. 'ORD-20240115-00123'
    customer_id     INT          NOT NULL,          -- ID klienta (zewnętrzny system CRM)
    sku_id          INT          NOT NULL,
    quantity        INT          NOT NULL,
    unit_price      DECIMAL(10,2) NOT NULL,
    total_value     DECIMAL(10,2) NOT NULL,
    channel         VARCHAR(20)  NOT NULL,
    status          VARCHAR(20)  NOT NULL DEFAULT 'new',
    order_date      DATETIME     NOT NULL,
    required_date   DATETIME     NULL,              -- kiedy klient chce dostawy
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sku_id) REFERENCES skus(sku_id)
);

-- 8. PICK_ORDERS

CREATE TABLE pick_orders (
    pick_id         INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT          NOT NULL,
    employee_id     INT          NOT NULL,  -- kto kompletował
    sku_id          INT          NOT NULL,
    qty_requested   INT          NOT NULL,
    qty_picked      INT          NOT NULL,
    is_correct      BOOLEAN      NOT NULL DEFAULT TRUE,
    error_type      VARCHAR(50)  NULL,  -- 'wrong_item', 'wrong_qty', 'damaged'
    started_at      DATETIME     NOT NULL,
    completed_at    DATETIME     NULL,   -- NULL = jeszcze w trakcie
    lines_picked    INT          NOT NULL DEFAULT 1,
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id)    REFERENCES customer_orders(order_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (sku_id)      REFERENCES skus(sku_id)
);

-- 9. SHIPMENTS

CREATE TABLE shipments (
    shipment_id     INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT          NOT NULL,
    carrier         VARCHAR(20)  NOT NULL,
    tracking_number VARCHAR(50)  NULL,
    shipping_cost   DECIMAL(8,2) NOT NULL,
    weight_kg       DECIMAL(6,3) NOT NULL,
    ship_date       DATETIME     NOT NULL,   -- kiedy wysłaliśmy
    estimated_date  DATETIME     NOT NULL,   -- obiecana data dostawy
    actual_date     DATETIME     NULL,       -- kiedy faktycznie dotarło
    sla_days        INT          NOT NULL,
    is_on_time      BOOLEAN      NULL,       -- obliczone po dostawie
    created_at      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES customer_orders(order_id)
);
