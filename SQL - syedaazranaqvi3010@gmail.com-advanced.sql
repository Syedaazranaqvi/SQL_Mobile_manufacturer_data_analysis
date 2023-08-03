--SQL Advance Case Study

--Q1--BEGIN 
select  distinct (state) from FACT_TRANSACTIONS as ft
inner join DIM_LOCATION as l
on ft.IDLocation=l.IDLocation
inner join DIM_MODEL as mo
on ft.IDModel=mo.IDModel
where  date between '01-01-2005' and getdate()
--Q1--END

--Q2.BEGIN	
select top 1 manu.Manufacturer_Name from dim_manufacturer as manu
inner join dim_model as model
on manu.idmanufacturer=model.idmanufacturer
inner join FACT_TRANSACTIONS as f
on model.idmodel=f.idmodel
inner join DIM_LOCATION as loc
on f.IDLocation=loc.IDLocation
 where manufacturer_name ='Samsung' and country='US'
 group by Manufacturer_Name
 order by count(f.Quantity) desc
--Q2--END

--Q3--BEGIN      
select  Model_Name,ZipCode,State,count(IDCustomer)as no_of_transaction from FACT_TRANSACTIONS as f
inner join DIM_MODEL as m
on f.IDModel=m.IDModel
inner join DIM_LOCATION as l
on f.IDLocation=l.IDLocation
group by Model_Name,ZipCode,state
--Q3--END

--Q4--BEGIN
select  top 1 min(unit_price) as price ,Model_Name ,Manufacturer_Name from DIM_MODEL as model 
inner join DIM_MANUFACTURER as m
on model.IDManufacturer=m.IDManufacturer
group by  manufacturer_name,Model_Name
--Q4--END

--Q5--BEGIN 
select  Manufacturer_Name,model_name , avg(totalPrice) as avg_price ,
sum(quantity) as sales_quantity from FACT_TRANSACTIONS as f
left join DIM_MODEL as mo
on f.IDModel=mo.IDModel
inner join DIM_MANUFACTURER as ma
on mo.IDManufacturer=ma.IDManufacturer 
where Manufacturer_Name in (
	select top 5 Manufacturer_Name from FACT_TRANSACTIONS as f
	left join DIM_MODEL as mo
	on f.IDModel=mo.IDModel
	inner join DIM_MANUFACTURER as ma
	on mo.IDManufacturer=ma.IDManufacturer
	group by Manufacturer_Name
	order by sum(quantity) desc
)
group by Manufacturer_Name,model_name
order by avg(totalprice) desc

--Q5--END

--Q6--BEGIN
select Customer_Name,AVG(totalprice) as average_amount from FACT_TRANSACTIONS as ft
left join  DIM_CUSTOMER as c
on ft.IDCustomer=c.IDCustomer
where year(date)=2009
group by Customer_Name
having avg(totalprice)>500
--Q6--END
	
--Q7--BEGIN 
select model2008.model_name from
(select top 5  ft.IDModel ,sum(quantity) as quantity,model_name  from FACT_TRANSACTIONS as ft
inner join DIM_MODEL as mo
on ft.IDModel=mo.IDModel
where year(date) ='2008'
group by ft.IDModel,Model_Name
order by sum(quantity) desc) as model2008
inner join
(select top 5  ft.IDModel ,sum(quantity) as quantity,model_name  from FACT_TRANSACTIONS as ft
inner join DIM_MODEL as mo
on ft.IDModel=mo.IDModel
where year(date) ='2009'
group by ft.IDModel,Model_Name
order by sum(quantity) desc) as model2009
on model2008.idmodel=model2009.idmodel
inner join 
(select top 5  ft.IDModel ,sum(quantity) as quantity,model_name  from FACT_TRANSACTIONS as ft
inner join DIM_MODEL as mo
on ft.IDModel=mo.IDModel
where year(date) ='2010'
group by ft.IDModel,Model_Name
order by sum(quantity) desc) as model2010
on model2009.model_name=model2010.model_name
--Q7--END

--Q8--BEGIN
select ab.manufacturer_name,ab.quantitysales ,bc.manufacturer_name,bc.quantitysales from(
select top 1 manufacturer_name ,sum(quantity ) as quantitysales from FACT_TRANSACTIONS as ft
inner join DIM_MODEL as mo
on ft.IDModel=mo.IDModel
inner join DIM_MANUFACTURER as mu
on mo.IDManufacturer=mu.IDManufacturer
where year(date)=2009
group by Manufacturer_Name
having sum(quantity)<(select q from(select top 1 manufacturer_name,sum(quantity ) as q from FACT_TRANSACTIONS as ft
inner join DIM_MODEL as mo
on ft.IDModel=mo.IDModel
inner join DIM_MANUFACTURER as mu
on mo.IDManufacturer=mu.IDManufacturer
where year(date)=2009
group by Manufacturer_Name
order by sum(Quantity) desc) as a) 
order by sum(Quantity) desc
)as ab
cross join 
(select top 1 manufacturer_name ,sum(quantity ) as quantitysales from FACT_TRANSACTIONS as ft
inner join DIM_MODEL as mo
on ft.IDModel=mo.IDModel
inner join DIM_MANUFACTURER as mu
on mo.IDManufacturer=mu.IDManufacturer
where year(date)=2010
group by Manufacturer_Name
having sum (quantity)< ( select qt from(select top 1 manufacturer_name,sum(quantity ) as qt from FACT_TRANSACTIONS as ft
inner join DIM_MODEL as mo
on ft.IDModel=mo.IDModel
inner join DIM_MANUFACTURER as mu
on mo.IDManufacturer=mu.IDManufacturer
where year(date)=2009
group by Manufacturer_Name
order by sum(Quantity) desc)as b)
order by sum(Quantity) desc
) as bc
--Q8--END

--Q9--BEGIN	
select Manufacturer_Name from FACT_TRANSACTIONS as ft
	inner join DIM_MODEL as mo
	on ft.IDModel=mo.IDModel
	inner join DIM_MANUFACTURER as mu
	on mo.IDManufacturer=mu.IDManufacturer
	where year(date)=2010 
	group by Manufacturer_Name
	except
	select Manufacturer_Name from FACT_TRANSACTIONS as ft
	inner join DIM_MODEL as mo
	on ft.IDModel=mo.IDModel
	inner join DIM_MANUFACTURER as mu
	on mo.IDManufacturer=mu.IDManufacturer
	where year(date)=2009 
	group by Manufacturer_Name
--Q9--END

--Q10--BEGIN
	select firsttable.Customer_Name,firsttable.year,firsttable.averagespend,
	firsttable.averagequantity,case when secondtable.YEAR IS NOT NULL Then
        FORMAT(
            CONVERT(DECIMAL(10, 2), (firsttable.averagespend-secondtable.averagespend)) /
            CONVERT(DECIMAL(10, 2), secondtable.averagespend), 'p')
    ELSE NULL END AS "YEARLY GROWTH"
	from
	(select  top 100 ct.Customer_Name,year(ft.date) as year,avg(ft.totalprice) as averagespend,
	avg(ft.quantity)  as averagequantity from FACT_TRANSACTIONS as ft
	left join DIM_CUSTOMER as ct
	on ft.IDCustomer=ct.IDCustomer
	where ft.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS group by IDCustomer
	order by sum(TotalPrice)desc)
	group by Customer_Name,year(date)) as firsttable
	left join
	(select   top 100 ct.Customer_Name,year(ft.Date) as year,avg(ft.TotalPrice) as averagespend,
	avg(ft.Quantity)  as averagequantity from FACT_TRANSACTIONS as ft
	left join DIM_CUSTOMER as ct
	on ft.IDCustomer=ct.IDCustomer
	where ft.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS group by IDCustomer
	order by sum(TotalPrice)desc)
	group by Customer_Name,year(date)) as secondtable
	on firsttable.customer_name=secondtable.Customer_Name and secondtable.year=firsttable.year-1
--Q10--END
	