-- PF: UNKNOWN_SCHEMA.sa_get_bits
-- proc_id: 234
-- generated_at: 2025-12-29T13:53:28.760Z

create procedure dbo.sa_get_bits( in bit_string long varbit,in only_on_bits bit default 1 ) 
result( bitnum unsigned integer,bit_val bit ) dynamic result sets 1
internal name 'sa_get_bits'
