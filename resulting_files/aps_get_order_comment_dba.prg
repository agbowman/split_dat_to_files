CREATE PROGRAM aps_get_order_comment:dba
 RECORD reply(
   1 comment = vc
   1 updt_cnt = i4
   1 long_text_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET error_cnt = 0
 SELECT INTO "nl:"
  lt.long_text_id
  FROM report_task rt,
   long_text lt
  PLAN (rt
   WHERE (request->report_id=rt.report_id)
    AND rt.comments_long_text_id > 0)
   JOIN (lt
   WHERE rt.comments_long_text_id=lt.long_text_id
    AND lt.parent_entity_name="REPORT_TASK")
  DETAIL
   reply->comment = lt.long_text, reply->updt_cnt = lt.updt_cnt, reply->long_text_id = lt
   .long_text_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","REPORT_TASK")
  GO TO exit_script
 ENDIF
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
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
