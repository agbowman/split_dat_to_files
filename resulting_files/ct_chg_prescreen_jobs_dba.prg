CREATE PROGRAM ct_chg_prescreen_jobs:dba
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE update_error = i2 WITH private, constant(1)
 DECLARE lock_error = i2 WITH private, constant(2)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE job_status_mean = vc WITH protect
 DECLARE job_cnt = i2 WITH protect, noconstant(0)
 DECLARE forcedcomp = vc WITH protect, constant("FORCEDCOMP")
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET job_status_mean = uar_get_code_meaning(request->job_status_cd)
 SET job_cnt = size(request->job_list,5)
 IF (job_cnt > 0)
  SELECT INTO "nl:"
   cp.*
   FROM ct_prescreen_job cp,
    (dummyt d  WITH seq = value(job_cnt))
   PLAN (d)
    JOIN (cp
    WHERE (cp.ct_prescreen_job_id=request->job_list[d.seq].job_id))
   WITH nocounter, forupdate(cp)
  ;end select
  IF (curqual=0)
   SET fail_flag = lock_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error locking the ct_prescreen_job table."
   GO TO check_error
  ENDIF
  UPDATE  FROM ct_prescreen_job cp,
    (dummyt d  WITH seq = value(job_cnt))
   SET cp.job_status_cd = request->job_status_cd, cp.updt_cnt = (cp.updt_cnt+ 1), cp.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    cp.updt_id = reqinfo->updt_id, cp.updt_applctx = reqinfo->updt_applctx, cp.updt_task = reqinfo->
    updt_task
   PLAN (d)
    JOIN (cp
    WHERE (cp.ct_prescreen_job_id=request->job_list[d.seq].job_id))
   WITH nocounter
  ;end update
  CALL echo(build("Curqual for update1 is: ",curqual))
  IF (curqual=0)
   SET fail_flag = update_error
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Updating jobs in ct_prescreen_job table."
   GO TO check_error
  ENDIF
  IF (job_status_mean=forcedcomp)
   SELECT INTO "nl:"
    cpi.*
    FROM ct_prot_prescreen_job_info cpi,
     (dummyt d  WITH seq = value(job_cnt))
    PLAN (d)
     JOIN (cpi
     WHERE (cpi.ct_prescreen_job_id=request->job_list[d.seq].job_id))
    WITH nocounter, forupdate(cpi)
   ;end select
   IF (curqual=0)
    SET fail_flag = lock_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Error locking the ct_prot_prescreen_job_info table."
    GO TO check_error
   ENDIF
   UPDATE  FROM ct_prot_prescreen_job_info cpi,
     (dummyt d  WITH seq = value(job_cnt))
    SET cpi.completed_flag = 2, cpi.updt_cnt = (cpi.updt_cnt+ 1), cpi.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     cpi.updt_id = reqinfo->updt_id, cpi.updt_applctx = reqinfo->updt_applctx, cpi.updt_task =
     reqinfo->updt_task
    PLAN (d)
     JOIN (cpi
     WHERE (cpi.ct_prescreen_job_id=request->job_list[d.seq].job_id))
    WITH nocounter
   ;end update
   CALL echo(build("Curqual for update1 is: ",curqual))
   IF (curqual=0)
    SET fail_flag = update_error
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Updating jobs in ct_prot_prescreen_job_info table."
    GO TO check_error
   ENDIF
  ENDIF
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 SET last_mod = "000"
 SET mod_date = "April 15, 2010"
END GO
