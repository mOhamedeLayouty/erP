-- PF: UNKNOWN_SCHEMA.sa_statement_text
-- proc_id: 193
-- generated_at: 2025-12-29T13:53:28.748Z

create procedure dbo.sa_statement_text( in txt long varchar ) 
result( stmt_text long varchar ) dynamic result sets 1
begin
  declare currline long varchar;
  declare len integer;
  declare posn integer;
  declare stmt_type varchar(10);
  declare from_line integer;
  declare local temporary table satmp_statement_text(
    ln integer not null default autoincrement,
    stmt_text long varchar null,
    primary key(ln),) in SYSTEM not transactional;
  set txt = replace(txt,'\x09',' ');
  -- Make a SQL statement readable by inserting newlines.
  set stmt_type = null;
  if substr(txt,1,6) = 'SELECT' then
    set stmt_type = 'SELECT';
    set txt = replace(txt,',',',\x0A');
    set txt = replace(txt,'FROM ','\x0AFROM ');
    set txt = replace(txt,'LEFT OUTER JOIN','\x0A        LEFT OUTER JOIN');
    set txt = replace(txt,'WHERE','\x0AWHERE');
    set txt = replace(txt,' AND ','\x0AAND   ');
    set txt = replace(txt,'GROUP BY','\x0AGROUP BY');
    set txt = replace(txt,'ORDER BY','\x0AORDER BY');
    set txt = replace(txt,'UNION','\x0AUNION')
  elseif substr(txt,1,6) = 'INSERT' then
    set txt = replace(txt,',',',\x0A    ');
    set txt = replace(txt,'VALUES','\x0AVALUES');
    set txt = replace(txt,'SELECT','\x0ASELECT')
  elseif substr(txt,1,6) = 'DELETE' then
    set txt = replace(txt,'FROM ','\x0AFROM ');
    set txt = replace(txt,'WHERE','\x0AWHERE');
    set txt = replace(txt,' AND ','\x0AAND   ')
  elseif substr(txt,1,6) = 'UPDATE' then
    set txt = replace(txt,'SET ','\x0ASET ');
    set txt = replace(txt,'FROM ','\x0AFROM ');
    set txt = replace(txt,'WHERE','\x0AWHERE');
    set txt = replace(txt,' AND ','\x0AAND   ')
  else
    -- other
  end if;
  set len = length(txt);
  while(len > 0) loop
    set posn = locate(txt,'\x0A');
    if(posn > 150 or posn = 0) then
      set posn = 150;
      set currline = substr(txt,1,posn)
    else
      set currline = substr(txt,1,posn-1)
    end if;
    insert into satmp_statement_text( stmt_text ) values( currline ) ;
    set txt = substr(txt,posn+1);
    set len = len-posn
  end loop;
  -- Make subqueries in SELECT list display better.
  -- (Subqueries in WHERE make queries display worse.)
  if stmt_type = 'SELECT' then
    select max(ln)
      into from_line from satmp_statement_text
      where substr(stmt_text,1,4) = 'FROM';
    update satmp_statement_text
      set stmt_text = '        ' || stmt_text
      where(substr(stmt_text,1,4) = 'FROM' or substr(stmt_text,1,5) = 'WHERE'
      and ln < from_line)
  end if;
  select stmt_text from satmp_statement_text order by ln asc
end
