-- PF: UNKNOWN_SCHEMA.sr_add_message_server
-- proc_id: 286
-- generated_at: 2025-12-29T13:53:28.775Z

create procedure dbo.sr_add_message_server( 
  in @owner varchar(128) default current user ) 
begin
  declare err_dbremote_owner_not_group exception for sqlstate value '99201';
  declare err_dbremote_http_rootdir_not_set exception for sqlstate value '99202';
  declare err_dbremote_message_server_exists exception for sqlstate value '99203';
  declare @c_user varchar(128);
  declare @stmt long varchar;
  declare @root_dir varchar(1024);
  if not exists(select 1
      from SYS.SYSUSERAUTHORITY as sua
        join SYS.SYSUSER as su on sua.user_id = su.user_id
      where sua.auth = 'GROUP'
      and su.user_name = @owner) then
    message 'DBG_SRAMS: User is not a group - ' || @owner to console debug only;
    raiserror 29300 'User %1! is not a group',@owner;
    return
  end if;
  set @root_dir = null;
  select sro.setting
    into @root_dir from SYS.SYSREMOTETYPE as srt
      ,SYS.SYSREMOTEOPTIONTYPE as srot
      ,SYS.SYSREMOTEOPTION as sro
      ,SYS.SYSUSER as su
    where srt.type_id = srot.type_id
    and srot.option_id = sro.option_id
    and sro.user_id = su.user_id
    and UCASE(srt.type_name) = 'HTTP'
    and UCASE(srot."option") = 'ROOT_DIRECTORY'
    and su.user_name = @owner;
  if(@root_dir is null) then
    select sro.setting
      into @root_dir from SYS.SYSREMOTETYPE as srt
        ,SYS.SYSREMOTEOPTIONTYPE as srot
        ,SYS.SYSREMOTEOPTION as sro
        ,SYS.SYSUSER as su
      where srt.type_id = srot.type_id
      and srot.option_id = sro.option_id
      and sro.user_id = su.user_id
      and UCASE(srt.type_name) = 'HTTP'
      and UCASE(srot."option") = 'ROOT_DIRECTORY'
      and su.user_name = 'PUBLIC'
  end if;
  if(@root_dir is null) then
    message 'DBG_SRAMS: HTTP root_directory not set.' to console debug only;
    raiserror 29301 'You must set the root_directory message system parameter for the HTTP transport';
    return
  end if;
  if exists(select 1 from SYS.SYSWEBSERVICE where service_name = 'dbremote') then
    set @c_user = null;
    select su.user_name
      into @c_user from SYS.SYSPROCEDURE as sp
        join SYS.SYSUSER as su on sp.creator = su.user_id
      where proc_name in( 'sp_dbremote_user_to_dir' ) ;
    message 'DBG_SRAMS: err_dbremote_message_server_exists - ' || @c_user to console debug only;
    raiserror 29302 'User %1! appears to already own the message server objects',@c_user;
    return
  end if;
  set @stmt
     = '\x0A        create function "' || @owner
     || '"."sp_dbremote_user_to_dir" (\x0A            in  @uname   varchar(128)\x0A        )\x0A        returns varchar(128)\x0A        begin\x0A            declare @ret varchar(128);\x0A            set @ret = NULL;\x0A            if exists ( select 1\x0A                          from SYS.SYSUSERAUTHORITY sua\x0A                          join SYS.SYSUSER su on sua.user_id = su.user_id\x0A                         where su.user_name = @uname\x0A                           and sua.auth = ''PUBLISH'' ) then\x0A                select publisher_address\x0A                  into @ret\x0A                  from SYS.SYSREMOTETYPE\x0A                 where UCASE(type_name) = ''HTTP'';\x0A            else\x0A                select sru.address\x0A                  into @ret\x0A                  from SYS.SYSUSER su\x0A                  join SYS.SYSREMOTEUSER sru on su.user_id = sru.user_id\x0A                   and su.user_name = @uname;\x0A            end if;\x0A            return( @ret );\x0A        end;\x0A    ';
  message 'DBG_SRAMS: ' || @stmt to console debug only;
  execute immediate @stmt;
  set @stmt
     = '\x0A        create procedure "' || @owner
     || '"."sp_dbremote_control" (\x0A                in  @action  varchar(32),\x0A                in  @uname   varchar(128)\x0A            )\x0A        result (rawdoc long varchar)\x0A        begin\x0A            declare @method   char(10);\x0A            declare @status   int          = 0;\x0A            declare @errormsg long varchar = ''ok'';\x0A            declare @result   xml;\x0A            declare @contents long binary;\x0A            declare @dir      varchar(128);\x0A            declare @ctype    char(100)    = ''text/xml'';\x0A            declare @cconv    char(3)      = ''OFF'';\x0A            set @method   = isnull( http_variable( ''method'' ), http_header(''@HttpMethod'') );\x0A            set @uname    = isnull( @uname, '''' );\x0A            set @dir      = isnull( sp_dbremote_user_to_dir( @uname ), '''' );\x0A            if @method not in ( ''GET'' ) then\x0A                set @status   = -1;\x0A                set @errormsg = ''Invalid method "'' || @method || ''"'';\x0A            elseif @action not in ( ''ping'' ) then\x0A                set @status   = -2;\x0A                set @errormsg = ''Unknown operation "'' || @action || ''"'';\x0A            elseif @uname = '''' then\x0A                set @status   = -3;\x0A                set @errormsg = ''Missing user name'';\x0A            elseif @dir = '''' then\x0A                set @status   = -4;\x0A                set @errormsg = ''User "'' || @uname || ''" is not a remote user or publisher in this database'';\x0A            elseif @action = ''ping'' then\x0A                set @contents = ''ok'';\x0A                set @cconv    = ''ON'';\x0A            else\x0A                set @status   = -9;\x0A                set @errormsg = ''Unknown operation "'' || @action || ''"'';\x0A            end if;\x0A            if @status != 0 then\x0A                set @contents = @errormsg;\x0A                set @ctype    = ''text/plain'';\x0A                set @cconv    = ''ON'';\x0A            end if;\x0A            call sa_set_http_header( ''X-DBREMOTE-ERR'',    @status );\x0A            call sa_set_http_header( ''X-DBREMOTE-MSG'',    @errormsg );\x0A            call sa_set_http_header( ''Content-Type'',      @ctype );\x0A            call sa_set_http_option( ''CharsetConversion'', @cconv );\x0A            select @contents;\x0A        exception\x0A            when others then\x0A                select sqlcode, errormsg()\x0A                  into @status, @errormsg\x0A                  from dummy;\x0A                call sa_set_http_header( ''X-DBREMOTE-ERR'',    @status );\x0A                call sa_set_http_header( ''X-DBREMOTE-MSG'',    @errormsg );\x0A                call sa_set_http_header( ''Content-Type'',      ''text/plain'' );\x0A                call sa_set_http_option( ''CharsetConversion'', ''ON'' );\x0A                select @errormsg;\x0A        end;\x0A    ';
  message 'DBG_SRAMS: ' || @stmt to console debug only;
  execute immediate @stmt;
  set @stmt
     = '\x0A        create procedure "' || @owner
     || '"."sp_dbremote_main" (\x0A                in  @uname   varchar(128)\x0A                ,in  @fname   varchar(128)\x0A            )\x0A        result (rawdoc long binary)\x0A        begin\x0A            declare @method   char(10);\x0A            declare @status   int          = 0;\x0A            declare @errormsg long varchar = ''ok'';\x0A            declare @dir      char(128);\x0A            declare @match    char(512);\x0A            declare @xml      xml;\x0A            declare @contents long binary;\x0A            declare @ctype    char(100)    = ''application/octet-stream'';\x0A            declare @cconv    char(3)      = ''OFF'';\x0A            set @method   = isnull( http_variable( ''method'' ), http_header(''@HttpMethod'') );\x0A            set @fname    = isnull( @fname, '''' );\x0A            set @contents = isnull( http_variable( ''body'' ), http_variable( ''text'' ), '''' );\x0A            set @dir      = isnull( sp_dbremote_user_to_dir( @uname ), '''' );\x0A            if left( property(''platform''), 7 ) = ''Windows'' then\x0A                set @match = @dir || ''\\'' || @fname;\x0A            else\x0A                set @match = @dir || ''/''  || @fname;\x0A            end if;\x0A            if @method not in ( ''GET'', ''DELETE'', ''PUT'' ) then\x0A                set @status   = -1;\x0A                set @errormsg = ''Invalid method "'' || @method || ''"'';\x0A            elseif @uname = '''' then\x0A                set @status   = -3;\x0A                set @errormsg = ''Missing user name'';\x0A            elseif @dir = '''' then\x0A                set @status   = -4;\x0A                set @errormsg = ''User "'' || @uname || ''" is not a remote user or publisher in this database'';\x0A            elseif @contents = '''' and @method = ''PUT'' then\x0A                set @status   = -6;\x0A                set @errormsg = ''Missing message body'';\x0A            elseif @method = ''PUT'' then\x0A                if exists( select 1 from "' || @owner
     || '"."dbremote_msgs" where file_name = @match ) then\x0A                    update "' || @owner
     || '"."dbremote_msgs"\x0A                       set contents = @contents\x0A                     where file_name = @match;\x0A                    set @errormsg = ''File "'' || @match || ''" updated'';\x0A                else\x0A                    insert\x0A                      into "' || @owner
     || '"."dbremote_msgs" ( file_name, contents )\x0A                    values ( @match, @contents );\x0A                    set @errormsg = ''File "'' || @match || ''" saved'';\x0A                end if;\x0A                set @contents = NULL;\x0A                set @contents = ''ok'';\x0A                set @ctype    = ''text/plain'';\x0A                set @cconv    = ''ON'';\x0A            elseif @fname = '''' and @method = ''GET'' then\x0A                if left( property(''platform''), 7 ) = ''Windows'' then\x0A                    set @match = @dir || ''\\%'';\x0A                else\x0A                    set @match = @dir || ''/%'';\x0A                end if;\x0A                select    substr( file_name, length(@dir)+2 ) as fname\x0A                    , size\x0A                    , create_date_time   as cdt\x0A                    , modified_date_time as mdt\x0A                  into @xml\x0A                  from "' || @owner
     || '"."dbremote_msgs" e\x0A                 where file_name like @match\x0A                   for xml auto;\x0A                set @contents = ''<root>'' || @xml || ''</root>'';\x0A                set @ctype    = ''text/xml'';\x0A                set @cconv    = ''ON'';\x0A            elseif @fname = '''' then\x0A                set @status   = -5;\x0A                set @errormsg = ''Missing message file name'';\x0A            elseif @method = ''GET'' then\x0A                select contents\x0A                  into @contents\x0A                  from "' || @owner
     || '"."dbremote_msgs"\x0A                 where file_name = @match;\x0A                set @ctype = ''application/octet-stream'';\x0A                set @cconv = ''OFF'';\x0A            elseif @method = ''DELETE'' then\x0A                delete\x0A                  from "' || @owner
     || '"."dbremote_msgs"\x0A                 where file_name = @match;\x0A                set @contents = ''ok - deleted'';\x0A                set @ctype    = ''text/plain'';\x0A                set @cconv    = ''ON'';\x0A            else\x0A                set @status   = -9;\x0A                set @errormsg = ''Unknown method "'' || http_header(''@HttpMethod'') || ''"'';\x0A            end if;\x0A            if @status != 0 then\x0A                set @contents = @errormsg;\x0A                set @ctype    = ''text/plain'';\x0A                set @cconv    = ''ON'';\x0A            end if;\x0A            call sa_set_http_header( ''X-DBREMOTE-ERR'',    @status );\x0A            call sa_set_http_header( ''X-DBREMOTE-MSG'',    @errormsg );\x0A            call sa_set_http_header( ''Content-Type'',      @ctype );\x0A            call sa_set_http_option( ''CharsetConversion'', @cconv );\x0A            select @contents;\x0A        exception\x0A            when others then\x0A                select sqlcode, errormsg()\x0A                  into @status, @errormsg\x0A                  from dummy;\x0A                call sa_set_http_header( ''X-DBREMOTE-ERR'',    @status );\x0A                call sa_set_http_header( ''X-DBREMOTE-MSG'',    @errormsg );\x0A                call sa_set_http_header( ''Content-Type'',      ''text/plain'' );\x0A                call sa_set_http_option( ''CharsetConversion'', ''ON'' );\x0A                select @errormsg;\x0A        end;\x0A    ';
  message 'DBG_SRAMS: ' || @stmt to console debug only;
  execute immediate @stmt;
  set @stmt
     = '\x0A        grant execute on "' || @owner || '"."sp_dbremote_user_to_dir" to "' || @owner
     || '"\x0A    ';
  message 'DBG_SRAMS: ' || @stmt to console debug only;
  execute immediate @stmt;
  set @stmt
     = '\x0A        grant execute on "' || @owner || '"."sp_dbremote_main" to "' || @owner
     || '"\x0A    ';
  message 'DBG_SRAMS: ' || @stmt to console debug only;
  execute immediate @stmt;
  set @stmt
     = '\x0A        grant execute on "' || @owner || '"."sp_dbremote_control" to "' || @owner
     || '"\x0A    ';
  message 'DBG_SRAMS: ' || @stmt to console debug only;
  execute immediate @stmt;
  set @stmt
     = '\x0A        create service "dbremote"\x0A              type ''raw''\x0A              methods ''get,put,delete''\x0A              authorization on\x0A              user "' || @owner
     || '"\x0A              url elements\x0A              as call "' || @owner
     || '"."sp_dbremote_main"( :URL1, :URL2 );\x0A    ';
  message 'DBG_SRAMS: ' || @stmt to console debug only;
  execute immediate @stmt;
  set @stmt
     = '\x0A        create service "dbremote/control"\x0A              type ''raw''\x0A              methods ''get''\x0A              authorization on\x0A              user "' || @owner
     || '"\x0A              url elements\x0A              as call "' || @owner
     || '"."sp_dbremote_control"( :URL1, :URL2 );\x0A    ';
  message 'DBG_SRAMS: ' || @stmt to console debug only;
  execute immediate @stmt;
  set @stmt
     = '\x0A        create server "dbremote_msgs_server"\x0A        class ''directory''\x0A        using ''root=' || @root_dir
     || ';subdirs=1;createdirs=no''\x0A    ';
  message 'DBG_SRAMS: ' || @stmt to console debug only;
  execute immediate @stmt;
  set @stmt
     = '\x0A        create externlogin "' || @owner
     || '" to "dbremote_msgs_server"\x0A    ';
  message 'DBG_SRAMS: ' || @stmt to console debug only;
  execute immediate @stmt;
  for l_users as c_users dynamic scroll cursor for
    select current publisher as user_name
      where current publisher is not null union
    select su.user_name
      from SYS.SYSREMOTEUSER as sru
        join SYS.SYSUSER as su on sru.user_id = su.user_id
  do
    if not exists(select 1
        from SYS.SYSGROUP as sg
          join SYS.SYSUSER as su1 on sg.group_id = su1.user_id
          join SYS.SYSUSER as su2 on sg.group_member = su2.user_id
        where su1.user_name = @owner
        and su2.user_name = @c_user) then
      set @stmt
         = '\x0A                grant membership in group "' || @owner || '" to "' || user_name
         || '"\x0A            ';
      message 'DBG_SRAMS: ' || @stmt to console debug only;
      execute immediate @stmt
    end if;
    set @stmt
       = '\x0A            create externlogin "' || user_name
       || '" to "dbremote_msgs_server"\x0A        ';
    message 'DBG_SRAMS: ' || @stmt to console debug only;
    execute immediate @stmt
  end for;
  if not exists(select 1
      from SYS.SYSEXTERNLOGIN as sel
        join SYS.SYSSERVER as ss on sel.srvid = ss.srvid
        join SYS.SYSUSER as su on sel.user_id = su.user_id
      where ss.srvname = 'dbremote_msgs_server'
      and su.user_name = current user) then
    set @stmt
       = '\x0A            create externlogin "' || current user
       || '" to "dbremote_msgs_server"\x0A        ';
    message 'DBG_SRAMS: ' || @stmt to console debug only;
    execute immediate @stmt
  end if;
  set @stmt
     = '\x0A        create existing table "' || @owner
     || '"."dbremote_msgs"\x0A        at ''dbremote_msgs_server;;;.''\x0A    ';
  message 'DBG_SRAMS: ' || @stmt to console debug only;
  execute immediate @stmt
end
