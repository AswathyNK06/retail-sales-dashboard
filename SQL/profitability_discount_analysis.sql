-- sql/profitability_discount_analysis.sql
-- Purpose: Product, region, and discount-level profitability analysis
-- This view supports validation and deeper analysis for the Tableau dashboard.
-- Final Tableau dashboard should primarily use analytics.retail_base.

CREATE OR REPLACE VIEW analytics.profitability_discount_analysis AS
SELECT
    order_month,
    region_name,
    category,
    product_name,

    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity) AS total_units,

    SUM(gross_revenue) AS gross_revenue,
    SUM(discount_amount) AS total_discount,
    SUM(net_revenue) AS net_revenue,
    SUM(profit) AS total_profit,

    SUM(profit) / NULLIF(SUM(net_revenue), 0) AS profit_margin,
    SUM(discount_amount) / NULLIF(SUM(gross_revenue), 0) AS discount_pct,
    SUM(net_revenue) / NULLIF(COUNT(DISTINCT order_id), 0) AS avg_order_value,
    SUM(net_revenue) / NULLIF(COUNT(DISTINCT customer_id), 0) AS revenue_per_customer

FROM analytics.retail_base
GROUP BY
    order_month,
    region_name,
    category,
    product_name;