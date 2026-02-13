-- sql/base_table.sql
-- This view creates a single, clean analytical base
-- Grain: one row per order per product (order line level)

CREATE OR REPLACE VIEW analytics.retail_base AS

-- STEP 1: Clean the raw orders table
WITH cleaned_orders AS (
    SELECT
        o.order_id,                           -- unique identifier for the order
        CAST(o.order_date AS DATE) AS order_date,  -- order_date in timestamp format, we need it in date format
        o.customer_id,                        -- who placed the order
        o.product_id,                         -- what product was sold
        o.region_id,                          -- where it was sold

        -- Convert quantity and price to numeric to avoid calculation issues
        CAST(o.quantity AS NUMERIC) AS quantity,
        CAST(o.unit_price AS NUMERIC) AS unit_price,

        -- If discount is NULL, treat it as zero
        COALESCE(CAST(o.discount_amount AS NUMERIC), 0) AS discount_amount

    FROM orders o

    -- Basic data quality filters
    WHERE o.order_id IS NOT NULL
      AND o.order_date IS NOT NULL
      AND o.customer_id IS NOT NULL
      AND o.product_id IS NOT NULL
      AND o.region_id IS NOT NULL
      AND o.quantity IS NOT NULL
      AND o.unit_price IS NOT NULL
),

-- STEP 2: Join dimension tables and calculate business metrics
enriched_orders AS (
    SELECT
        co.order_id,
        co.order_date,

        -- Create a month column for monthly aggregation
        DATE_TRUNC('month', co.order_date)::DATE AS order_month,

        -- Customer details
        co.customer_id,
        c.customer_name,
        c.customer_segment,

        -- Product details
        co.product_id,
        p.product_name,
        p.category,
        p.cost_per_unit,

        -- Region details
        co.region_id,
        r.region_name,

        -- Transaction-level details
        co.quantity,
        co.unit_price,
        co.discount_amount,

        -- Revenue before discount
        (co.quantity * co.unit_price) AS gross_revenue,

        -- Revenue after discount (this is the real revenue)
        (co.quantity * co.unit_price) - co.discount_amount AS net_revenue,

        -- Cost of goods sold
        (co.quantity * p.cost_per_unit) AS cost_amount,

        -- Profit = revenue minus cost
        ((co.quantity * co.unit_price) - co.discount_amount)
            - (co.quantity * p.cost_per_unit) AS profit

    FROM cleaned_orders co

    -- Join product table to get category and cost
    LEFT JOIN products p
        ON co.product_id = p.product_id

    -- Join customer table (names useful for drill-down, not default views)
    LEFT JOIN customers c
        ON co.customer_id = c.customer_id

    -- Join region table
    LEFT JOIN regions r
        ON co.region_id = r.region_id
)

-- STEP 3: Final select with margin calculation
SELECT
    eo.*,

    -- Margin = profit divided by revenue
    -- Protect against divide-by-zero
eo.profit * 1.0 / NULLIF(eo.net_revenue, 0) AS margin

FROM enriched_orders eo;
