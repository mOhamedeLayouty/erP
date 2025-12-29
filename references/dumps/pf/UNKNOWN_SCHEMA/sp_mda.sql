-- PF: UNKNOWN_SCHEMA.sp_mda
-- proc_id: 332
-- generated_at: 2025-12-29T13:53:28.789Z

create procedure dbo.sp_mda( @requesttype integer,@requestversion integer,@clientversion integer= 0 ) as
begin
  declare @min_mdaversion integer,@max_mdaversion integer
  declare @mda_version integer
  declare @srv_version integer
  declare @mdaver_querytype tinyint
  declare @mdaver_query varchar(255)
  declare @original_iso_level integer
  declare @charindex integer
  declare @position integer
  declare @server_version varchar(3)
  select @server_version = substring(@@version,1,3)
  select @min_mdaversion = 1
  select @max_mdaversion = 7
  select @mda_version = @requestversion
  if(patindex('%IQ%',@@version) > 0)
    begin
      select @srv_version = 6
    end
  else
    begin
      select @charindex = charindex('.',@server_version)
      if(@charindex > 0)
        begin
          select @position = @charindex-1
        end
      else
        begin
          select @position = char_length(@server_version)
        end
      select @srv_version = convert(integer,substring(@@version,1,@position))
    end
  select @original_iso_level = @@isolation
  set transaction isolation level 1
  if(@requestversion < @min_mdaversion)
    begin
      select @mda_version = @min_mdaversion
    end
  if(@mda_version > @max_mdaversion)
    begin
      select @mda_version = @max_mdaversion
    end
  if(@mda_version < 4)
    begin
      select @mda_version = 1
      select @mdaver_querytype = 2
      select @mdaver_query = 'select 1'
    end
  else
    begin
      select @mdaver_querytype = 5
      select @mdaver_query = convert(varchar(255),@mda_version)
    end
  if(@requesttype = 0)
    begin
      select mdinfo=convert(varchar(30),'MDAVERSION'),
        querytype=@mdaver_querytype,
        query=@mdaver_query union
      select mdinfo,querytype,query
        from dbo.spt_mda
        where mdinfo in( 
        'MDARELEASEID' ) 
    end
  else if(@requesttype = 1)
      begin
        select mdinfo=convert(varchar(30),'MDAVERSION'),
          querytype=@mdaver_querytype,
          query=@mdaver_query union
        select mdinfo,querytype,query
          from dbo.spt_mda
          where @mda_version >= mdaver_start
          and @mda_version <= mdaver_end
          and((@srv_version >= srvver_start)
          and(@srv_version <= srvver_end
          or srvver_end = -1))
      end
    else if(@requesttype = 2)
        begin
          select mdinfo=convert(varchar(30),'MDAVERSION'),
            querytype=@mdaver_querytype,
            query=@mdaver_query union
          select mdinfo,querytype,query
            from dbo.spt_mda
            where mdinfo in( 
            'CONNECTCONFIG',
            'SET_CATALOG',
            'SET_AUTOCOMMIT_ON',
            'SET_AUTOCOMMIT_OFF',
            'SET_ISOLATION',
            'SET_ROWCOUNT',
            'DEFAULT_CHARSET' ) 
            and @mda_version >= mdaver_start
            and @mda_version <= mdaver_end
            and((@srv_version >= srvver_start)
            and(@srv_version <= srvver_end
            or srvver_end = -1))
        end
  if(@original_iso_level = 0)
    begin
      set transaction isolation level 0
    end
  if(@original_iso_level = 2)
    begin
      set transaction isolation level 2
    end
  if(@original_iso_level = 3)
    begin
      set transaction isolation level 3
    end
  if(@original_iso_level = 4)
    begin
      set transaction isolation level snapshot
    end
  if(@original_iso_level = 5)
    begin
      set transaction isolation level statement snapshot
    end
  if(@original_iso_level = 6)
    begin
      set transaction isolation level readonly statement snapshot
    end
end
