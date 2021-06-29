CREATE OR REPLACE PROCEDURE add_order(p_order_id smallint, p_customer_id bpchar, p_employee_id smallint, p_order_date date, p_required_date date, p_shipped_date date, p_ship_via smallint, p_freight real)
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
        RAISE NOTICE 'tidak ditemukan';
    END IF;
END; $$