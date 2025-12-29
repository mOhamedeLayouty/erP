-- PF: UNKNOWN_SCHEMA.WebCopyTemplate
-- proc_id: 411
-- generated_at: 2025-12-29T13:53:28.810Z

create procedure DBA.WebCopyTemplate( @Id integer,@parentId integer ) as
begin
  declare @newId integer
  insert into WebTemplate( ConnectionId,
    ParentId,DocType,Name,Location,Description,Size ) 
    select ConnectionId,@parentId,DocType,Name,Location,Description,Size
      from WebTemplate where Id = @Id
  select @newId = @@identity
  /* Copy the data */
  insert into WebData( Id,
    Sequence,Data ) 
    select @newId,Sequence,Data from WebData
      where Id = @Id
  declare children dynamic scroll cursor for select Id from WebTemplate where ParentId = @Id
  declare @child integer
  open children
  fetch next children
    into @child
  while(@@sqlstatus = 0) begin
      execute WebCopyTemplate @child,@newId
      fetch next children
        into @child
    end
  execute WebChanged
  /* Return the new id */
  select @Id = @newId
end
