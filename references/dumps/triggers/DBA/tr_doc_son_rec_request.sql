-- TRIGGER: DBA.tr_doc_son_rec_request
-- ON TABLE: DBA.doc_son_rec
-- generated_at: 2025-12-29T13:52:33.689Z

create trigger tr_doc_son_rec_request after insert order 1 on
DBA.doc_son_rec
referencing new as new_name
for each row
/* WHEN( search_condition ) */
//V1.2 add center and location
begin
  declare @doc_t_num varchar(10);
  declare @req_doc_t_num varchar(10);
  declare @service_center integer;
  declare @location_id integer;
  set @doc_t_num = new_name.doc_t_num;
  set @req_doc_t_num = new_name.request_doc_t_num;
  set @service_center = new_name.service_center;
  set @location_id = new_name.location_id;
  if @req_doc_t_num is not null then
    update DBA.request_doc_son_rec set DBA.request_doc_son_rec.done_doc_t_num = @doc_t_num
      where DBA.request_doc_son_rec.doc_t_num = @req_doc_t_num and request_doc_son_rec.service_center = @service_center
      and request_doc_son_rec.location_id = @location_id
  end if
end
