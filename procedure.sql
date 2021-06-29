CREATE OR REPLACE PROCEDURE add_order(p_order_id int, p_customer_id bpchar, p_employee_id smallint, p_order_date date, p_required_date date, p_shipped_date date, p_ship_via smallint, p_freight real)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ship_name character varying(40);
    v_ship_address character varying(60);
    v_ship_city character varying(15);
    v_ship_region character varying(15);
    v_ship_postal_code character varying(10);
    v_ship_country character varying(15);
BEGIN
    SELECT company_name, address, city, region, postal_code, country
    INTO v_ship_name, v_ship_address, v_ship_city, v_ship_region, v_ship_postal_code, v_ship_country
    FROM customers
    WHERE customer_id = p_customer_id;

    IF FOUND THEN
        INSERT INTO orders
        VALUES(p_order_id, p_customer_id, p_employee_id, p_order_date, p_required_date, p_shipped_date, p_ship_via, p_freight, v_ship_name, v_ship_address, v_ship_city, v_ship_region, v_ship_postal_code, v_ship_country);
    ELSE
        RAISE NOTICE '% tidak ditemukan', customer_id;
    END IF;
END; $$;

-- ======================================================================================================== --
CREATE OR REPLACE PROCEDURE add_total_price_order_details()
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_price REAL;
    v_unit_price REAL;
    v_discount REAL;
    v_quantity SMALLINT;
    idn record;

BEGIN
    FOR idn IN
        (SELECT order_id, product_id
        FROM order_details)
    LOOP
        SELECT unit_price, quantity, discount
        INTO v_unit_price, v_quantity, v_discount
        FROM order_details od
        WHERE idn.order_id = od.order_id AND idn.product_id = od.product_id;
		
        SELECT v_unit_price*v_quantity*(1-v_discount) INTO v_total_price;
		
		
        UPDATE order_details
        SET total_price = ROUND(v_total_price::NUMERIC,2)
        WHERE order_id = idn.order_id AND product_id = idn.product_id;
    END LOOP;
END; $$;

CALL add_total_price_order_details();
-- ======================================================================================================== --
CREATE OR REPLACE PROCEDURE add_order_detail(p_order_id int, p_product_id smallint, p_quantity smallint, p_coupon_code VARCHAR(10))
LANGUAGE plpgsql
AS $$
DECLARE
    v_unit_price REAL;
    v_total_price REAL;
    v_discount REAL;

    tanggal_beli DATE;
    kupon_berlaku DATE;
    kupon_kadaluarsa DATE;
    min_beli smallint;

BEGIN
    SELECT unit_price
    INTO v_unit_price
    FROM products
    WHERE p_product_id = product_id;

    SELECT order_date
    INTO tanggal_beli
    FROM orders
    WHERE order_id = p_order_id;

    SELECT valid_date, expired_date, min_quantity, discount
    INTO kupon_berlaku, kupon_kadaluarsa, min_beli, v_discount
    FROM coupons
    WHERE p_coupon_code = code;

    IF NOT (tanggal_beli >= kupon_berlaku AND tanggal_beli < kupon_kadaluarsa AND p_quantity >= min_beli) THEN
        v_discount = 0;
    END IF;

    SELECT v_unit_price*p_quantity*(1-v_discount) INTO v_total_price;

    INSERT INTO order_details 
    VALUES(p_order_id, p_product_id, v_unit_price, p_quantity, v_discount, p_coupon_code, v_total_price);
END; $$;