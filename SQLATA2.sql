--Question 1-1
--Product Penetration 4%

select ((a.totalpurchase*100+0.0)/b.totaluser) as 'percentage'
from
	(select count(distinct user_id) as totalpurchase
	from [ATA project]..user_action$
	where action='purchase_product') a,
	(select count (*) as totaluser
	from [ATA project]..user$) b

--Question 1-2
--View Conversion 13%

select((a.totalpurchase*100+0.0)/b.totalview) as 'percentage'
from
	(select count(distinct user_id) as totalpurchase
	from [ATA project]..user_action$
	where action='purchase_product') a,
	(select count(*) as totalview
	from [ATA project]..user_action$
	where action='view_product') b

--Question 2-1
--PPU 
--在join table之后的and...and就是说过滤加在这边比较高效比where要好很多能运用在两个表格上,where的话不能作用在附表上

select convert(varchar(10),create_date,102) as [Corhor],(count(distinct c.user_id)+0.0)/COUNT(distinct d.user_id) *100 as PPU

from [ATA project]..user_action$ c
	right join [ATA project]..user$ d
	on c.user_id=d.user_id and  c.timestamp <= dateadd(day,3,d.create_date) and  c.action = 'purchase_product'
 
group by  convert(varchar(10),create_date,102)
order by 1



--Question 2-2
--Avg new user login within 2 days 
--这里面有几个重要个功能比如说timestamp后面的过滤dateadd+1就是在创造账号之后的1天。 还有在join table之后的and...and
--就是说过滤加在这边比较高效比where要好很多能运用在两个表格上

select create_date, avg(num) as [Avg log in]
from (
select convert(varchar(10),create_date,102) as create_date,d.user_id,count(*) as num
from [ATA project]..user_action$ c
	inner join [ATA project]..user$ d
	on c.user_id=d.user_id and  convert(varchar(10),c.timestamp,102) =  convert(varchar(10),dateadd(day,1,d.create_date),102) and  c.action = 'login'
group by  convert(varchar(10),create_date,102),d.user_id
) t
group by create_date
order by 1
