CREATE PROGRAM bed_ens_rel_assay_sr:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET rec_cnt = size(request->rel_list,5)
 SET active_code_value = 0.0
 SET inactive_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the ACTIVE code value from codeset 48.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="INACTIVE"
   AND cv.active_ind=1
  DETAIL
   inactive_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "Y"
  SET error_msg = concat("Unable to retrieve the INACTIVE code value from codeset 48.")
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO rec_cnt)
   IF ((request->rel_list[x].action_flag=1))
    UPDATE  FROM assay_processing_r apr
     SET apr.display_sequence = request->rel_list[x].sequence, apr.default_result_type_cd = request->
      rel_list[x].result_type_code_value, apr.active_ind = 1,
      apr.active_status_cd = active_code_value, apr.active_status_prsnl_id = reqinfo->updt_id, apr
      .active_status_dt_tm = cnvtdatetime(curdate,curtime),
      apr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apr.updt_id = reqinfo->updt_id, apr.updt_task
       = reqinfo->updt_task,
      apr.updt_cnt = (apr.updt_cnt+ 1), apr.updt_applctx = reqinfo->updt_applctx
     WHERE (apr.service_resource_cd=request->rel_list[x].sr_code_value)
      AND (apr.task_assay_cd=request->rel_list[x].dta_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     INSERT  FROM assay_processing_r apr
      SET apr.service_resource_cd = request->rel_list[x].sr_code_value, apr.default_result_type_cd =
       request->rel_list[x].result_type_code_value, apr.dnld_assay_alias = null,
       apr.downld_ind = 0, apr.active_ind = 1, apr.task_assay_cd = request->rel_list[x].
       dta_code_value,
       apr.display_sequence = request->rel_list[x].sequence, apr.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), apr.updt_id = reqinfo->updt_id,
       apr.updt_task = reqinfo->updt_task, apr.updt_cnt = 1, apr.updt_applctx = reqinfo->updt_applctx,
       apr.active_status_cd = active_code_value, apr.active_status_prsnl_id = reqinfo->updt_id, apr
       .active_status_dt_tm = cnvtdatetime(curdate,curtime)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert/update service resource ",cnvtstring(request->
        rel_list[x].sr_code_value)," assay ",cnvtstring(request->rel_list[x].dta_code_value),
       " on the assay_processing_r table.")
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((request->rel_list[x].action_flag=2))
    UPDATE  FROM assay_processing_r apr
     SET apr.display_sequence = request->rel_list[x].sequence, apr.default_result_type_cd = request->
      rel_list[x].result_type_code_value, apr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      apr.updt_id = reqinfo->updt_id, apr.updt_task = reqinfo->updt_task, apr.updt_cnt = (apr
      .updt_cnt+ 1),
      apr.updt_applctx = reqinfo->updt_applctx
     WHERE (apr.service_resource_cd=request->rel_list[x].sr_code_value)
      AND apr.active_ind=1
      AND (apr.task_assay_cd=request->rel_list[x].dta_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update ",cnvtstring(request->rel_list[x].sr_code_value),
      " assay ",cnvtstring(request->rel_list[x].dta_code_value)," on the assay_processing_r table.")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->rel_list[x].action_flag=3))
    UPDATE  FROM assay_proccessing_r apr
     SET apr.active_ind = 0, apr.active_status_cd = inactive_code_value, apr.active_status_prsnl_id
       = reqinfo->updt_id,
      apr.active_status_dt_tm = cnvtdatetime(curdate,curtime)
     WHERE (apr.service_resource_cd=request->rel_list[x].sr_code_value)
      AND apr.active_ind=1
      AND (apr.task_assay_cd=request->rel_list[x].dta_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to delete ",cnvtstring(request->rel_list[x].sr_code_value),
      " assay ",cnvtstring(request->rel_list[x].dta_code_value)," on the assay_processing_r table.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REL_ASSAY_SR","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
