;with [sprocs] as (
select database_id,sproc.[object_id], name, plan_handle,sql_handle,qfp.last_compile_batch_sql_handle,
case when sql_handle = last_compile_batch_sql_handle then '1' else '0' end 'Forced_Plan_in_use'
FROM sys.dm_exec_procedure_stats sproc
left outer join (
select [last_compile_batch_sql_handle],object_id,query_hash,qsp.initial_compile_start_time,qsp.last_compile_start_time,qsp.last_execution_time from sys. query_store_plan qsp
inner join sys.query_store_query qsq on qsp.query_id = qsq.query_id 
where is_forced_plan = 1 
) qfp on sproc.object_id  = qfp.object_id 
--left outer join sys.dm_exec_query_stats query on sproc.sql_handle = query.sql_handle
left outer join sys.objects obj on sproc.object_id = obj.object_id
cross apply sys.dm_exec_query_plan(sproc.plan_handle)
where qfp.object_id is not null
)


select * from sprocs a
where a.database_id = convert(varchar,db_id())
