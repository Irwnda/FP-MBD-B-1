-- ======================================================================================= --

CREATE SEQUENCE IF NOT EXISTS seq_order_id
AS INT
START 756854;

-- DROP SEQUENCE seq_order_id;

-- ======================================================================================= --

CREATE OR REPLACE PROCEDURE add_order(p_customer_id bpchar, p_employee_id smallint, p_order_date date, p_required_date date, p_shipped_date date, p_ship_via smallint, p_freight real, p_coupon VARCHAR(10))
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO orders (order_id, customer_id, employee_id, order_date, required_date, shipped_date, ship_via, freight, coupon_code)
    VALUES(0, p_customer_id, p_employee_id, p_order_date, p_required_date, p_shipped_date, p_ship_via, p_freight, p_coupon);
END; $$;

-- ======================================================================================= --

CREATE OR REPLACE FUNCTION add_new_order()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
    v_ship_name character varying(40);
    v_ship_address character varying(60);
    v_ship_city character varying(100);
    v_ship_region character varying(100);
    v_ship_postal_code character varying(30);
    v_ship_country character varying(100);
    
    v_total_price REAL;
    v_discount REAL;
    kupon_berlaku DATE;
    kupon_kadaluarsa DATE;
    min_beli REAL;
BEGIN
    SELECT company_name, address, city, region, postal_code, country
    INTO v_ship_name, v_ship_address, v_ship_city, v_ship_region, v_ship_postal_code, v_ship_country
    FROM customers
    WHERE customer_id = NEW.customer_id;

    SELECT valid_date, expired_date, min_freight, discount
    INTO kupon_berlaku, kupon_kadaluarsa, min_beli, v_discount
    FROM coupons
    WHERE coupon_code = NEW.coupon_code;

    IF NOT (NEW.order_date >= kupon_berlaku AND NEW.order_date < kupon_kadaluarsa AND NEW.freight >= min_beli) THEN
        v_discount = 0;
    END IF;

    SELECT SUM(total_price)
    INTO v_total_price
    FROM order_details
    GROUP BY order_id;

    INSERT INTO orders
    VALUES(nextval('seq_order_id'), NEW.customer_id, NEW.employee_id, NEW.order_date, NEW.required_date, NEW.shipped_date, NEW.ship_via, NEW.freight, v_ship_name, v_ship_address, v_ship_city, v_ship_region, v_ship_postal_code, v_ship_country, NEW.coupon_code, v_total_price*(1-v_discount))
    ON CONFLICT DO NOTHING;
	
	RETURN NEW;
	
	EXCEPTION
	WHEN foreign_key_violation THEN
END;
$$;

-- ======================================================================================= --

CREATE TRIGGER insert_order
BEFORE INSERT ON orders
FOR EACH ROW
WHEN (pg_trigger_depth() < 1)
EXECUTE PROCEDURE add_new_order();

-- ======================================================================================= --

-- CALL add_order('AVOELKER6V', 879::smallint, DATE('1998-09-07'), DATE('1998-09-19'), DATE(null), 2::smallint, 289, 'DJFOGQDIEW');
