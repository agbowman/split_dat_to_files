CREATE PROGRAM bed_ens_rel_assay_sr_rad:dba
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
 FOR (x = 1 TO rec_cnt)
   IF ((request->rel_list[x].action_flag=1))
    INSERT  FROM assay_processing_r apr
     SET apr.service_resource_cd = request->rel_list[x].sr_code_value, apr.task_assay_cd = request->
      rel_list[x].dta_code_value, apr.active_ind = 1,
      apr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apr.updt_id = reqinfo->updt_id, apr.updt_task
       = reqinfo->updt_task,
      apr.updt_cnt = 1, apr.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert service resource ",cnvtstring(request->rel_list[x].
       sr_code_value)," assay ",cnvtstring(request->rel_list[x].dta_code_value),
      " on the assay_processing_r table.")
     GO TO exit_script
    ENDIF
    INSERT  FROM assay_resource_translation art
     SET art.service_resource_cd = request->rel_list[x].sr_code_value, art.task_assay_cd = request->
      rel_list[x].dta_code_value, art.active_ind = 1,
      art.updt_dt_tm = cnvtdatetime(curdate,curtime3), art.updt_id = reqinfo->updt_id, art.updt_task
       = reqinfo->updt_task,
      art.updt_cnt = 1, art.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",cnvtstring(request->rel_list[x].sr_code_value),
      " assay ",cnvtstring(request->rel_list[x].dta_code_value),
      " on the assay_resource_translation table.")
     GO TO exit_script
    ENDIF
    INSERT  FROM assay_resource_list arl
     SET arl.service_resource_cd = request->rel_list[x].sr_code_value, arl.task_assay_cd = request->
      rel_list[x].dta_code_value, arl.active_ind = 1,
      arl.primary_ind = request->rel_list[x].default_ind, arl.sequence = request->rel_list[x].
      sequence, arl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      arl.updt_id = reqinfo->updt_id, arl.updt_task = reqinfo->updt_task, arl.updt_cnt = 1,
      arl.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",cnvtstring(request->rel_list[x].sr_code_value),
      " assay ",cnvtstring(request->rel_list[x].dta_code_value)," on the assay_resource_list table.")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->rel_list[x].action_flag=2))
    UPDATE  FROM assay_resource_list arl
     SET arl.primary_ind = request->rel_list[x].default_ind, arl.sequence = request->rel_list[x].
      sequence, arl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      arl.updt_id = reqinfo->updt_id, arl.updt_task = reqinfo->updt_task, arl.updt_cnt = (arl
      .updt_cnt+ 1),
      arl.updt_applctx = reqinfo->updt_applctx
     WHERE (arl.service_resource_cd=request->rel_list[x].sr_code_value)
      AND arl.active_ind=1
      AND (arl.task_assay_cd=request->rel_list[x].dta_code_value)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update ",cnvtstring(request->rel_list[x].sr_code_value),
      " assay ",cnvtstring(request->rel_list[x].dta_code_value),
      " on the assay_processing_list table.")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->rel_list[x].action_flag=3))
    DELETE  FROM assay_processing_r apr
     WHERE (apr.service_resource_cd=request->rel_list[x].sr_code_value)
      AND apr.active_ind=1
      AND (apr.task_assay_cd=request->rel_list[x].dta_code_value)
     WITH nocounter
    ;end delete
    DELETE  FROM assay_resource_translation art
     WHERE (art.service_resource_cd=request->rel_list[x].sr_code_value)
      AND art.active_ind=1
      AND (art.task_assay_cd=request->rel_list[x].dta_code_value)
     WITH nocounter
    ;end delete
    DELETE  FROM assay_resource_list arl
     WHERE (arl.service_resource_cd=request->rel_list[x].sr_code_value)
      AND arl.active_ind=1
      AND (arl.task_assay_cd=request->rel_list[x].dta_code_value)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REL_ASSAY_SR_RAD","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
