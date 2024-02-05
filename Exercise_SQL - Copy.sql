-- 1. The largest total transaction value during 2021

select
  format_datetime("%B", datetime(order_date)) as month,
  sum(after_discount) as total_transaction
from `finpro.order_detail`
  where extract(year from order_date) = 2021
  and is_valid = 1
group by 1
order by total_transaction desc;

-- 2. Categories that generate the most transaction value in 2022

select
  category,
  round(sum(after_discount), 2) as total_transaction
from `finpro.order_detail` od
  join `finpro.sku_detail` sd on od.sku_id = sd.id
  where extract(year from order_date) = 2022
  and is_valid = 1
group by 1
order by 2 desc


-- 3. Comparison of transaction value of each category in 2021 and 2022.
with TransactionByYear as (
select
  category,
  round(sum(case when extract(year from order_date) = 2021 then after_discount end), 2) as total_transaction_2021,
  round(sum(case when extract(year from order_date) = 2022 then after_discount end), 2) as total_transaction_2022
from `finpro.order_detail` od
  join `finpro.sku_detail` sd on od.sku_id = sd.id
  where extract(year from order_date) in (2021, 2022)
  and is_valid = 1
group by 1)

select
  TransactionByYear.*,
  round(total_transaction_2022 - total_transaction_2021, 2) as difference,
  case
    when total_transaction_2021 > total_transaction_2022 then 'Decrease'
    when total_transaction_2021 < total_transaction_2022 then 'Increase'
    else 'Stable'
  end as growth
from TransactionByYear
order by 2 desc

-- 4. The most used payment methods during 2022

select 
  payment_method,
  count(distinct od.id) as total_payment_method
from `finpro.order_detail` od
  join `finpro.payment_detail` pd on od.payment_id = pd.id
  where extract(year from order_date) = 2022
  and is_valid =1
group by 1
order by 2 desc


-- 5. Order of products with the highest transaction value

with TransactionByProduct as (
select 
  case
    when lower(sd.sku_name) like '%samsung%' then 'Samsung'
    when lower(sd.sku_name) like '%apple%' or lower(sd.sku_name) like '%iphone%' or lower(sd.sku_name) like '%ipad%'
      or lower(sd.sku_name) like '%macbook%' then 'Apple'
    when lower(sd.sku_name) like '%playstation%' or lower(sd.sku_name) like '%sony%' then 'Sony'
    when lower(sd.sku_name) like '%huawei%' then 'Huawei'
    when lower(sd.sku_name) like '%lenovo%' then 'Lenovo'
  end as product_brand,
  sum(od.after_discount) total_transaction
from `finpro.sku_detail` sd
  join `finpro.order_detail` od on sd.id = od.sku_id
  where is_valid = 1
  group by 1
)

select
  *
from TransactionByProduct
  where product_brand is not null
  order by total_transaction desc;


