-- PF: UNKNOWN_SCHEMA.sa_internal_split_list
-- proc_id: 233
-- generated_at: 2025-12-29T13:53:28.760Z

create procedure dbo.sa_internal_split_list( in str long varchar,in delim char(10),in maxlen integer ) 
internal name 'sa_split_list'
