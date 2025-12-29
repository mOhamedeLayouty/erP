-- PF: UNKNOWN_SCHEMA.sp_sql_type_name
-- proc_id: 348
-- generated_at: 2025-12-29T13:53:28.793Z

create procedure dbo.sp_sql_type_name( 
  @datatype tinyint,
  @usrtype smallint ) 
as
begin
  declare @answer varchar(255)
  if(@usrtype > 100)
    begin
      select @answer = type_name from SYS.sysusertype
        where type_id = @usrtype
    end
  else if(@usrtype = 81)
      begin
        select @answer = 'uniqueidentifier'
      end
    else if(@datatype = 38 and @usrtype = 33)
        begin
          select @answer = 'bigint'
        end
      else if(@usrtype = 82)
          begin
            select @answer = 'timestamp with time zone'
          end
        else if(@usrtype = 83)
            begin
              select @answer = 'st_geometry'
            end
          else if(@usrtype = 36)
              begin
                select @answer = 'long nvarchar'
              end
            else if(@usrtype = 35)
                begin
                  select @answer = 'nvarchar'
                end
              else if(@usrtype = 34)
                  begin
                    select @answer = 'nchar'
                  end
                else if(@usrtype = 38)
                    begin
                      select @answer = 'time'
                    end
                  else if(@usrtype = 37)
                      begin
                        select @answer = 'date'
                      end
                    else if(@datatype = 108)
                        begin
                          if(@usrtype = 31)
                            select @answer = 'unsigned smallint'
                          else if(@usrtype = 29)
                              select @answer = 'unsigned int'
                            else if(@usrtype = 84)
                                select @answer = 'unsigned bigint'
                              else
                                select @answer = 'numeric'
                        end
                      else if(@datatype = 106)
                          begin
                            select @answer = 'decimal'
                          end
                        else
                          begin
                            select @answer = j.type_name from dbo.spt_jdatatype_info as j
                              where j.ss_dtype = @datatype and j.is_unique = 1
                          end
  select dbo.sp_jconnect_trimit(@answer)
end
