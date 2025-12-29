-- PF: UNKNOWN_SCHEMA.SP_price_upload
-- proc_id: 425
-- generated_at: 2025-12-29T13:53:28.814Z

create procedure DBA.SP_price_upload( 
  //
  //v1.1 make sparepart get more chars (50)
  //
  in @sparepart varchar(50),
  in @price varchar(12),
  in @min_price varchar(12),
  in @official_price varchar(12) ) 
--Ver 1.0
begin
  insert into price_upload
    ( sparepart,
    price,
    min_price,
    official_price,
    flag ) values
    ( @sparepart,
    @price,
    @min_price,
    @official_price,
    0 ) 
end
