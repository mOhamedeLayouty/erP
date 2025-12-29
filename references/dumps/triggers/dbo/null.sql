-- TRIGGER: dbo.null
-- ON TABLE: dbo.maint_plan
-- generated_at: 2025-12-29T13:52:33.697Z

create trigger REFACTION after delete on dbo.maint_plan
referencing old as oldkey
for each row
begin
  delete from dbo.maint_plan_report
  where plan_id = oldkey.plan_id
end
