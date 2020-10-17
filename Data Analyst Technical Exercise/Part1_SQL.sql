
/*
Author: John Allen

Description:
	* This query displays the decile of user design exports for a prior 7 day period.
	* Each row represents a distinct user_id with their export decile and last export design category.

Assumptions:
	* Growth marketers only want decile calculated for the past 7 days from date of query execution.
	* The design_category field is not null.
*/

select t1.[user_id]
-- Included swipe count for subdecile comparison
	,count(distinct t1.[event_id]) as [export_count]
	,ntile(10) over (order by count(distinct t1.[event_id]) asc) as [decile]
	,t2.[design_category] as [last_exported_design_category]
from [design_exported] t1
-- Self join for latest record in period
left join (
	select [user_id]
		,[design_category]
		,row_number() over (partition by [user_id] order by [timestamp] desc) as rn
	from [design_exported]
	where [timestamp] >= dateadd(day, -7, getdate())
	group by [user_id], [design_category], [timestamp]
	) t2
	on t1.[user_id] = t2.[user_id]
	and t2.rn = 1
-- Last 7 days
where [timestamp] >= dateadd(day, -7, getdate())
group by t1.[user_id], t2.[design_category]
order by [export_count] desc, [decile] desc
go
