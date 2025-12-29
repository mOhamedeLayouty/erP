-- PF: UNKNOWN_SCHEMA.sa_http_php_page_interpreted
-- proc_id: 58
-- generated_at: 2025-12-29T13:53:28.708Z

create function dbo.sa_http_php_page_interpreted( in php_page long varchar,in method long varchar,in url long varchar,in version long varchar,in headers long binary,in request_body long binary ) 
returns long binary
sql security invoker
external name 'sqlanywhere_extenv_start_http( $argv[2], $argv[3], $argv[4], $argv[5], $argv[6] ); eval( " ?>" . $argv[1] . "<?php " );' language php
