CREATE PROGRAM aps_chg_unlock_case_report:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET error_cnt = 0
 SELECT INTO "nl:"
  rt.*
  FROM report_task rt
  WHERE (request->report_id=rt.report_id)
  WITH forupdate(rt)
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","F","TABLE","REPORT_TASK")
  GO TO exit_script
 ENDIF
 UPDATE  FROM report_task rt
  SET rt.editing_prsnl_id = 0, rt.updt_dt_tm = cnvtdatetime(curdate,curtime), rt.updt_id = reqinfo->
   updt_id,
   rt.updt_task = reqinfo->updt_task, rt.updt_applctx = reqinfo->updt_applctx, rt.updt_cnt = (rt
   .updt_cnt+ 1)
  WHERE (request->report_id=rt.report_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL handle_errors("UDPATE","F","TABLE","REPORT_TASK")
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
 GO TO end_of_program
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#end_of_program
END GO
