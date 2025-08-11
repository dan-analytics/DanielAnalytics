-- SaaS KPI Analysis Project
-- Author: Daniel Tapia
-- Objective: Extract key performance indicators (KPIs) from billing_data for dashboarding and business insight

-- Dataset: billing_data
-- Description: Contains subscription, billing, usage, and payment information for a SaaS product

/* 🔹 KPI 1: Total Active Revenue */
-- Business Insight: Snapshot of current live revenue from active subscriptions
SELECT SUM(plan_price) AS active_revenue
FROM billing_data
WHERE subscription_status = 'Active';

/* 🔹 KPI 2: Monthly Recurring Revenue (MRR) */
-- Business Insight: Tracks MRR over time to monitor growth, retention, and acquisition impact
SELECT billing_period, SUM(plan_price) AS mrr
FROM billing_data
WHERE billing_cycle = 'Monthly' AND subscription_status = 'Active'
GROUP BY billing_period
ORDER BY billing_period;

/* 🔹 KPI 3: Annual Recurring Revenue (ARR) */
-- Business Insight: Long-term revenue metric used for valuation and strategic planning
SELECT 
  SUM(
    CASE 
      WHEN billing_cycle = 'Monthly' THEN plan_price * 12
      WHEN billing_cycle = 'Annual' THEN plan_price
      ELSE 0
    END
  ) AS arr
FROM billing_data
WHERE subscription_status = 'Active';

/* 🔹 KPI 4: Churn Rate by Month */
-- Business Insight: Measures customer loss over time; high churn signals retention issues
SELECT billing_period,
       COUNT(*) FILTER (WHERE subscription_status = 'Cancelled') * 1.0 /
       COUNT(*) AS churn_rate
FROM billing_data
GROUP BY billing_period
ORDER BY billing_period;

/* 🔹 KPI 5: Retention Rate by Month */
-- Business Insight: Indicates customer loyalty and product value
SELECT billing_period,
       COUNT(*) FILTER (WHERE subscription_status = 'Active') * 1.0 /
       COUNT(*) AS retention_rate
FROM billing_data
GROUP BY billing_period
ORDER BY billing_period;

/* 🔹 KPI 6: Failed Payment Rate */
-- Business Insight: Identifies billing system issues and potential cash flow risks
SELECT billing_period,
       COUNT(*) FILTER (WHERE payment_status = 'Failed') * 1.0 /
       COUNT(*) AS failed_payment_rate
FROM billing_data
GROUP BY billing_period
ORDER BY billing_period;

/* 🔹 KPI 7: Top Customers by Usage */
-- Business Insight: Highlights power users for upselling, case studies, or feedback
SELECT order_id, SUM(usage_amount) AS total_usage
FROM billing_data
GROUP BY order_id
ORDER BY total_usage DESC
LIMIT 5;

/* 🔹 KPI 8: Long-Term Inactive Subscriptions */
-- Business Insight: Flags stale accounts for re-engagement campaigns or cleanup
SELECT *
FROM billing_data
WHERE signup_date::DATE < CURRENT_DATE - INTERVAL '2 years'
ORDER BY signup_date::DATE;

/* 🔹 KPI 9: Monthly Revenue Trends */
-- Business Insight: Reveals growth patterns, seasonality, and marketing impact
SELECT billing_period, SUM(plan_price) AS monthly_revenue
FROM billing_data
GROUP BY billing_period
ORDER BY billing_period;

/* 🔹 KPI 10: Repeat Payment Failures */
-- Business Insight: Flags risky accounts for intervention (e.g., dunning emails or suspension)
SELECT order_id, COUNT(*) AS failed_count
FROM billing_data
WHERE payment_status = 'Failed'
GROUP BY order_id
HAVING COUNT(*) > 2;