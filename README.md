# Retail Sales Dashboard

## Project Overview
This project analyses retail sales performance across regions, categories and products using SQL (PostgreSQL) and Tableau. The dashboard is designed to support interactive business analysis through dynamic filtering and drill-down capabilities.

## Business Problem
Retail leadership often sees high-level sales numbers but struggles to quickly understand why the performance is changing. This project is designed to answer questions such as:
- Is revenue growing or declining over time?
- Which regions are driving growth and which are underperforming?
- Which categories and products are contributing most to revenue and profit?
- Is growth healthy, or is it being driven by discounting and lower margins?

## Stakeholders
This project is designed for:
- Senior leadership
- Regional managers
- Category / product managers

## Data Used
The project uses a retail dataset with the following source tables:
- `public.orders`
- `public.customers`
- `public.products`
- `public.regions`

The dataset is stored in the `data/` folder as CSV files.

## Data Model
Raw tables are stored in the `public` schema.

Analytical views are created in the `analytics` schema:
- `analytics.retail_base` (primary Tableau dashboard source)
- `analytics.kpi_monthly`
- `analytics.kpi_region`
- `analytics.kpi_product`

The final Tableau dashboard is built primarily from `analytics.retail_base`, which is the lowest-grain analytical view. This allows the dashboard filters, such as month and region, to work consistently across KPIs, trends and regional views.

The KPI views are retained as supporting analytical views for validation, faster aggregation checks and comparison during development.

## Grain
The main analytical base (`analytics.retail_base`) is built at:
- one row per order-product combination

This allows flexible analysis by month, region, category and product.
This became the primary Tableau data source because it supports flexible filtering across month, region, category and product.

## Key Metrics
The project tracks:
- Revenue
- Units sold
- Profit
- Margin: calculated as SUM(profit) / SUM(net revenue), not as a sum of row-level margins
- Gross revenue
- Discount amount
- Discount percentage: calculated as SUM(discount amount) / SUM(gross revenue)
- Average selling price
- MoM growth
- YoY growth

## SQL Views Built

### 1. `retail_base`
Primary analytical view used for the final Tableau dashboard. It is built at order-line level and includes cleaned business-ready fields such as gross revenue, net revenue, discount amount, cost, profit, margin, region, category and product.

### 2. `kpi_monthly`
Supporting KPI view used to validate monthly performance metrics and growth calculations such as MoM and YoY changes.

### 3. `kpi_region`
Supporting regional KPI view used to validate region-level revenue, profit and margin calculations.

### 4. `kpi_product`
Supporting product-level KPI view used to validate category and product performance calculations.

## Tools Used
- PostgreSQL
- pgAdmin 4
- VS Code
- Git / GitHub
- Tableau

## Repository Structure
```text
retail-sales-dashboard
│
├── data
│   ├── customers.csv
│   ├── orders.csv
│   ├── products.csv
│   ├── regions.csv
│
├── SQL
│   ├── 01_schema
│   │   └── schema.sql
│   ├── base_table.sql
│   ├── kpi_monthly.sql
│   ├── kpi_region.sql
│   └── kpi_product.sql
│
└── README.md
