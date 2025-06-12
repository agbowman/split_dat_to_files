CREATE PROGRAM aps_chg_db_process_order:dba
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
 SET ris_updt_cnt[500] = 0
 SET cur_updt_cnt = 0
 SET failed = "F"
 SET error_cnt = 0
 SET count1 = 0
#start_of_script
 IF ((request->add_cnt > 0))
  INSERT  FROM report_inproc_status ris,
    (dummyt d  WITH seq = value(request->add_cnt))
   SET ris.catalog_cd = request->add_qual[d.seq].catalog_cd, ris.task_assay_cd = request->add_qual[d
    .seq].task_assay_cd, ris.transcribed_status_cd = request->add_qual[d.seq].trans_status_cd,
    ris.processing_sequence = request->add_qual[d.seq].processing_seq, ris.cancelable_ind = request->
    add_qual[d.seq].canceled_ind, ris.updt_dt_tm = cnvtdatetime(curdate,curtime),
    ris.updt_id = reqinfo->updt_id, ris.updt_task = reqinfo->updt_task, ris.updt_cnt = 0,
    ris.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (ris)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","REPORT_INPROC_STATUS")
  ENDIF
 ENDIF
 IF ((request->chg_cnt > 0))
  SELECT INTO "nl:"
   ris.*
   FROM report_inproc_status ris,
    (dummyt d  WITH seq = value(request->chg_cnt))
   PLAN (d)
    JOIN (ris
    WHERE (request->chg_qual[d.seq].catalog_cd=ris.catalog_cd)
     AND (request->chg_qual[d.seq].task_assay_cd=ris.task_assay_cd))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), ris_updt_cnt[count1] = ris.updt_cnt
   WITH forupdate(ris)
  ;end select
  IF (((curqual=0) OR ((count1 != request->chg_cnt))) )
   CALL handle_errors("SELECT","F","TABLE","REPORT_INPROC_STATUS")
   GO TO end_of_script
  ELSE
   UPDATE  FROM report_inproc_status ris,
     (dummyt d  WITH seq = value(request->chg_cnt))
    SET ris.transcribed_status_cd = request->chg_qual[d.seq].trans_status_cd, ris.processing_sequence
      = request->chg_qual[d.seq].processing_seq, ris.cancelable_ind = request->chg_qual[d.seq].
     canceled_ind,
     ris.updt_dt_tm = cnvtdatetime(curdate,curtime), ris.updt_id = reqinfo->updt_id, ris.updt_task =
     reqinfo->updt_task,
     ris.updt_cnt = (request->chg_qual[d.seq].updt_cnt+ 1), ris.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (ris
     WHERE (request->chg_qual[d.seq].catalog_cd=ris.catalog_cd)
      AND (request->chg_qual[d.seq].task_assay_cd=ris.task_assay_cd))
    WITH nocounter
   ;end update
   IF (curqual != value(request->chg_cnt))
    CALL handle_errors("UPDATE","F","TABLE","REPORT_INPROC_STATUS")
    GO TO end_of_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->del_cnt > 0))
  DELETE  FROM report_inproc_status ris,
    (dummyt d  WITH seq = value(request->del_cnt))
   SET ris.seq = 1
   PLAN (d)
    JOIN (ris
    WHERE (request->del_qual[d.seq].catalog_cd=ris.catalog_cd)
     AND (request->del_qual[d.seq].task_assay_cd=ris.task_assay_cd))
   WITH nocounter
  ;end delete
  IF ((curqual != request->del_cnt))
   CALL handle_errors("DELETE","F","TABLE","REPORT_INPROC_STATUS")
   GO TO end_of_script
  ENDIF
 ENDIF
#end_of_script
 IF (error_cnt > 0)
  IF ((error_cnt=((value(request->add_cnt)+ value(request->chg_cnt))+ value(request->del_cnt))))
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
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
