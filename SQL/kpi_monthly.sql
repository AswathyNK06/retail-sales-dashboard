-- sql/kpi_monthly.sql
-- Purpose:
-- Create monthly KPIs with MoM and YoY growth
-- Built on top of the single analytical base (retail_base)


CREATE OR REPLACE VIEW analytics.kpi_monthly AS

-- STEP 1: Aggregate order-line data to month level
WITH monthly_agg AS (
    SELECT
        order_month,                         -- month (e.g. 2025-01-01)
        
        -- Core KPIs
        SUM(net_revenue) AS revenue,         -- total revenue for the month
        SUM(quantity) AS units_sold,          -- total units sold
        SUM(profit) AS profit,               -- total profit
        
        -- Margin at monthly level
        CASE
            WHEN SUM(net_revenue) = 0 THEN NULL
            ELSE SUM(profit) / SUM(net_revenue)
        END AS margin, -- Note: monthly margin here is not “average of row margins”. It is profit sum divided by revenue sum. That is correct.
        
        COUNT(DISTINCT order_id) AS orders    -- number of orders
    FROM analytics.retail_base
    GROUP BY order_month
),

-- STEP 2: Add previous month values using window functions
mom_calc AS (
    SELECT
        ma.*,

        -- Revenue last month
        LAG(revenue) OVER (ORDER BY order_month) AS prev_month_revenue,

        -- Profit last month
        LAG(profit) OVER (ORDER BY order_month) AS prev_month_profit

    FROM monthly_agg ma
),

-- STEP 3: Add same-month-last-year values
yoy_calc AS (
    SELECT
        mc.*,

        -- Revenue in the same month last year
        LAG(revenue, 12) OVER (ORDER BY order_month) AS prev_year_revenue,
	-- LAG(revenue,12) means “12 rows back”

        -- Profit in the same month last year
        LAG(profit, 12) OVER (ORDER BY order_month) AS prev_year_profit

    FROM mom_calc mc
)

-- STEP 4: Final select with growth calculations
SELECT
    order_month,
    revenue,
    units_sold,
    profit,
    margin,
    orders,

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

    -- Month-on-Month profit growth
    CASE
        WHEN prev_month_profit IS NULL OR prev_month_profit = 0 THEN NULL
        ELSE (profit - prev_month_profit) / prev_month_profit
    END AS profit_mom_growth,

    -- Year-on-Year profit growth
    CASE
        WHEN prev_year_profit IS NULL OR prev_year_profit = 0 THEN NULL
        ELSE (profit - prev_year_profit) / prev_year_profit
    END AS profit_yoy_growth

FROM yoy_calc
ORDER BY order_month;
