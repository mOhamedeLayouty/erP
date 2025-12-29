-- PF: UNKNOWN_SCHEMA.f_Tafquet
-- proc_id: 399
-- generated_at: 2025-12-29T13:53:28.807Z

create function DBA.f_Tafquet( in @TheNo numeric(18,2),in @an_currencyid varchar(20) ) 
returns varchar(1000)
begin
  declare @currency_ArabicName varchar(50);
  declare @currency_SubArabicName varchar(50);
  declare @TheNoAfterReplicate varchar(15);
  declare @ComWithWord varchar(1000);
  declare @TheNoWithDecimal varchar(400);
  declare @ThreeWords integer;
  declare local temporary table @Tafquet(
    num integer null,
    NoName varchar(100) null,) on commit delete rows;if @TheNo <= 0 then return 'zero' end if;
  set @TheNoAfterReplicate = "right"(replicate('0',15)+cast(floor(@TheNo) as varchar(15)),15);
  set @ThreeWords = 0;
  set @ComWithWord = ' ';
  insert into @Tafquet values( 0,'' ) ;
  insert into @Tafquet values( 1,'����' ) ;
  insert into @Tafquet values( 2,'�����' ) ;
  insert into @Tafquet values( 3,'�����' ) ;
  insert into @Tafquet values( 4,'�����' ) ;
  insert into @Tafquet values( 5,'����' ) ;
  insert into @Tafquet values( 6,'���' ) ;
  insert into @Tafquet values( 7,'����' ) ;
  insert into @Tafquet values( 8,'������' ) ;
  insert into @Tafquet values( 9,'����' ) ;
  insert into @Tafquet values( 10,'����' ) ;
  insert into @Tafquet values( 11,'���� ���' ) ;
  insert into @Tafquet values( 12,'���� ���' ) ;
  insert into @Tafquet values( 13,'����� ���' ) ;
  insert into @Tafquet values( 14,'����� ���' ) ;
  insert into @Tafquet values( 15,'���� ���' ) ;
  insert into @Tafquet values( 16,'��� ���' ) ;
  insert into @Tafquet values( 17,'���� ���' ) ;
  insert into @Tafquet values( 18,'������ ���' ) ;
  insert into @Tafquet values( 19,'���� ���' ) ;
  insert into @Tafquet values( 20,'�����' ) ;
  insert into @Tafquet values( 30,'������' ) ;
  insert into @Tafquet values( 40,'������' ) ;
  insert into @Tafquet values( 50,'�����' ) ;
  insert into @Tafquet values( 60,'����' ) ;
  insert into @Tafquet values( 70,'�����' ) ;
  insert into @Tafquet values( 80,'������' ) ;
  insert into @Tafquet values( 90,'�����' ) ;
  insert into @Tafquet values( 100,'����' ) ;
  insert into @Tafquet values( 200,'������' ) ;
  insert into @Tafquet values( 300,'��������' ) ;
  insert into @Tafquet values( 400,'��������' ) ;
  insert into @Tafquet values( 500,'�������' ) ;
  insert into @Tafquet values( 600,'������' ) ;
  insert into @Tafquet values( 700,'�������' ) ;
  insert into @Tafquet values( 800,'��������' ) ;
  insert into @Tafquet values( 900,'�������' ) ;
  insert into @Tafquet
    select FirstN.num+LasteN.num,LasteN.NoName+' � '+FirstN.NoName
      from(select * from @Tafquet where num >= 20 and num <= 90) as FirstN
        cross join(select * from @Tafquet where num >= 1 and num <= 9) as LasteN;
  insert into @Tafquet
    select FirstN.num+LasteN.num,FirstN.NoName+' � '+LasteN.NoName from(select * from @Tafquet where num >= 100 and num <= 900) as FirstN
        cross join(select * from @Tafquet where num >= 1 and num <= 99) as LasteN;
  if "left"(@TheNoAfterReplicate,3) > 0 then
    set @ComWithWord = @ComWithWord+ISNULL((select NoName from @Tafquet where num = "left"(@TheNoAfterReplicate,3)),'')+' ������'
  end if;
  if "left"("right"(@TheNoAfterReplicate,12),3) > 0 and "left"(@TheNoAfterReplicate,3) > 0 then
    set @ComWithWord = @ComWithWord+' � '
  end if;
  if "left"("right"(@TheNoAfterReplicate,12),3) > 0 then
    set @ComWithWord = @ComWithWord+ISNULL((select NoName from @Tafquet where num = "left"("right"(@TheNoAfterReplicate,12),3)),'')+' �����'
  end if;
  if "left"("right"(@TheNoAfterReplicate,9),3) > 0 then
    set @ComWithWord = @ComWithWord+case when @TheNo > 999000000 then ' �' else '' end;
    set @ThreeWords = "left"("right"(@TheNoAfterReplicate,9),3);
    set @ComWithWord = @ComWithWord+ISNULL((select case when @ThreeWords > 2 then NoName end from @Tafquet where num = "left"("right"(@TheNoAfterReplicate,9),3)),'')+case when @ThreeWords = 2 then ' �������' when @ThreeWords between 3 and 10 then ' ������' else ' �����' end
  end if;
  if "left"("right"(@TheNoAfterReplicate,6),3) > 0 then
    set @ComWithWord = @ComWithWord+case when @TheNo > 999000 then ' �' else '' end;
    set @ThreeWords = "left"("right"(@TheNoAfterReplicate,6),3);
    set @ComWithWord = @ComWithWord+ISNULL((select case when @ThreeWords > 2 then NoName end from @Tafquet where num = "left"("right"(@TheNoAfterReplicate,6),3)),'')+case when @ThreeWords = 2 then ' �����' when @ThreeWords between 3 and 10 then ' ����' else ' ���' end
  end if;
  if "right"(@TheNoAfterReplicate,3) > 0 then
    if @TheNo > 999 then
      set @ComWithWord = @ComWithWord+' �'
    end if;
    if "right"(@TheNoAfterReplicate,2) = '01' or "right"(@TheNoAfterReplicate,2) = '02' then
      --set @ComWithWord=@ComWithWord + case  when @TheNo>1000  then ' �'  else '' end 
      --set @ThreeWords=left(right(@TheNoAfterReplicate,6),3)
      set @ComWithWord = @ComWithWord+' '+ISNULL((select noname from @Tafquet where num = "right"(@TheNoAfterReplicate,3)),'')
    end if;
    set @ThreeWords = "right"(@TheNoAfterReplicate,2);
    if @ThreeWords = 0 then
      -- set @ComWithWord=@ComWithWord + ' �' 
      set @ComWithWord = @ComWithWord+ISNULL((select NoName from @Tafquet where @ThreeWords = 0 and num = "right"(@TheNoAfterReplicate,3)),'')
    end if end if;
  set @ThreeWords = "right"(@TheNoAfterReplicate,2);
  set @ComWithWord = @ComWithWord+ISNULL((select NoName from @Tafquet where @ThreeWords > 2 and num = "right"(@TheNoAfterReplicate,3)),'');
  select top 1 name,sub_curr_name into @currency_ArabicName,@currency_SubArabicName from Ledger.cur where curr_id = @an_currencyid order by company_code desc;
  set @ComWithWord = @ComWithWord+' '+case when @ThreeWords = 2 then ' '+@currency_ArabicName when @ThreeWords between 3 and 10 then ' '+@currency_ArabicName else ' '+@currency_ArabicName end;
  if "right"(rtrim(@ComWithWord),1) = ',' then
    set @ComWithWord = substring(@ComWithWord,1,len(@ComWithWord)-1)
  end if;
  if "right"(@TheNo,len(@TheNo)-charindex('.',@TheNo)) > 0 and charindex('.',@TheNo) <> 0 then
    set @ThreeWords = "left"("right"(round(@TheNo,2),2),2);
    set @TheNoWithDecimal = ' �'+ISNULL((select NoName from @Tafquet where num = "left"("right"(round(@TheNo,2),2),2) and @ThreeWords > 2),'');
    set @TheNoWithDecimal = @TheNoWithDecimal+case when @ThreeWords = 2 then ' '+@currency_SubArabicName when @ThreeWords between 3 and 10 then ' '+@currency_SubArabicName else ' '+@currency_SubArabicName end;
    set @ComWithWord = @ComWithWord+' � '+convert(varchar(500),@ThreeWords)+case when @ThreeWords = 2 then ' '+@currency_SubArabicName when @ThreeWords between 3 and 10 then ' '+@currency_SubArabicName else ' '+@currency_SubArabicName end --@TheNoWithDecimal 
  end if;
  set @ComWithWord = @ComWithWord; // + ' ��� �� ��� ';
  return rtrim(@ComWithWord)
end
