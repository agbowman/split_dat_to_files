CREATE PROGRAM dm_rdm_reset_long_rows:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dm_rdm_reset_long_rows..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE processind = i4 WITH protect, noconstant(0)
 DECLARE idomain = vc WITH public, noconstant("ICD9 Interrogator")
 DECLARE iname = vc WITH public, noconstant("Large Long Text Row Reset")
 DECLARE dtt_loop = i4
 DECLARE dtt_cnt = i4
 DECLARE dtt_max_len = i4 WITH protect, constant(50000)
 DECLARE dtt_status_flag = i2 WITH protect, constant(2)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain=idomain
   AND di.info_name=iname
  DETAIL
   processind = 1
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Select from DM_INFO failed: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (processind=1)
  FREE RECORD dm_data
  RECORD dm_data(
    1 cnt = i4
    1 qual[*]
      2 pe_name = vc
      2 pe_id = f8
      2 root_col = vc
      2 long_col = vc
      2 lt_len = i4
      2 pk_id = f8
  )
  SELECT INTO "NL:"
   FROM dm_text_find_data t
   WHERE dm_text_find_data_id > 0.0
    AND parent_entity_id > 0.0
   DETAIL
    dm_data->cnt = (dm_data->cnt+ 1), stat = alterlist(dm_data->qual,dm_data->cnt), dm_data->qual[
    dm_data->cnt].pe_name = t.parent_entity_name,
    dm_data->qual[dm_data->cnt].pe_id = t.parent_entity_id, dm_data->qual[dm_data->cnt].root_col = t
    .parent_entity_col, dm_data->qual[dm_data->cnt].long_col = t.search_col_name,
    dm_data->qual[dm_data->cnt].pk_id = t.dm_text_find_data_id
   WITH nocounter
  ;end select
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Query on DM_TEXT_FIND_DATA failed: ",errmsg)
   GO TO exit_script
  ENDIF
  FOR (dtt_loop = 1 TO dm_data->cnt)
   EXECUTE dm_rdm_reset_long_rows_c dtt_loop
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Query for Long_Text row length failed: ",errmsg)
    GO TO exit_script
   ENDIF
  ENDFOR
  FOR (dtt_loop = 1 TO dm_data->cnt)
    IF ((dm_data->qual[dtt_loop].lt_len >= dtt_max_len))
     UPDATE  FROM dm_text_find_data d
      SET d.status_flag = dtt_status_flag
      WHERE (d.dm_text_find_data_id=dm_data->qual[dtt_loop].pk_id)
      WITH nocounter
     ;end update
     SET dtt_cnt = (dtt_cnt+ curqual)
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed updating DM_TEXT_FIND_DATA: ",errmsg)
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
  DELETE  FROM dm_info di
   WHERE di.info_domain=idomain
    AND di.info_name=iname
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Delete from DM_INFO failed: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = concat("There were ",trim(cnvtstring(dtt_cnt)),
   " rows in DM_TEXT_FIND_DATA reset to status_flag = 2")
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = concat("Success:  No work was required during this run.")
 ENDIF
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
