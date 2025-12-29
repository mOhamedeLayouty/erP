-- TRIGGER: DBA.tr_car_doc_son_rec
-- ON TABLE: DBA.car_doc_son_rec
-- generated_at: 2025-12-29T13:52:33.689Z

create trigger tr_car_doc_son_rec after insert order 1 on
DBA.car_doc_son_rec
referencing new as new_name
for each row /* WHEN( search_condition ) */
begin
  declare @doc_t_num varchar(10);
  declare @req_doc_t_num varchar(10);
  set @doc_t_num = new_name.doc_t_num;
  set @req_doc_t_num = new_name.request_doc_t_num;
  if @req_doc_t_num is not null then
    update DBA.car_request_doc_son_rec set DBA.car_request_doc_son_rec.done_doc_t_num = @doc_t_num
      where DBA.car_request_doc_son_rec.doc_t_num = @req_doc_t_num
  end if
end
