CREATE TABLE coupon(
  code varchar(10),
  product_id smallint,
  discount real,
  min_quantity smallint,
  valid_date date,
  expired_date date
);
