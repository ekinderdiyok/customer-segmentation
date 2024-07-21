
CREATE TABLE brands
(
  brand_id   SERIAL      ,
  brand_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (brand_id)
);

CREATE TABLE customer_loyalty
(
  customer_id           SERIAL NOT NULL,
  program_id            SERIAL NOT NULL,
  membership_start_date DATE   NOT NULL
);

CREATE TABLE customers
(
  customer_id       SERIAL       NOT NULL,
  name              VARCHAR(100),
  email             VARCHAR(100) NOT NULL UNIQUE,
  registration_date DATE         DEFAULT CURRENT_DATE,
  gender            CHAR(1)     ,
  birth_date        DATE        ,
  is_newsletter     BOOLEAN      DEFAULT FALSE,
  postal_code       VARCHAR(10) ,
  country_code      CHAR(2)     ,
  is_plus_member    BOOLEAN      DEFAULT FALSE,
  PRIMARY KEY (customer_id)
);

CREATE TABLE loyalty_programs
(
  program_id   SERIAL      ,
  program_name VARCHAR(100) NOT NULL,
  description  TEXT        ,
  PRIMARY KEY (program_id)
);

CREATE TABLE order_brands
(
  order_id SERIAL NOT NULL,
  brand_id SERIAL NOT NULL
);

CREATE TABLE orders
(
  order_id     SERIAL       ,
  customer_id  SERIAL        NOT NULL,
  order_date   DATE          DEFAULT CURRENT_DATE,
  total_amount DECIMAL(10,2) NOT NULL,
  is_onsite    BOOLEAN       DEFAULT FALSE,
  PRIMARY KEY (order_id)
);

ALTER TABLE orders
  ADD CONSTRAINT FK_customers_TO_orders
    FOREIGN KEY (customer_id)
    REFERENCES customers (customer_id);

ALTER TABLE order_brands
  ADD CONSTRAINT FK_orders_TO_order_brands
    FOREIGN KEY (order_id)
    REFERENCES orders (order_id);

ALTER TABLE customer_loyalty
  ADD CONSTRAINT FK_customers_TO_customer_loyalty
    FOREIGN KEY (customer_id)
    REFERENCES customers (customer_id);

ALTER TABLE customer_loyalty
  ADD CONSTRAINT FK_loyalty_programs_TO_customer_loyalty
    FOREIGN KEY (program_id)
    REFERENCES loyalty_programs (program_id);

ALTER TABLE order_brands
  ADD CONSTRAINT FK_brands_TO_order_brands
    FOREIGN KEY (brand_id)
    REFERENCES brands (brand_id);
