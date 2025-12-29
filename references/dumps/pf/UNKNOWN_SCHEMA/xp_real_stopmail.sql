-- PF: UNKNOWN_SCHEMA.xp_real_stopmail
-- proc_id: 41
-- generated_at: 2025-12-29T13:53:28.703Z

create function dbo.xp_real_stopmail( in cid integer ) 
returns integer
external name 'xp_stopmail@dbextf.dll'
