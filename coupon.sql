CREATE TABLE coupons(
  coupon_id smallint PRIMARY KEY,
  code varchar(10),
  discount real,
  min_freight real,
  valid_date date,
  expired_date date
);
