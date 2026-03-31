CREATE SCHEMA IF NOT EXISTS analytics;

DROP TABLE IF EXISTS public.orders;
DROP TABLE IF EXISTS public.products;
DROP TABLE IF EXISTS public.customers;
DROP TABLE IF EXISTS public.regions;

CREATE TABLE public.regions (
    region_id INT PRIMARY KEY,
    region_name TEXT NOT NULL
);

CREATE TABLE public.customers (
    customer_id INT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    customer_segment TEXT,
    region_id INT NOT NULL REFERENCES public.regions(region_id)
);

CREATE TABLE public.products (
    product_id INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    cost_per_unit NUMERIC(10,2) NOT NULL
);

CREATE TABLE public.orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL REFERENCES public.customers(customer_id),
    product_id INT NOT NULL REFERENCES public.products(product_id),
    region_id INT NOT NULL REFERENCES public.regions(region_id),
    quantity NUMERIC(10,2) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    discount_amount NUMERIC(10,2) NOT NULL
);

CREATE INDEX idx_orders_order_date ON public.orders(order_date);
CREATE INDEX idx_orders_region_id ON public.orders(region_id);
CREATE INDEX idx_orders_product_id ON public.orders(product_id);
CREATE INDEX idx_orders_customer_id ON public.orders(customer_id);