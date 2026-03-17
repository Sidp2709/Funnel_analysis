SELECT * FROM `project-0a1ab0bf-6de2-4411-834.SQL_Practice.User Events` LIMIT 1000

--Definind sales funnel and its stages -- 

WITH funnel_stages AS (

  SELECT
    COUNT(CASE WHEN event_type = 'page_view' THEN user_id END) AS stage1_views,
    COUNT(CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage2_cart,
    COUNT(CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage3_checkout_start,
    COUNT(CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage4_payment_info,
    COUNT(CASE WHEN event_type = 'purchase' THEN user_id END) AS stage5_purchaae,
  FROM `project-0a1ab0bf-6de2-4411-834.SQL_Practice.User Events`

--I want the data from the last 20 days since January 30, 2026 --

  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE '2026-1-30', INTERVAL 20 DAY))
)

SELECT * FROM funnel_stages

WITH funnel_stages AS (

  SELECT
    COUNT(CASE WHEN event_type = 'page_view' THEN user_id END) AS stage1_views,
    COUNT(CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage2_cart,
    COUNT(CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage3_checkout_start,
    COUNT(CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage4_payment_info,
    COUNT(CASE WHEN event_type = 'purchase' THEN user_id END) AS stage5_purchaae,
  FROM `project-0a1ab0bf-6de2-4411-834.SQL_Practice.User Events`

--I want the data from the last 20 days since January 30, 2026 --

  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE '2026-1-30', INTERVAL 20 DAY))
)



SELECT 

  stage1_views,
  stage2_cart,
  ROUND(stage2_cart * 100 / stage1_views) AS view_to_cart_rate,

  stage3_checkout_start,
  ROUND(stage3_checkout_start * 100 / stage2_cart) AS cart_to_checkout_rate,

  stage4_payment_info,
  ROUND(stage4_payment_info * 100 / stage3_checkout_start) AS checkout_to_payment_info_rate,

  stage5_purchaae,
  ROUND(stage5_purchaae * 100 / stage4_payment_info) AS payment_info_to_purchase_rate,

  ROUND(stage5_purchaae * 100 / stage1_views) AS view_to_purchase_rate,

FROM funnel_stages


WITH source_funnel AS (
  SELECT 
    traffic_source,
    COUNT( DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
    COUNT( DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS cart,
    COUNT( DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase,

  FROM `project-0a1ab0bf-6de2-4411-834.SQL_Practice.User Events`
    
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE '2026-1-30', INTERVAL 20 DAY))

  GROUP BY  traffic_source 

)

SELECT

  traffic_source,
  views,
  cart,
  purchase,
  ROUND(cart * 100 / views) AS cart_conv_rate,
  ROUND(purchase * 100 / cart) AS purchase_conv_rate,
  ROUND(purchase * 100 / views) AS cart_to_purchase_conv_rate
FROM source_funnel
ORDER BY purchase DESC

--time to conversion analysis --

WITH user_journey AS (  
    SELECT 
    user_id,
    MIN(CASE WHEN event_type = 'page_view' THEN event_date END) AS view_time,
    MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END) AS cart_time,
    MIN(CASE WHEN event_type = 'purchase' THEN event_date END) AS purchase_time

  FROM `project-0a1ab0bf-6de2-4411-834.SQL_Practice.User Events`
    
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE '2026-1-30', INTERVAL 20 DAY))

  GROUP BY  user_id 
  HAVING MIN( CASE WHEN event_type = 'purchase' THEN event_date END) IS NOT NULL
)

SELECT
  COUNT(*) AS converted_users,

  ROUND(AVG(TIMESTAMP_DIFF(cart_time, view_time, MINUTE)),2) AS avg_minutes_view_to_cart,
  ROUND(AVG(TIMESTAMP_DIFF(purchase_time, cart_time, MINUTE)),2) AS avg_minutes_cart_to_purchase,
  ROUND(AVG(TIMESTAMP_DIFF(purchase_time, view_time, MINUTE)),2) AS avg_minutes_total_journey

FROM user_journey

--revenue funnel analysis --

WITH funnel_revenue AS (  
    SELECT 
      COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,
      COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS total_buyers,
      ROUND(SUM(CASE WHEN event_type = 'purchase' THEN amount END),2) AS total_revenue,
      COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS total_orders

    FROM `project-0a1ab0bf-6de2-4411-834.SQL_Practice.User Events`
    
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE '2026-1-30', INTERVAL 20 DAY))
)

SELECT
  total_visitors,
  total_buyers,
  total_revenue,
  total_orders,
  ROUND(total_revenue / total_orders,2) AS avg_order_value,
  ROUND(total_revenue / total_buyers,2) AS revenue_per_buyer,
  ROUND(total_revenue / total_visitors,2) AS revenue_per_visitor,


FROM funnel_revenue