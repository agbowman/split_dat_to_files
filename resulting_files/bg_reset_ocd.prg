CREATE PROGRAM bg_reset_ocd
 DECLARE bg_ocd = i4
 DECLARE bg_from_envid = i4
 DECLARE bg_to_envid = i4
 SET bg_ocd =  $1
 SET bg_from_envid =  $2
 SET bg_to_envid =  $3
 DELETE  FROM ocd_package
  WHERE ocd=101000
   AND environment_id=bg_to_envid
 ;end delete
 DELETE  FROM ocd_package_component
  WHERE ocd=101000
   AND environment_id=bg_to_envid
 ;end delete
 INSERT  FROM ocd_package op
  (op.environment_id, op.error_msg, op.ocd,
  op.product_area_name, op.product_area_number, op.revision_number,
  op.status, op.status_dt_tm)(SELECT
   bg_to_envid, o.error_msg, 101000,
   o.product_area_name, o.product_area_number, o.revision_number,
   "READY TO PACKAGE", o.status_dt_tm
   FROM ocd_package o
   WHERE o.ocd=bg_ocd
    AND o.environment_id=bg_from_envid)
 ;end insert
 INSERT  FROM ocd_package_component p
  (p.archive_feature, p.component_type, p.end_state,
  p.environment_id, p.error_msg, p.ocd,
  p.schema_dt_tm, p.status)(SELECT
   c.archive_feature, c.component_type, c.end_state,
   bg_to_envid, c.error_msg, 101000,
   c.schema_dt_tm, "READY TO PACKAGE"
   FROM ocd_package_component c
   WHERE c.ocd=bg_ocd
    AND c.environment_id=bg_from_envid)
 ;end insert
END GO
