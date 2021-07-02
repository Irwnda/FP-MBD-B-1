CREATE TABLE coupons(
  coupon_code varchar(10) PRIMARY KEY,
  discount real,
  min_freight real,
  valid_date date,
  expired_date date
);
