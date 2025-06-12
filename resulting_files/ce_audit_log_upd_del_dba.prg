CREATE PROGRAM ce_audit_log_upd_del:dba
 SUBROUTINE checkerrors(operation)
   DECLARE errormsg = c255 WITH noconstant("")
   DECLARE errorcode = i4 WITH noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    SET reply->status_data.subeventstatus[1].operationname = substring(1,25,trim(operation))
    SET reply->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errormsg
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 num_updated = i4
   1 num_deleted = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE request_size = i4 WITH constant(size(request->log_list,5))
 DECLARE operation_status_completed = f8 WITH constant(uar_get_code_by("MEANING",4002019,"COMPLETED")
  )
 IF (operation_status_completed <= 0.0)
  SET operation_status_completed = - (1.0)
 ENDIF
 SET reply->num_deleted = 0
 FOR (i = 1 TO request_size)
  DELETE  FROM ce_audit_log t
   WHERE (request->log_list[i].delete_ind=1)
    AND (t.ce_audit_log_id=request->log_list[i].ce_audit_log_id)
   WITH counter
  ;end delete
  SET reply->num_deleted += curqual
 ENDFOR
 UPDATE  FROM ce_audit_log t,
   (dummyt d  WITH seq = value(request_size))
  SET t.error_msg_txt = request->log_list[d.seq].error_msg_txt, t.operation_status_cd =
   operation_status_completed, t.updt_dt_tm = cnvtdatetime(sysdate),
   t.updt_task = reqinfo->updt_task, t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->
   updt_applctx,
   t.updt_cnt = (t.updt_cnt+ 1)
  PLAN (d)
   JOIN (t
   WHERE (request->log_list[d.seq].delete_ind=0)
    AND (t.ce_audit_log_id=request->log_list[d.seq].ce_audit_log_id))
  WITH rdbarrayinsert = 100, counter
 ;end update
 SET reply->num_updated = curqual
 CALL checkerrors("CE_AUDIT_LOG update/delete")
 IF (((reply->num_updated+ reply->num_deleted)=request_size))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "P"
 ENDIF
#exit_program
 COMMIT
END GO
