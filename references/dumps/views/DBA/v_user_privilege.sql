-- VIEW: DBA.v_user_privilege
-- generated_at: 2025-12-29T14:36:30.559Z
-- object_id: 24884
-- table_id: 1459
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.v_user_privilege as /* view_column_name, ... */
  select distinct
    security_users.user_name,
    security_users.super_user,
    security_users.full_name_a,
    security_users.remarks,
    security_template_c.control_id as system_id,
    security_template_b.control_id as menu_id,
    security_template_c.description_e as system_name_e,
    security_template_c.description_a as system_name_a,
    security_template_b.description_e as menu_name_e,
    security_template_b.description_a as menu_name_a,
    security_template_a.description_e as secuirty_name_e,
    security_template_a.description_a as secuirty_name_a,
    control.parent_id,
    control.control_id,
    control.info_view,
    control.info_update,
    control.info_delete,
    control.info_insert,
    control.info_print
    from DBA.security_template as security_template_a left outer join DBA.security_template as security_template_b on security_template_a.parent_id = security_template_b.control_id left outer join DBA.security_template as security_template_c on security_template_b.parent_id = security_template_c.control_id
      ,DBA.security_info as control,DBA.security_users
    where(security_template_a.control_id = control.control_id)
    and(control.parent_id = security_template_c.control_id)
    and(security_users.user_name = control.user_name)
    and((security_template_c.parent_id = '#$%')) union
  select distinct
    security_users.user_name,
    security_users.super_user,
    security_users.full_name_a,
    security_users.remarks,
    security_template_c.control_id as system_id,
    security_template_b.control_id as menu_id,
    security_template_c.description_e as system_name_e,
    security_template_c.description_a as system_name_a,
    security_template_b.description_e as menu_name_e,
    security_template_b.description_a as menu_name_a,
    security_template_a.description_e as secuirty_name_e,
    security_template_a.description_a as secuirty_name_a,
    control.parent_id,
    control.control_id,
    control.c_view as info_view,
    control.c_update as info_update,
    control.c_delete as info_delete,
    control.c_insert as info_insert,
    control.c_print as info_print
    from DBA.security_template as security_template_a left outer join DBA.security_template as security_template_b
      on security_template_a.parent_id = security_template_b.control_id
      left outer join DBA.security_template as security_template_c
      on security_template_b.parent_id = security_template_c.control_id
      ,DBA.group_control as control,DBA.security_users
    where(security_template_a.control_id = control.control_id)
    and(control.parent_id = security_template_c.control_id)
    and(control.group_code = security_users.security_group_code)
    and((security_template_c.parent_id = '#$%')) union
  select distinct
    security_users.user_name,
    security_users.super_user,
    security_users.full_name_a,
    security_users.remarks,
    '' as system_id,
    '' as menu_id,
    '' as system_name_e,
    '' as system_name_a,
    '' as menu_name_e,
    '' as menu_name_a,
    '' as secuirty_name_e,
    '' as secuirty_name_a,
    '',
    '',
    '' as info_view,
    '' as info_update,
    '' as info_delete,
    '' as info_insert,
    '' as info_print
    from DBA.security_users where security_users.super_user = 1
