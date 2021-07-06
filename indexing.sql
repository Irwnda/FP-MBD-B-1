CREATE INDEX customer_cid on customers(customer_id);
CREATE INDEX orders_oid on orders(order_id);
CREATE INDEX products_pid on products(product_id);
CREATE INDEX employees_eid on employees(employee_id);
CREATE INDEX coupons_cc on coupons(coupon_code);

DROP INDEX customer_cid;
DROP INDEX orders_oid;
DROP INDEX products_pid;
DROP INDEX employees_eid;
DROP INDEX coupons_cc;
