select market
from dim_customer
where customer='Atliq Exclusive' and region ='APAC'


select (select distinct count(product_code) from fact_manufacturing_cost where cost_year='2020') unique_products_2020,
       (select distinct count(product_code) from fact_manufacturing_cost where cost_year='2021') unique_products_2021,
       (select (unique_products_2021 - unique_products_2020) / unique_products_2020 * 100) percentage_chg


select segment, count(distinct product_code) as product_count
from dim_product
group by segment
order by product_count desc;


with
temp as (select segment, count(distinct fact_manufacturing_cost.product_code) product_count,cost_year
         from fact_manufacturing_cost join dim_product on dim_product.product_code = fact_manufacturing_cost.product_code
         group by segment, cost_year)
select segment, product_count_2020, product_count_2021, (product_count_2021-product_count_2020) difference
from (select distinct temp.segment, product_count_20.product_count as product_count_2020, product_count_21.product_count as product_count_2021
      from temp
          join (select segment, product_count from temp where cost_year='2020') product_count_20
              on temp.segment=product_count_20.segment
          join (select segment, product_count from temp where cost_year='2021') product_count_21
              on temp.segment=product_count_21.segment) temp1


select fact_manufacturing_cost.product_code, product, manufacturing_cost
from fact_manufacturing_cost
join dim_product dp on fact_manufacturing_cost.product_code = dp.product_code
where manufacturing_cost in ((select max(manufacturing_cost) from fact_manufacturing_cost), (select min(manufacturing_cost) from fact_manufacturing_cost))


select inn.customer_code, dc.customer, pre_invoice_discount_pct as average_discount_percentage
from fact_pre_invoice_deductions inn
join dim_customer dc on inn.customer_code = dc.customer_code
where market='india' and fiscal_year='2021'
order by pre_invoice_discount_pct desc
limit 5



select Month, Year, round(SUM((gross_price * sold_quantity * (1-pre_invoice_discount_pct))),2) Gross_sales_Amount
from (select dc.customer_code, month(date) Month, year(date) Year,sold_quantity, fgp.fiscal_year, gross_price, pre_invoice_discount_pct
    from dim_customer dc
    join fact_sales_monthly fsm on dc.customer_code = fsm.customer_code
    join fact_pre_invoice_deductions fpid on dc.customer_code = fpid.customer_code and fsm.fiscal_year=fpid.fiscal_year
    join fact_gross_price fgp on fsm.fiscal_year = fgp.fiscal_year and fgp.product_code=fsm.product_code
    where customer = 'Atliq Exclusive')temp
group by Month, Year
ORDER BY Year, Month


SELECT CASE
    when MONTH(date) in (1,2,3) Then 1
    when month(date) in (4,5,6) then 2
    when month(date) in (7,8,9) then 3
    else 4
    end Quater,
    SUM(sold_quantity) total_sold_quantity
from fact_sales_monthly
where year(date) = '2020'
group by Quater
order by total_sold_quantity desc


select channel, gross_sales gross_sales_mln, round(gross_sales * 100/(sum(gross_sales) over ()),2) percentage
from (select channel, round(sum((sold_quantity*gross_price*(1-pre_invoice_discount_pct))), 2) gross_sales
    from dim_customer dc
    join fact_sales_monthly fsm on dc.customer_code = fsm.customer_code
    join fact_gross_price fgp on fsm.product_code = fgp.product_code and fsm.fiscal_year = fgp.fiscal_year
    join fact_pre_invoice_deductions fpid on dc.customer_code = fpid.customer_code and fpid.fiscal_year=fsm.fiscal_year
    where year(date) = '2021'
    group by channel) temp


select division, product_code
from (select product_code,division, rank() over (partition by division order by total_count) rank_count
    from (select dp.product_code, division,sum(sold_quantity) total_count
        from fact_sales_monthly fsm
        join dim_product dp on fsm.product_code = dp.product_code
        where fiscal_year='2021'
        group by dp.product_code, division) temp) temp1
where rank_count <=3





