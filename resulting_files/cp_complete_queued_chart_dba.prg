CREATE PROGRAM cp_complete_queued_chart:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE handleerror(status=c1,operationname=vc,targetvalue=vc) = null
 DECLARE spooling_cd = f8
 DECLARE spooled_cd = f8
 DECLARE print_error_cd = f8
 DECLARE file_error_cd = f8
 DECLARE unknown_error_cd = f8
 DECLARE queue_status_cd = f8
 DECLARE was_locked = i2
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 SET stat = uar_get_meaning_by_codeset(28800,"SPOOLING",1,spooling_cd)
 SET stat = uar_get_meaning_by_codeset(28800,"SPOOLED",1,spooled_cd)
 SET stat = uar_get_meaning_by_codeset(28800,"PRINTERROR",1,print_error_cd)
 SET stat = uar_get_meaning_by_codeset(28800,"INVFILEERROR",1,file_error_cd)
 SET stat = uar_get_meaning_by_codeset(28800,"UNKNOWNERROR",1,unknown_error_cd)
 IF ((request->printer_valid_ind=0))
  SET queue_status_cd = print_error_cd
 ELSEIF ((request->file_valid_ind=0))
  SET queue_status_cd = file_error_cd
 ELSEIF ((request->spool_success_ind=0))
  SET queue_status_cd = unknown_error_cd
 ELSE
  SET queue_status_cd = spooled_cd
 ENDIF
 SELECT INTO "nl:"
  FROM chart_print_queue cpq
  WHERE (cpq.chart_queue_id=request->chart_queue_id)
  DETAIL
   IF (cpq.queue_status_cd=spooling_cd)
    was_locked = 1
   ENDIF
  WITH nocounter, forupdate(cpq)
 ;end select
 IF (curqual > 0)
  IF (was_locked=1)
   UPDATE  FROM chart_print_queue cpq
    SET cpq.queue_status_cd = queue_status_cd, cpq.updt_cnt = (cpq.updt_cnt+ 1), cpq.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     cpq.updt_id = reqinfo->updt_id, cpq.updt_task = reqinfo->updt_task, cpq.updt_applctx = reqinfo->
     updt_applctx
    WHERE (cpq.chart_queue_id=request->chart_queue_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handleerror("F","Update statement","Queued print request not updated")
   ENDIF
  ELSE
   CALL handleerror("Z","Select statement","Queued chart wasn't locked")
  ENDIF
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL handleerror("Z","Select statement","Queued chart doesn't exist")
 ENDIF
 SUBROUTINE handleerror(status,operationname,targetvalue)
   SET reqinfo->commit_ind = 0
   SET errorcode = error(errmsg,0)
   IF (errorcode != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.operationname = operationname
    SET reply->status_data.operationstatus = "F"
    SET reply->status_data.targetobjectname = "Error Message"
    SET reply->status_data.targetobjectvalue = errmsg
   ELSE
    SET reply->status_data.status = status
    SET reply->status_data.operationname = operationname
    SET reply->status_data.operationstatus = "S"
    SET reply->status_data.targetobjectvalue = targetvalue
   ENDIF
   GO TO exit_script
 END ;Subroutine
#exit_script
 CALL echorecord(reply)
END GO
