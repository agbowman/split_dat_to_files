CREATE PROGRAM aps_chg_db_dc_dis_agree:dba
 RECORD internal(
   1 qual[1]
     2 status = i1
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 evaluation_term_id = f8
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt[500] = 0
 SET count1 = 0
 SET nbr_to_change = size(request->qual,5)
 SET nbr_good_changes = nbr_to_change
 SET stat = alter(internal->qual,nbr_to_change)
 SET failed = "F"
 SET error_cnt = 0
 SELECT INTO "nl:"
  adet.*
  FROM ap_dc_evaluation_term adet,
   (dummyt d  WITH seq = value(nbr_to_change))
  PLAN (d)
   JOIN (adet
   WHERE (adet.evaluation_term_id=request->qual[d.seq].evaluation_term_id))
  DETAIL
   cur_updt_cnt[d.seq] = adet.updt_cnt
  WITH nocounter, forupdate(c)
 ;end select
 FOR (x = 1 TO nbr_to_change)
   IF ((cur_updt_cnt[x] != request->qual[x].updt_cnt))
    CALL handle_errors("LOCK","F","TABLE","AP_DC_EVALUATION_TERM")
    IF (error_cnt > 1)
     SET stat = alter(reply->exception_data,error_cnt)
    ENDIF
    SET reply->exception_data[error_cnt].evaluation_term_id = request->qual[x].evaluation_term_id
    SET request->qual[x].evaluation_term_id = 0
    SET nbr_good_changes = (nbr_good_changes - 1)
   ENDIF
 ENDFOR
 UPDATE  FROM ap_dc_evaluation_term adet,
   (dummyt d  WITH seq = value(nbr_to_change))
  SET adet.display = request->qual[d.seq].display, adet.description = request->qual[d.seq].
   description, adet.agreement_cd = request->qual[d.seq].agreement_cd,
   adet.discrepancy_req_ind = request->qual[d.seq].discrepancy_req_ind, adet.reason_req_ind = request
   ->qual[d.seq].reason_req_ind, adet.investigation_req_ind = request->qual[d.seq].
   investigation_req_ind,
   adet.resolution_req_ind = request->qual[d.seq].resolution_req_ind, adet.active_ind = request->
   qual[d.seq].active_ind, adet.updt_dt_tm = cnvtdatetime(curdate,curtime),
   adet.updt_id = reqinfo->updt_id, adet.updt_task = reqinfo->updt_task, adet.updt_applctx = reqinfo
   ->updt_applctx,
   adet.updt_cnt = (request->qual[d.seq].updt_cnt+ 1)
  PLAN (d)
   JOIN (adet
   WHERE (adet.evaluation_term_id=request->qual[d.seq].evaluation_term_id))
  WITH nocounter
 ;end update
 IF (curqual != nbr_good_changes)
  SET failed = "T"
  CALL handle_errors("UPDATE","F","TABLE","AP_DC_EVALUATION_TERM")
 ENDIF
#exit_script
 IF (failed="F")
  IF (nbr_to_change != nbr_good_changes)
   SET reply->status_data.status = "P"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  SET reqinfo->commit_ind = 1
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  ROLLBACK
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
END GO
