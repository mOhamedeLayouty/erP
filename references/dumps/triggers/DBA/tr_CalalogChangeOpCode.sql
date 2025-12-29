-- TRIGGER: DBA.tr_CalalogChangeOpCode
-- ON TABLE: DBA.ws_Operation
-- generated_at: 2025-12-29T13:52:33.690Z

create trigger tr_CalalogChangeOpCode after update of OperationCode
order 1 on DBA.ws_Operation
referencing old as old_rec new as new_rec
for each row
begin
  update ws_CatalogDetail
    set ws_CatalogDetail.OperationCode = new_rec.OperationCode
    where ws_CatalogDetail.OperationID = new_rec.OpertationId
    and ws_CatalogDetail.OperationCode = old_rec.OperationCode
end
