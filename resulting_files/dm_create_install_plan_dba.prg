CREATE PROGRAM dm_create_install_plan:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dipcnt = i4
 DECLARE dcip_err_ind = i2
 DECLARE dcip_errcode = i4
 DECLARE dcip_errmsg = c132
 DECLARE dcip_operation = c25
 DECLARE dcip_objname = c25
 DECLARE dcip_custmsg = c100
 DECLARE dcip_batch_number = i4
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET dipcnt = 0
 SET dcip_err_ind = 0
 SET dcip_errcode = 0
 SET dcip_errmsg = fillstring(132," ")
 SET dcip_operation = fillstring(25," ")
 SET dcip_objname = fillstring(25," ")
 SET dcip_custmsg = fillstring(100," ")
 SET dcip_batch_number = (request->install_plan_id * - (1))
 IF ((request->install_plan_id <= 0))
  SET dcip_err_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "ERROR CHECK"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INSTALL_PLAN_ID"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failed because INSTALL_PLAN_ID is invalid."
  GO TO exit_program
 ENDIF
 IF (size(request->qual,5) < 1)
  SET dcip_err_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "ERROR CHECK"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REQUEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failed because there were too few Packages in the Install Plan."
  GO TO exit_program
 ENDIF
 SET dcip_errcode = error(dcip_errmsg,1)
 SELECT INTO "nl:"
  dip.package_number
  FROM dm_install_plan dip
  WHERE (dip.install_plan_id=request->install_plan_id)
  WITH nocounter, maxqual(dip,1)
 ;end select
 SET dcip_operation = "SELECT"
 SET dcip_objname = "DM_INSTALL_PLAN"
 SET dcip_custmsg = concat("Failed selecting from table <",dcip_objname,">. ")
 IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
  GO TO exit_program
 ENDIF
 IF (curqual)
  DELETE  FROM dm_afd_cons_columns dacc
   WHERE dacc.alpha_feature_nbr=dcip_batch_number
    AND dacc.owner=currdbuser
   WITH nocounter
  ;end delete
  SET dcip_operation = "DELETE"
  SET dcip_objname = "DM_AFD_CONS_COLUMNS"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_constraints dac
   WHERE dac.alpha_feature_nbr=dcip_batch_number
    AND dac.owner=currdbuser
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_CONSTRAINTS"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_index_columns daic
   WHERE daic.alpha_feature_nbr=dcip_batch_number
    AND daic.owner=currdbuser
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_INDEX_COLUMNS"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_indexes dai
   WHERE dai.alpha_feature_nbr=dcip_batch_number
    AND dai.owner=currdbuser
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_INDEXES"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_columns dac
   WHERE dac.alpha_feature_nbr=dcip_batch_number
    AND dac.owner=currdbuser
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_COLUMNS"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_part_objects dapo
   WHERE dapo.alpha_feature_nbr=dcip_batch_number
    AND dapo.owner=currdbuser
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_PART_OBJECTS"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_part_subpart_objects dapso
   WHERE dapso.alpha_feature_nbr=dcip_batch_number
    AND dapso.owner=currdbuser
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_PART_SUBPART_OBJECTS"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_part_subpart_tspaces dapst
   WHERE dapst.alpha_feature_nbr=dcip_batch_number
    AND dapst.owner=currdbuser
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_PART_SUBPART_TSPACES"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_part_subpart_keycols dapskc
   WHERE dapskc.alpha_feature_nbr=dcip_batch_number
    AND dapskc.owner=currdbuser
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_PART_SUBPART_KEYCOLS"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_tables dat
   WHERE dat.alpha_feature_nbr=dcip_batch_number
    AND dat.owner=currdbuser
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_TABLES"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_common_data_foundation cdf
   WHERE cdf.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DMAFDCOMMONDATAFOUNDATION"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_code_value_group cvg
   WHERE cvg.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_CODE_VALUE_GROUP"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_code_value_extension cve
   WHERE cve.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DMAFDCODEVALUEEXTENSION"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_code_value_alias cva
   WHERE cva.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_CODE_VALUE_ALIAS"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_code_value cv
   WHERE cv.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_CODE_VALUE"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_code_set_extension cse
   WHERE cse.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_CODE_SET_EXTENSION"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_afd_code_value_set cvs
   WHERE cvs.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_AFD_CODE_VALUE_SET"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_ocd_task_req_r trr
   WHERE trr.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_OCD_TASK_REQ_R"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_ocd_app_task_r atr
   WHERE atr.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_OCD_APP_TASK_R"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_ocd_request req
   WHERE req.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_OCD_REQUEST"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_ocd_task tsk
   WHERE tsk.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_OCD_TASK"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_ocd_application app
   WHERE app.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_OCD_APPLICATION"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_ocd_readme dor
   WHERE dor.ocd=dcip_batch_number
    AND  EXISTS (
   (SELECT
    "x"
    FROM dm_readme dr
    WHERE dr.readme_id=dor.readme_id
     AND dr.owner=currdbuser))
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_OCD_README"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_alpha_features daf
   WHERE daf.alpha_feature_nbr=dcip_batch_number
    AND daf.owner=currdbuser
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_ALPHA_FEATURES"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_alpha_features_env dafe
   WHERE dafe.alpha_feature_nbr=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_ALPHA_FEATURES_ENV"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_ocd_log dol
   WHERE dol.ocd=dcip_batch_number
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_OCD_LOG"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
  DELETE  FROM dm_install_plan dip
   WHERE (dip.install_plan_id=request->install_plan_id)
   WITH nocounter
  ;end delete
  SET dcip_objname = "DM_INSTALL_PLAN"
  SET dcip_custmsg = concat("Failed deleting from table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   ROLLBACK
   GO TO exit_program
  ELSE
   COMMIT
  ENDIF
 ENDIF
 INSERT  FROM dm_install_plan dip,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET dip.install_plan_id = request->install_plan_id, dip.package_number = request->qual[d.seq].
   package_number
  PLAN (d)
   JOIN (dip)
  WITH nocounter
 ;end insert
 SET dcip_operation = "INSERT"
 SET dcip_objname = "DM_INSTALL_PLAN"
 SET dcip_custmsg = concat("Failed inserting into table <",dcip_objname,">. ")
 IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
  ROLLBACK
  GO TO exit_program
 ELSE
  COMMIT
 ENDIF
 IF (curqual != size(request->qual,5))
  SET dcip_err_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "ERROR CHECK"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DM_INSTALL_PLAN"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Failed to create the new install plan."
 ENDIF
 SELECT INTO "nl:"
  FROM dm_ocd_log dol
  WHERE dol.environment_id=0
   AND dol.project_type="INSTALL PLAN"
   AND dol.project_name="TYPE"
   AND (dol.ocd=(request->install_plan_id * - (1)))
  WITH nocounter
 ;end select
 SET dcip_operation = "SELECT"
 SET dcip_objname = "DM_OCD_LOG"
 SET dcip_custmsg = concat("Failed selecting from table <",dcip_objname,">. ")
 IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  INSERT  FROM dm_ocd_log dol
   SET dol.environment_id = 0, dol.project_type = "INSTALL PLAN", dol.project_name = "TYPE",
    dol.ocd = (request->install_plan_id * - (1)), dol.batch_dt_tm = cnvtdatetime(curdate,curtime3),
    dol.status = "MANAGED-DT",
    dol.updt_dt_tm = cnvtdatetime(curdate,curtime3), dol.active_ind = 1
   WITH nocounter
  ;end insert
  SET dcip_operation = "INSERT"
  SET dcip_objname = "DM_OCD_LOG"
  SET dcip_custmsg = concat("Failed inserting to table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   GO TO exit_program
  ENDIF
 ELSE
  UPDATE  FROM dm_ocd_log dol
   SET dol.status = "MANAGED-DT", dol.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE dol.environment_id=0
    AND dol.project_type="INSTALL PLAN"
    AND dol.project_name="TYPE"
    AND (dol.ocd=(request->install_plan_id * - (1)))
   WITH nocounter
  ;end update
  SET dcip_operation = "UPDATE"
  SET dcip_objname = "DM_OCD_LOG"
  SET dcip_custmsg = concat("Failed updating table <",dcip_objname,">. ")
  IF (dcip_check_error(dcip_operation,dcip_objname,dcip_custmsg,0))
   GO TO exit_program
  ENDIF
 ENDIF
 SUBROUTINE dcip_check_error(dce_op,dce_objname,dce_objval,dce_reset_ind)
   IF (dce_reset_ind=1)
    SET dcip_errcode = error(dcip_errmsg,1)
   ELSE
    SET dcip_errcode = error(dcip_errmsg,0)
   ENDIF
   IF (dcip_errcode != 0)
    SET reply->status_data.subeventstatus[1].operationname = dce_op
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = dce_objname
    SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(dce_objval,dcip_errmsg)
    SET dcip_err_ind = 1
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
#exit_program
 IF (dcip_err_ind=0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DM_INSTALL_PLAN"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Succeeded creating new install plan."
  SET reqinfo->commit_ind = 1
 ENDIF
 IF (curenv=0)
  CALL echorecord(reply)
  CALL echorecord(reqinfo)
 ENDIF
END GO
