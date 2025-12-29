-- PF: UNKNOWN_SCHEMA.sa_http_php_page
-- proc_id: 59
-- generated_at: 2025-12-29T13:53:28.708Z

create function dbo.sa_http_php_page( in php_page long varchar ) 
returns long binary
sql security invoker
begin
  declare headers long varchar;
  select list(name || ': ' || value,"char"(13) || "char"(10))
    into headers from sa_http_header_info();
  return sa_http_php_page_interpreted(php_page,
    http_header('@HttpMethod'),
    http_header('@HttpURI'),
    http_header('@HttpVersion'),
    headers,
    HTTP_BODY())
end
