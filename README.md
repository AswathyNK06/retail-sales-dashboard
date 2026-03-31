# Retail Sales Dashboard

## Project Overview
This project analyses retail sales performance across regions, categories and products using SQL (PostgreSQL) and Tableau. The goal is to help business stakeholders understand overall performance trends, identify what is driving revenue and profit changes, and highlight where action is needed.

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
- `analytics.retail_base`
- `analytics.kpi_monthly`
- `analytics.kpi_region`
- `analytics.kpi_product`

## Grain
The main analytical base is built at:
- one row per order per product

This allows flexible analysis by month, region, category and product.

## Key Metrics
The project tracks:
- Revenue
- Units sold
- Profit
- Margin
- Gross revenue
- Discount amount
- Discount percentage
- Average selling price
- MoM growth
- YoY growth

## SQL Views Built

### 1. `retail_base`
A clean analytical base created from the raw transactional tables. It joins source tables and calculates business-ready measures such as gross revenue, net revenue, cost, profit and margin.

### 2. `kpi_monthly`
Monthly KPI view used to analyse overall business performance over time. Includes MoM and YoY changes for revenue, units sold, profit, average selling price and discount percentage.

### 3. `kpi_region`
Regional monthly KPI view used to compare region-level performance.

### 4. `kpi_product`
Category + product + month KPI view used to analyse product-level and category-level performance trends.

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