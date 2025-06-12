CREATE PROGRAM aps_chg_worklist_nbr_to_null:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
     2 fail_where = c6
 )
 RECORD temp_lock(
   1 qual[5]
     2 updt_cnt = i4
     2 processing_task_id = f8
 )
#script
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET cntr = 0
 SET error_cnt = 0
 SELECT INTO "nl:"
  pt.*
  FROM processing_task pt
  WHERE (request->chg_nbr_from=pt.worklist_nbr)
  DETAIL
   cntr = (cntr+ 1)
   IF (mod(cntr,5)=1
    AND cntr != 1)
    stat = alter(temp_lock->qual,(cntr+ 5))
   ENDIF
   temp_lock->qual[cntr].updt_cnt = pt.updt_cnt, temp_lock->qual[cntr].processing_task_id = pt
   .processing_task_id
  WITH forupdate(pt)
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","PROCESSING_TASK")
  SET reply->status_data.fail_where = "SELECT"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 UPDATE  FROM processing_task pt,
   (dummyt d  WITH seq = value(cntr))
  SET pt.worklist_nbr = 0, pt.updt_dt_tm = cnvtdatetime(curdate,curtime), pt.updt_id = reqinfo->
   updt_id,
   pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (
   temp_lock->qual[d.seq].updt_cnt+ 1)
  PLAN (d)
   JOIN (pt
   WHERE (temp_lock->qual[d.seq].processing_task_id=pt.processing_task_id)
    AND (request->chg_nbr_from=pt.worklist_nbr))
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL handle_errors("UPDATE","Z","TABLE","PROCESSING_TASK")
  SET reply->status_data.fail_where = "UPDATE"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_cnt > 0)
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
