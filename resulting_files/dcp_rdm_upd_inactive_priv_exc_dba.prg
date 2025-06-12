CREATE PROGRAM dcp_rdm_upd_inactive_priv_exc:dba
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
 SET readme_data->message = "Readme Failed: Starting script dcp_rdm_upd_inactive_priv_exc.prg..."
 DECLARE error_msg = vc WITH protect
 DECLARE updt_cnt = i4 WITH protect, noconstant(- (1))
 DECLARE max_id = f8 WITH protect, noconstant(0.0)
 DECLARE min_range_id = f8 WITH protect, noconstant(0.0)
 DECLARE max_range_id = f8 WITH protect, noconstant(0.0)
 DECLARE range_inc = f8 WITH protect, noconstant(250000.0)
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_name="dcp_rdm_upd_inactive_priv_exc"
   AND di.info_domain="POWERCHART PRIVMAINT"
  DETAIL
   min_range_id = di.info_number, updt_cnt = di.updt_cnt
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to find the min_range_id from the dm_info table",
   error_msg)
  GO TO exit_script
 ENDIF
 IF ((updt_cnt=- (1)))
  SELECT INTO "nl:"
   min_val = min(pe.privilege_exception_id)
   FROM privilege_exception pe
   WHERE pe.privilege_exception_id > 0
   DETAIL
    min_range_id = min_val
   WITH nocounter
  ;end select
  IF (error(error_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat(
    "Failed to find minimum privilege_exception_id on privilege_exception table",error_msg)
   GO TO exit_script
  ENDIF
  INSERT  FROM dm_info d
   SET d.info_domain = "POWERCHART PRIVMAINT", d.info_name = "dcp_rdm_upd_inactive_priv_exc", d
    .info_date = cnvtdatetime(curdate,curtime3),
    d.info_number = min_range_id, d.info_long_id = 0, d.updt_applctx = reqinfo->updt_applctx,
    d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = 0, d.updt_id = reqinfo->updt_id,
    d.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (error(error_msg,1) != 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to Insert record into DM_INFO table",error_msg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  max_val = max(pe.privilege_exception_id)
  FROM privilege_exception pe
  WHERE pe.privilege_exception_id > 0
  DETAIL
   max_id = max_val
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to find maximum privilege_exception_id on privilege_exception",error_msg)
  GO TO exit_script
 ENDIF
 SET max_range_id = (min_range_id+ range_inc)
 WHILE (min_range_id <= max_id)
   UPDATE  FROM privilege_exception pe
    SET pe.active_ind = 1, pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task,
     pe.updt_cnt = (pe.updt_cnt+ 1), pe.updt_applctx = reqinfo->updt_applctx, pe.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    WHERE pe.privilege_exception_id BETWEEN min_range_id AND max_range_id
     AND pe.active_ind = null
   ;end update
   IF (error(error_msg,1) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update active_ind on privilege_exception table",
     error_msg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   IF (max_range_id >= max_id)
    SET save_id = (max_id+ 1)
   ELSE
    SET save_id = (max_range_id+ 1)
   ENDIF
   UPDATE  FROM dm_info d
    SET d.info_number = save_id, d.info_long_id = 0, d.updt_applctx = reqinfo->updt_applctx,
     d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d.updt_cnt+ 1), d.updt_id = reqinfo
     ->updt_id,
     d.updt_task = reqinfo->updt_task
    WHERE d.info_domain="POWERCHART PRIVMAINT"
     AND d.info_name="dcp_rdm_upd_inactive_priv_exc"
    WITH nocounter
   ;end update
   IF (error(error_msg,1) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update record into DM_INFO table",error_msg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   SET min_range_id = (max_range_id+ 1)
   SET max_range_id = (max_range_id+ range_inc)
 ENDWHILE
 SET readme_data->status = "S"
 SET readme_data->message = "Success: dcp_rdm_upd_inactive_priv_exc performed all required tasks"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
