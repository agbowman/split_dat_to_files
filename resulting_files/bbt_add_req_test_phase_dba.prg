CREATE PROGRAM bbt_add_req_test_phase:dba
 RECORD reply(
   1 phase_group_cd = f8
   1 phase_group_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET nbr_to_add = size(request->qual,5)
 SET y = 0
 SET idx = 0
 SET failed = "F"
 SET phase_group_cd = 0.0
 SET next_code = 0.0
 EXECUTE cpm_next_code
 SET phase_group_cd = next_code
 SET auth_data_status_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=8
   AND cv.cdf_meaning="AUTH"
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   auth_data_status_cd = cv.code_value
  WITH nocounter
 ;end select
 INSERT  FROM code_value c
  SET c.code_value = next_code, c.code_set = 1601, c.cdf_meaning = request->cdf_meaning,
   c.display = request->display, c.display_key = trim(cnvtupper(request->display)), c.description =
   request->description,
   c.active_ind = request->active_ind, c.definition = request->description, c.collation_seq = 0,
   c.active_type_cd = 0.0, c.active_dt_tm =
   IF ((request->active_ind=1)) cnvtdatetime(curdate,curtime3)
   ELSE null
   ENDIF
   , c.inactive_dt_tm =
   IF ((request->active_ind=0)) cnvtdatetime(curdate,curtime3)
   ELSE null
   ENDIF
   ,
   c.begin_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.end_effective_dt_tm = cnvtdatetime(
    "31-DEC-2100:00:00:00.00"), c.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   c.updt_id = reqinfo->updt_id, c.updt_cnt = 0, c.updt_task = reqinfo->updt_task,
   c.updt_applctx = reqinfo->updt_applctx, c.data_status_cd = auth_data_status_cd, c
   .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
   c.data_status_prsnl_id = reqinfo->updt_id, c.active_status_prsnl_id = reqinfo->updt_id
  WITH counter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
 ENDIF
 IF (failed="T")
  SET reply->status_data.status = "Z"
  SET reply->status_data.operationname = "add"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "code_value"
  SET reply->status_data.targetobjectvalue = "phase not added to 1601"
  ROLLBACK
  GO TO end_script
 ENDIF
 FOR (idx = 1 TO nbr_to_add)
   SET next_code = 0.0
   EXECUTE cpm_next_code
   INSERT  FROM phase_group p
    SET p.phase_group_id = next_code, p.phase_group_cd = phase_group_cd, p.task_assay_cd = request->
     qual[idx].task_assay_cd,
     p.sequence = request->qual[idx].sequence, p.required_ind = request->qual[idx].required_ind, p
     .active_ind = 1,
     p.active_status_cd = 0, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
     .active_status_prsnl_id = reqinfo->updt_id,
     p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "phase_group"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = string(request->qual[idx].
     task_assay_cd)
    SET failed = "T"
    GO TO row_failed
   ENDIF
 ENDFOR
#row_failed
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.operationname = "add"
  SET reply->status_data.operationstatus = "F"
  SET reply->status_data.targetobjectname = "phase_group"
  SET reply->status_data.targetobjectvalue = "phase not added"
  SET reqinfo->commit_ind = 0
  GO TO end_script
 ELSE
  SET reply->phase_group_cd = phase_group_cd
  SET reply->phase_group_disp = request->display
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
#end_script
 CALL echo(build("phase_group_cd: ",reply->phase_group_cd))
END GO
