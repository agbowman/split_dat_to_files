CREATE PROGRAM dm_create_merge_translates:dba
 DECLARE dcmt_target_id = f8 WITH protect
 DECLARE dcmt_source_id = f8 WITH protect
 SET dcmt_target_id = 0.0
 SET dcmt_source_id = 0.0
 CALL echo("Start dm_create_merge_translates")
 SELECT INTO "nl:"
  l.info_number
  FROM dm_info@ref_data_link l
  WHERE l.info_domain="DATA MANAGEMENT"
   AND l.info_name="DM_ENV_ID"
  DETAIL
   dcmt_source_id = l.info_number
  WITH nocounter
 ;end select
 IF (dcmt_source_id > 0.0)
  SELECT INTO "nl:"
   i.info_number
   FROM dm_info i
   WHERE i.info_domain="DATA MANAGEMENT"
    AND i.info_name="DM_ENV_ID"
   DETAIL
    dcmt_target_id = i.info_number
   WITH nocounter
  ;end select
  IF (dcmt_target_id > 0.0)
   EXECUTE dm_ins_merge_translates dcmt_source_id, dcmt_target_id
  ELSE
   CALL echo("Fatal Error: target environment id not found in dm_info@ref_data_link")
  ENDIF
 ELSE
  CALL echo("Fatal Error: source environment id not found in dm_info")
 ENDIF
#exit_program
 CALL echo("dm_create_merge_translates is finished")
END GO
