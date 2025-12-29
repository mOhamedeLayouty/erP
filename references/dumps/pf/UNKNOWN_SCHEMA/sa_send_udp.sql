-- PF: UNKNOWN_SCHEMA.sa_send_udp
-- proc_id: 232
-- generated_at: 2025-12-29T13:53:28.759Z

create function dbo.sa_send_udp( 
  in destAddress char(254),
  in destPort unsigned smallint,
  in msg long binary ) 
returns integer
internal name 'sa_send_udp'
