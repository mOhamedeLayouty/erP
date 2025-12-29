-- PF: UNKNOWN_SCHEMA.sa_get_server_messages
-- proc_id: 255
-- generated_at: 2025-12-29T13:53:28.767Z

create procedure dbo.sa_get_server_messages( in first_line integer ) 
result( line_num integer,message_text varchar(255),message_time timestamp ) dynamic result sets 1
begin
  declare ln integer;
  declare max_ln integer;
  declare max_rows integer;
  declare local temporary table ServerMessages(
    line_num integer not null,
    message_text varchar(255) null,
    message_time timestamp null,
    primary key(line_num),) in SYSTEM on commit preserve rows;
  set max_ln = property('MaxMessage');
  set max_rows = property('MessageWindowSize');
  set ln = first_line;
  if(ln < 0 or ln <= (max_ln-max_rows)) then
    set ln = max_ln-max_rows+1;
    if ln < 0 then
      set ln = 0
    end if
  end if;
  while(ln < max_ln) loop
    insert into ServerMessages values
      ( ln,
      property('MessageText',ln),
      property('MessageTime',ln) ) ;
    set ln = ln+1
  end loop;
  commit work;
  select * from ServerMessages
    order by line_num asc
end
