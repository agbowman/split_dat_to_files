CREATE PROGRAM aps_chk_updts_on_rpt:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_cnt = i2 WITH protect, noconstant(0)
 IF ((request->report_id > 0))
  SELECT INTO "nl:"
   cr.updt_cnt
   FROM case_report cr
   WHERE (cr.report_id=request->report_id)
    AND (cr.updt_cnt=request->cr_updt_cnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("UPDT_CNT","F","TABLE","CASE_REPORT")
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
