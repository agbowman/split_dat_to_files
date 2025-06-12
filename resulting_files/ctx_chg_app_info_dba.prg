CREATE PROGRAM ctx_chg_app_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cur_updt_cnt = 0
 SELECT INTO "nl:"
  a.*
  FROM application a
  WHERE (request->application_number=a.application_number)
  DETAIL
   cur_updt_cnt = a.updt_cnt
  WITH nocounter, forupdate(a)
 ;end select
 IF (((curqual=0) OR ((cur_updt_cnt != request->updt_cnt))) )
  GO TO lock_failed
 ENDIF
 UPDATE  FROM application a
  SET a.active_ind = request->active_ind, a.log_access_ind = request->log_access_ind, a.log_level =
   request->log_level,
   a.active_dt_tm =
   IF ((request->active_dt_tm > 0)) cnvtdatetime(request->active_dt_tm)
   ELSE a.active_dt_tm
   ENDIF
   , a.inactive_dt_tm =
   IF ((request->inactive_dt_tm > 0)) cnvtdatetime(request->inactive_dt_tm)
   ELSE a.inactive_dt_tm
   ENDIF
   , a.updt_dt_tm = cnvtdatetime(sysdate),
   a.updt_task = reqinfo->updt_task, a.updt_cnt = (a.updt_cnt+ 1), a.updt_id = reqinfo->updt_id,
   a.updt_applctx = reqinfo->updt_applctx
  WHERE (a.application_number=request->application_number)
  WITH nocounter
 ;end update
 IF (curqual=0)
  GO TO update_failed
 ENDIF
 GO TO exit_script
#lock_failed
 SET reply->status_data.subeventstatus[1].operationname = "forupdat"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "table"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "application"
 SET failed = "T"
 GO TO exit_script
#update_failed
 SET reply->status_data.subeventstatus[1].operationname = "update"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "table"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "application"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="T")
  ROLLBACK
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
