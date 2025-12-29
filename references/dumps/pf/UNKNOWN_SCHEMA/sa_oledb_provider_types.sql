-- PF: UNKNOWN_SCHEMA.sa_oledb_provider_types
-- proc_id: 297
-- generated_at: 2025-12-29T13:53:28.779Z

create procedure dbo.sa_oledb_provider_types( 
  in inDataType unsigned smallint default 0,
  in inBestMatch bit default 0 ) 
result( 
  TYPE_NAME char(128),
  DATA_TYPE unsigned smallint,
  COLUMN_SIZE unsigned integer,
  LITERAL_PREFIX char(128),
  LITERAL_SUFFIX char(128),
  CREATE_PARAMS char(128),
  IS_NULLABLE bit,
  CASE_SENSITIVE bit,
  SEARCHABLE unsigned integer,
  UNSIGNED_ATTRIBUTE bit,
  FIXED_PREC_SCALE bit,
  AUTO_UNIQUE_VALUE bit,
  LOCAL_TYPE_NAME char(128),
  MINIMUM_SCALE smallint,
  MAXIMUM_SCALE smallint,
  GUID uniqueidentifier,
  TYPELIB char(128),
  VERSION char(128),
  IS_LONG bit,
  BEST_MATCH bit,
  IS_FIXEDLENGTH bit ) dynamic result sets 1
on exception resume
begin
  select distinct
    domain_name as TYPE_NAME,
    cast(case type_name
    when 'smallint' then 2
    when 'integer' then 3
    when 'real' then 4
    when 'float' then 4
    when 'double' then 5
    when 'bit' then 11
    when 'tinyint' then 17
    when 'unsigned smallint' then 18
    when 'unsigned int' then 19
    when 'bigint' then 20
    when 'unsigned bigint' then 21
    when 'uniqueidentifier' then 72
    when 'binary' then 128
    when 'long binary' then 128
    when 'varbinary' then 128
    when 'varbit' then 129
    when 'long varbit' then 129
    when 'st_geometry' then 129
    when 'char' then 129
    when 'long varchar' then 129
    when 'varchar' then 129
    when 'nchar' then 130
    when 'nvarchar' then 130
    when 'long nvarchar' then 130
    when 'numeric' then 131
    when 'decimal' then 131
    when 'date' then 133
    when 'time' then 145
    when 'timestamp' then 135
    when 'xml' then 141
    when 'timestamp with time zone' then 146
    else 132
    end as unsigned smallint) as DATA_TYPE,
    cast(case type_name
    when 'smallint' then 5
    when 'integer' then 10
    when 'real' then 7
    when 'float' then 7
    when 'double' then 15
    when 'bit' then 1
    when 'tinyint' then 3
    when 'unsigned smallint' then 5
    when 'unsigned int' then 10
    when 'bigint' then 20
    when 'unsigned bigint' then 20
    when 'uniqueidentifier' then 16
    when 'binary' then 32767
    when 'long binary' then 2147483647
    when 'varbinary' then 32767
    when 'varbit' then 32767
    when 'long varbit' then 2147483647
    when 'st_geometry' then 2147483647
    when 'char' then 32767
    when 'long varchar' then 2147483647
    when 'varchar' then 32767
    when 'nchar' then 32764
    when 'nvarchar' then 32764
    when 'long nvarchar' then 2147483647
    when 'numeric' then 127
    when 'decimal' then 127
    when 'date' then 10
    when 'time' then 16
    when 'timestamp' then 26
    when 'xml' then 2147483647
    when 'timestamp with time zone' then 33
    else 32767
    end as unsigned integer) as COLUMN_SIZE,
    cast(case type_name
    when 'uniqueidentifier' then ''''
    when 'binary' then '0x'
    when 'long binary' then '0x'
    when 'varbinary' then '0x'
    when 'varbit' then ''''
    when 'long varbit' then ''''
    when 'st_geometry' then ''''
    when 'char' then ''''
    when 'long varchar' then ''''
    when 'varchar' then ''''
    when 'nchar' then 'N'''
    when 'nvarchar' then 'N'''
    when 'long nvarchar' then 'N'''
    when 'date' then ''''
    when 'time' then ''''
    when 'timestamp' then ''''
    when 'xml' then ''''
    when 'timestamp with time zone' then ''''
    else null
    end as char) as LITERAL_PREFIX,
    cast(case type_name
    when 'uniqueidentifier' then ''''
    when 'varbit' then ''''
    when 'long varbit' then ''''
    when 'st_geometry' then ''''
    when 'char' then ''''
    when 'long varchar' then ''''
    when 'varchar' then ''''
    when 'nchar' then ''''
    when 'nvarchar' then ''''
    when 'long nvarchar' then ''''
    when 'date' then ''''
    when 'time' then ''''
    when 'timestamp' then ''''
    when 'xml' then ''''
    when 'timestamp with time zone' then ''''
    else null
    end as char) as LITERAL_SUFFIX,
    if type_name not like 'long %' then
      if type_name like '%char%'
      or type_name like '%varbit%'
      or type_name like '%binary%' then
        'max length'
      else if(type_name = 'numeric' or type_name = 'decimal') then 'precision,scale' endif
      endif
    endif as CREATE_PARAMS,
    cast(1 as bit) as IS_NULLABLE,
    cast(if(type_name like '%char%' or type_name like 'xml')
    and 'A' <> 'a' then 1 else 0 endif as bit) as CASE_SENSITIVE,
    cast(4 as unsigned integer) as SEARCHABLE,
    cast(if type_name in( 
    'smallint','integer','bigint','real','float','double','decimal','numeric' ) then
      0
    else
      if type_name = 'bit'
      or type_name = 'varbit'
      or type_name = 'long varbit'
      or type_name = 'tinyint'
      or type_name like 'unsigned%' then
        1
      endif
    endif as bit) as UNSIGNED_ATTRIBUTE,
    cast(0 as bit) as FIXED_PREC_SCALE,
    cast(case type_name
    when 'smallint' then 1
    when 'integer' then 1
    when 'real' then 1
    when 'float' then 1
    when 'double' then 1
    when 'bit' then 0
    when 'tinyint' then 1
    when 'unsigned smallint' then 1
    when 'unsigned int' then 1
    when 'bigint' then 1
    when 'unsigned bigint' then 1
    when 'uniqueidentifier' then 0
    when 'binary' then 0
    when 'long binary' then 0
    when 'varbinary' then 0
    when 'varbit' then 0
    when 'long varbit' then 0
    when 'st_geometry' then 0
    when 'char' then 0
    when 'long varchar' then 0
    when 'varchar' then 0
    when 'nchar' then 0
    when 'nvarchar' then 0
    when 'long nvarchar' then 0
    when 'numeric' then 1
    when 'decimal' then 1
    when 'date' then 0
    when 'time' then 0
    when 'timestamp' then 1
    when 'xml' then 0
    when 'timestamp with time zone' then 0
    else 0
    end as bit) as AUTO_UNIQUE_VALUE,
    cast(null as char(128)) as LOCAL_TYPE_NAME,
    cast(case type_name
    when 'numeric' then 0
    when 'decimal' then 0
    else null
    end as smallint) as MINIMUM_SCALE,
    cast(case type_name
    when 'numeric' then 127
    when 'decimal' then 127
    else null
    end as smallint) as MAXIMUM_SCALE,
    cast(null as uniqueidentifier) as GUID,
    cast(null as char(128)) as TYPELIB,
    cast(null as char(128)) as VERSION,
    cast(if type_name like 'long%'
    or type_name like 'st_%'
    or type_name = 'xml' then 1 else 0 endif as bit) as IS_LONG,
    cast(case type_name
    when 'smallint' then 1
    when 'integer' then 1
    when 'real' then 1
    when 'float' then 0
    when 'double' then 1
    when 'bit' then 1
    when 'tinyint' then 1
    when 'unsigned smallint' then 1
    when 'unsigned int' then 1
    when 'bigint' then 1
    when 'unsigned bigint' then 1
    when 'uniqueidentifier' then 1
    when 'binary' then 1
    when 'long binary' then 0
    when 'varbinary' then 0
    when 'varbit' then 0
    when 'long varbit' then 0
    when 'st_geometry' then 0
    when 'char' then 0
    when 'long varchar' then 0
    when 'varchar' then 1
    when 'nchar' then 0
    when 'nvarchar' then 1
    when 'long nvarchar' then 0
    when 'numeric' then 1
    when 'decimal' then 0
    when 'date' then 1
    when 'time' then 1
    when 'timestamp' then 1
    when 'xml' then 1
    when 'timestamp with time zone' then 1
    else 0
    end as bit) as BEST_MATCH,
    cast(case type_name
    when 'smallint' then 1
    when 'integer' then 1
    when 'real' then 1
    when 'float' then 1
    when 'double' then 1
    when 'bit' then 1
    when 'tinyint' then 1
    when 'unsigned smallint' then 1
    when 'unsigned int' then 1
    when 'bigint' then 1
    when 'unsigned bigint' then 1
    when 'uniqueidentifier' then 1
    when 'binary' then 0
    when 'long binary' then 0
    when 'varbinary' then 0
    when 'varbit' then 0
    when 'long varbit' then 0
    when 'st_geometry' then 0
    when 'char' then 0
    when 'long varchar' then 0
    when 'varchar' then 0
    when 'nchar' then 0
    when 'nvarchar' then 0
    when 'long nvarchar' then 0
    when 'numeric' then 1
    when 'decimal' then 1
    when 'date' then 1
    when 'time' then 1
    when 'timestamp' then 1
    when 'xml' then 0
    when 'timestamp with time zone' then 1
    else 0
    end as bit) as IS_FIXEDLENGTH
    from(select * from SYS.SYSDOMAIN union select 4,'real',7,7) as sysd
    where domain_name not like 'java%'
    and DATA_TYPE
     = if inDataType = 0 then DATA_TYPE
    else inDataType
    endif
    and BEST_MATCH
     = if inBestMatch = 0 then BEST_MATCH
    else inBestMatch
    endif union all
  select distinct
    type_name as TYPE_NAME,
    cast(case type_name
    when 'money' then 6
    when 'smallmoney' then 6
    when 'datetime' then 135
    when 'smalldatetime' then 135
    when 'text' then 129
    when 'image' then 128
    when 'oldbit' then 132
    when 'sysname' then 132
    when 'uniqueidentifierstr' then 132
    when 'ntext' then 130
    else 132
    end as unsigned smallint) as DATA_TYPE,
    cast(case type_name
    when 'text' then 2147483647
    when 'image' then 2147483647
    when 'ntext' then 2147483647
    when 'datetime' then 26
    when 'smalldatetime' then 26
    else width
    end as unsigned integer) as COLUMN_SIZE,
    cast(case type_name
    when 'datetime' then ''''
    when 'smalldatetime' then ''''
    when 'text' then ''''
    when 'image' then '0x'
    when 'sysname' then ''''
    when 'uniqueidentifierstr' then ''''
    when 'ntext' then 'N'''
    else null
    end as char) as LITERAL_PREFIX,
    cast(case type_name
    when 'datetime' then ''''
    when 'smalldatetime' then ''''
    when 'text' then ''''
    when 'sysname' then ''''
    when 'uniqueidentifierstr' then ''''
    when 'ntext' then ''''
    else null
    end as char) as LITERAL_SUFFIX,
    if type_name not like 'long %' then
      if type_name like '%char%' or type_name like '%binary%' then
        'max length'
      else
        if(type_name = 'numeric' or type_name = 'decimal') then 'precision,scale' endif
      endif
    endif as CREATE_PARAMS,cast(1 as bit) as IS_NULLABLE,cast(if type_name like '%char%' and 'A' <> 'a' then 1 else 0 endif as bit) as CASE_SENSITIVE,
    cast(4 as unsigned integer) as SEARCHABLE,
    cast(case type_name
    when 'money' then 0
    when 'smallmoney' then 0
    when 'oldbit' then 1 end as bit) as UNSIGNED_ATTRIBUTE,
    cast(case type_name
    when 'money' then 1
    when 'smallmoney' then 1
    else 0
    end as bit) as FIXED_PREC_SCALE,
    cast(case type_name
    when 'money' then 1
    when 'smallmoney' then 1
    when 'datetime' then 0
    when 'smalldatetime' then 0
    when 'text' then 0
    when 'image' then 0
    when 'oldbit' then 1
    when 'sysname' then 0
    when 'uniqueidentifierstr' then 0
    when 'ntext' then 0
    else 0
    end as bit) as AUTO_UNIQUE_VALUE,
    cast(null as char(128)) as LOCAL_TYPE_NAME,
    cast(null as smallint) as MINIMUM_SCALE,
    cast(null as smallint) as MAXIMUM_SCALE,
    cast(null as uniqueidentifier) as GUID,
    cast(null as char(128)) as TYPELIB,
    cast(null as char(128)) as VERSION,
    cast(case type_name
    when 'money' then 0
    when 'smallmoney' then 0
    when 'datetime' then 0
    when 'smalldatetime' then 0
    when 'text' then 1
    when 'image' then 1
    when 'oldbit' then 0
    when 'sysname' then 0
    when 'uniqueidentifierstr' then 0
    when 'ntext' then 1
    else 0
    end as bit) as IS_LONG,
    cast(case type_name
    when 'money' then 1
    when 'smallmoney' then 0
    when 'datetime' then 0
    when 'smalldatetime' then 0
    when 'text' then 0
    when 'image' then 0
    when 'oldbit' then 0
    when 'sysname' then 0
    when 'uniqueidentifierstr' then 1
    when 'ntext' then 0
    else 0
    end as bit) as BEST_MATCH,
    cast(case type_name
    when 'money' then 1
    when 'smallmoney' then 1
    when 'datetime' then 1
    when 'smalldatetime' then 1
    when 'text' then 0
    when 'image' then 0
    when 'oldbit' then 1
    when 'sysname' then 1
    when 'uniqueidentifierstr' then 1
    when 'ntext' then 0
    else 0
    end as bit) as IS_FIXEDLENGTH
    from SYS.SYSUSERTYPE
    where creator = 0
    and type_name not like 'java%'
    and DATA_TYPE
     = if inDataType = 0 then DATA_TYPE
    else inDataType
    endif
    and BEST_MATCH
     = if inBestMatch = 0 then BEST_MATCH
    else inBestMatch
    endif
    order by 2 asc,20 desc,19 asc
end
