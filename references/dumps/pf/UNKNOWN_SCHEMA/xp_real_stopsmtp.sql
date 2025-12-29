-- PF: UNKNOWN_SCHEMA.xp_real_stopsmtp
-- proc_id: 45
-- generated_at: 2025-12-29T13:53:28.704Z

create function dbo.xp_real_stopsmtp( in cid integer ) 
returns integer
external name 'xp_stopsmtp@dbextf;Unix:xp_stopsmtp@libdbextf'
