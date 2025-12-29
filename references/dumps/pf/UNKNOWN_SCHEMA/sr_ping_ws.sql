-- PF: UNKNOWN_SCHEMA.sr_ping_ws
-- proc_id: 272
-- generated_at: 2025-12-29T13:53:28.771Z

create procedure dbo.sr_ping_ws( 
  in url varchar(1000),
  in uname varchar(128),
  in cert long varchar default null,
  in proxy varchar(1000) default null,
  in clport varchar(10) default null ) 
result( attr varchar(128),value long varchar ) dynamic result sets 1
url '!url/dbremote/control/ping/!uname' type
'HTTP:GET' header
'ASA-Id' set
'HTTP(CHUNK=ON;VERSION=1.1)' certificate
'!cert' clientport
'!clport' proxy
'!proxy'
