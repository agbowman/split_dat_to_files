CREATE PROGRAM aps_chg_ft_term_candidates:dba
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
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 DELETE  FROM ft_term_candidate_list ftcl,
   (dummyt d  WITH seq = value(request->remove_qual_cnt))
  SET ftcl.seq = 1
  PLAN (d)
   JOIN (ftcl
   WHERE (request->remove_qual[d.seq].followup_event_id=ftcl.followup_event_id)
    AND (request->remove_qual[d.seq].review_case_id=ftcl.review_case_id))
  WITH nocounter
 ;end delete
 IF ((curqual != request->remove_qual_cnt))
  CALL handle_errors("DELETE","Z","TABLE","FT_TERM_CANDIDATE_LIST")
  GO TO exit_script
 ENDIF
 IF ((request->update_qual_cnt > 0))
  UPDATE  FROM ap_ft_event afe,
    (dummyt d  WITH seq = value(request->update_qual_cnt))
   SET afe.term_id = reqinfo->updt_id, afe.term_dt_tm = cnvtdatetime(curdate,curtime), afe
    .term_reason_cd = request->update_qual[d.seq].reason_cd,
    afe.term_accession_nbr = request->update_qual[d.seq].review_case, afe.updt_cnt = (afe.updt_cnt+ 1
    ), afe.updt_dt_tm = cnvtdatetime(curdate,curtime),
    afe.updt_id = reqinfo->updt_id, afe.updt_task = reqinfo->updt_task, afe.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (afe
    WHERE (request->update_qual[d.seq].followup_event_id=afe.followup_event_id))
   WITH nocounter
  ;end update
  IF ((curqual != request->update_qual_cnt))
   CALL handle_errors("UPDATE","Z","TABLE","AP_FT_EVENT")
   GO TO exit_script
  ENDIF
 ENDIF
 GO TO exit_script
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
  CALL echo("<<<<< ROLLBACK <<<<<")
  CALL echo(error_cnt)
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo(">>>>> COMMIT >>>>>")
 ENDIF
END GO
