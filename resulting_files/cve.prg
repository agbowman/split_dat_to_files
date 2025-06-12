CREATE PROGRAM cve
 SET code_set = 0
 SET code_set = value( $1)
 SELECT
  e.code_set, c.display, e.code_value,
  e.field_type, e.field_name, e.field_value,
  e.updt_applctx, e.updt_dt_tm, e.updt_id,
  e.updt_cnt, e.updt_task
  FROM code_value c,
   code_value_extension e
  WHERE c.active_ind=1
   AND c.code_set=code_set
   AND e.code_value=c.code_value
  ORDER BY c.display
  WITH nocounter
 ;end select
END GO
