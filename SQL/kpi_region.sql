-- sql/kpi_region.sql
-- Purpose:
-- Create regional monthly KPIs with MoM and YoY growth
-- Built on top of the single analytical base (retail_base)

CREATE OR REPLACE VIEW analytics.kpi_region AS

-- STEP 1: Aggregate order-line data to region + month level
WITH region_agg AS (
    SELECT
        region_name,                         -- region (e.g. North, South)
        order_month,                         -- month (e.g. 2025-01-01)

        -- Core KPIs
        SUM(net_revenue) AS revenue,         -- total revenue for the region in that month
        SUM(quantity) AS units_sold,         -- total units sold
        SUM(profit) AS profit,               -- total profit

        -- Margin at region-month level
        CASE
            WHEN SUM(net_revenue) = 0 THEN NULL
            ELSE SUM(profit) / SUM(net_revenue)
        END AS margin,

        COUNT(DISTINCT order_id) AS orders,  -- number of distinct orders

        -- total discount amount for that region-month
        SUM(discount_amount) AS total_discount,

        -- total revenue before discount
        SUM(gross_revenue) AS gross_revenue,

        -- average selling price after discount
        CASE
            WHEN SUM(quantity) = 0 THEN NULL
            ELSE SUM(net_revenue) / SUM(quantity)
        END AS avg_selling_price,

        -- discount as % of gross revenue
        CASE
            WHEN SUM(gross_revenue) = 0 THEN NULL
            ELSE SUM(discount_amount) / SUM(gross_revenue)
        END AS discount_pct

    FROM analytics.retail_base
    GROUP BY region_name, order_month
),

-- STEP 2: Add previous month values using window functions
mom_calc AS (
    SELECT
        ra.*,

        -- Revenue last month for the same region
        LAG(revenue) OVER (
            PARTITION BY region_name
            ORDER BY order_month
        ) AS prev_month_revenue,

        -- Units sold last month for the same region
        LAG(units_sold) OVER (
            PARTITION BY region_name
            ORDER BY order_month
        ) AS prev_month_units_sold,

        -- Profit last month for the same region
        LAG(profit) OVER (
            PARTITION BY region_name
            ORDER BY order_month
        ) AS prev_month_profit,

        -- Average selling price last month for the same region
        LAG(avg_selling_price) OVER (
            PARTITION BY region_name
            ORDER BY order_month
        ) AS prev_month_avg_selling_price,

        -- Discount % last month for the same region
        LAG(discount_pct) OVER (
            PARTITION BY region_name
            ORDER BY order_month
        ) AS prev_month_discount_pct

    FROM region_agg ra
),

-- STEP 3: Add same-month-last-year values
yoy_calc AS (
    SELECT
        mc.*,

        -- Revenue in the same month last year for the same region
        LAG(revenue, 12) OVER (
            PARTITION BY region_name
            ORDER BY order_month
        ) AS prev_year_revenue,

        -- Units sold in the same month last year for the same region
        LAG(units_sold, 12) OVER (
            PARTITION BY region_name
            ORDER BY order_month
        ) AS prev_year_units_sold,

        -- Profit in the same month last year for the same region
        LAG(profit, 12) OVER (
            PARTITION BY region_name
            ORDER BY order_month
        ) AS prev_year_profit,

        -- Average selling price in the same month last year for the same region
        LAG(avg_selling_price, 12) OVER (
            PARTITION BY region_name
            ORDER BY order_month
        ) AS prev_year_avg_selling_price,

        -- Discount % in the same month last year for the same region
        LAG(discount_pct, 12) OVER (
            PARTITION BY region_name
            ORDER BY order_month
        ) AS prev_year_discount_pct

    FROM mom_calc mc
)

-- STEP 4: Final select with growth calculations
SELECT
    region_name,
    order_month,
    revenue,
    units_sold,
    profit,
    margin,
    orders,
    total_discount,        
    gross_revenue,         
    avg_selling_price,     
    discount_pct,          

    -- Month-on-Month revenue growth
    CASE
        WHEN prev_month_revenue IS NULL OR prev_month_revenue = 0 THEN NULL
        ELSE (revenue - prev_month_revenue) / prev_month_revenue
    END AS revenue_mom_growth,

    -- Year-on-Year revenue growth
    CASE
        WHEN prev_year_revenue IS NULL OR prev_year_revenue = 0 THEN NULL
        ELSE (revenue - prev_year_revenue) / prev_year_revenue
    END AS revenue_yoy_growth,

    -- Month-on-Month units sold growth
    CASE
        WHEN prev_month_units_sold IS NULL OR prev_month_units_sold = 0 THEN NULL
        ELSE (units_sold - prev_month_units_sold) / prev_month_units_sold
    END AS units_mom_growth,

    -- Year-on-Year units sold growth
    CASE
        WHEN prev_year_units_sold IS NULL OR prev_year_units_sold = 0 THEN NULL
        ELSE (units_sold - prev_year_units_sold) / prev_year_units_sold
    END AS units_yoy_growth,

    -- Month-on-Month profit growth
    CASE
        WHEN prev_month_profit IS NULL OR prev_month_profit = 0 THEN NULL
        ELSE (profit - prev_month_profit) / prev_month_profit
    END AS profit_mom_growth,

    -- Year-on-Year profit growth
    CASE
        WHEN prev_year_profit IS NULL OR prev_year_profit = 0 THEN NULL
        ELSE (profit - prev_year_profit) / prev_year_profit
    END AS profit_yoy_growth,

    -- Month-on-Month average selling price growth
    CASE
        WHEN prev_month_avg_selling_price IS NULL OR prev_month_avg_selling_price = 0 THEN NULL
        ELSE (avg_selling_price - prev_month_avg_selling_price) / prev_month_avg_selling_price
    END AS avg_selling_price_mom_growth,

    -- Year-on-Year average selling price growth
    CASE
        WHEN prev_year_avg_selling_price IS NULL OR prev_year_avg_selling_price = 0 THEN NULL
        ELSE (avg_selling_price - prev_year_avg_selling_price) / prev_year_avg_selling_price
    END AS avg_selling_price_yoy_growth,

    -- Month-on-Month change in discount %
    CASE
        WHEN prev_month_discount_pct IS NULL THEN NULL
        ELSE discount_pct - prev_month_discount_pct
    END AS discount_pct_mom_change,

    -- Year-on-Year change in discount %
    CASE
        WHEN prev_year_discount_pct IS NULL THEN NULL
        ELSE discount_pct - prev_year_discount_pct
    END AS discount_pct_yoy_change

FROM yoy_calc
ORDER BY region_name, order_month;