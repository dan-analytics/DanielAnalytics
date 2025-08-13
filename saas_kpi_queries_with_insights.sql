-- SaaS KPI Analysis Project
-- Author: Daniel Tapia
-- Objective: Extract key performance indicators (KPIs) from billing_data to support dashboarding, strategic decisions, and operational improvements.

-- Dataset: billing_data
-- Description: Contains subscription, billing, usage, and payment information for a SaaS product.

/* KPI 1: Total Active Revenue */
-- Business Insight: Snapshot of current recurring revenue from live subscriptions.
-- Use Case: Helps finance and RevOps teams assess real-time revenue health.
SELECT SUM(plan_price) AS active_revenue
FROM billing_data
WHERE subscription_status = 'Active';

/* KPI 2: Monthly Recurring Revenue (MRR) */
-- Business Insight: Tracks predictable monthly revenue from active customers.
-- Use Case: Core metric for growth tracking, forecasting, and investor reporting.
SELECT billing_period, SUM(plan_price) AS mrr
FROM billing_data
WHERE billing_cycle = 'Monthly' AND subscription_status = 'Active'
GROUP BY billing_period
ORDER BY billing_period;

/* KPI 3: Annual Recurring Revenue (ARR) */
-- Business Insight: Projects long-term revenue based on current subscriptions.
-- Use Case: Used in company valuation, strategic planning, and board reporting.
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

/* KPI 4: Churn Rate by Month */
-- Business Insight: Measures customer attrition over time.
-- Use Case: Identifies retention issues and evaluates impact of product or support changes.
SELECT billing_period,
       COUNT(*) FILTER (WHERE subscription_status = 'Cancelled') * 1.0 /
       COUNT(*) AS churn_rate
FROM billing_data
GROUP BY billing_period
ORDER BY billing_period;

/* KPI 5: Retention Rate by Month */
-- Business Insight: Tracks customer loyalty and product stickiness.
-- Use Case: Complements churn analysis and helps assess long-term customer value.
SELECT billing_period,
       COUNT(*) FILTER (WHERE subscription_status = 'Active') * 1.0 /
       COUNT(*) AS retention_rate
FROM billing_data
GROUP BY billing_period
ORDER BY billing_period;

/* KPI 6: Failed Payment Rate */
-- Business Insight: Monitors billing system reliability and potential revenue leakage.
-- Use Case: Flags technical issues or customer friction in the payment process.
SELECT billing_period,
       COUNT(*) FILTER (WHERE payment_status = 'Failed') * 100.0 /
       COUNT(*) AS failed_payment_rate
FROM billing_data
GROUP BY billing_period
ORDER BY billing_period;

/* KPI 7: Top Customers by Usage */
-- Business Insight: Identifies high-value users for upsell, or feedback.
-- Use Case: Supports customer success, marketing, and account management strategies.
SELECT order_id, SUM(usage_amount) AS total_usage
FROM billing_data
GROUP BY order_id
ORDER BY total_usage DESC
LIMIT 5;

/* KPI 8: Long-Term Inactive Subscriptions */
-- Business Insight: Flags dormant accounts for re-engagement or cleanup.
-- Use Case: Helps reduce data noise and target win-back campaigns.
SELECT *
FROM billing_data
WHERE signup_date::DATE < CURRENT_DATE - INTERVAL '2 years'
ORDER BY signup_date::DATE;

/* KPI 9: Monthly Revenue Trends */
-- Business Insight: Reveals growth patterns, seasonality, and marketing impact.
-- Use Case: Supports strategic planning and campaign performance analysis.
SELECT billing_period, SUM(plan_price) AS monthly_revenue
FROM billing_data
GROUP BY billing_period
ORDER BY billing_period;

/* KPI 10: Repeat Payment Failures */
-- Business Insight: Flags accounts with recurring payment issues.
-- Use Case: Enables proactive outreach, dunning workflows, or account suspension.
SELECT order_id, COUNT(*) AS failed_count
FROM billing_data
WHERE payment_status = 'Failed'
GROUP BY order_id
HAVING COUNT(*) > 2;
