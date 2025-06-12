CREATE PROGRAM aps_chg_followup_event:dba
 RECORD reply(
   1 person_id = f8
   1 term_long_text_id = f8
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
 SET fte_updt_cnt = 0
 SET lt_updt_cnt = 0
 SET reply->person_id = reqinfo->updt_id
 SET noltentry = ""
 SELECT INTO "nl:"
  fte.origin_flag
  FROM ap_ft_event fte
  WHERE (request->followup_event_id=fte.followup_event_id)
  DETAIL
   fte_updt_cnt = fte.updt_cnt
  WITH nocounter, forupdate(fte)
 ;end select
 IF (curqual=0)
  CALL handle_errors("LOCK","F","TABLE","AP_FT_EVENT")
  SET reply->status_data.status = "F"
  SET failed = "T"
 ENDIF
 IF ((request->term_long_text_id=0))
  SELECT INTO "nl:"
   seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    request->term_long_text_id = seq_nbr
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("NEWSEQ","Z","TABLE","REFERENCE_SEQ")
   SET reply->status_data.status = "F"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  INSERT  FROM long_text lt
   SET lt.long_text_id = request->term_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "AP_FT_EVENT", lt
    .parent_entity_id = request->followup_event_id,
    lt.long_text = request->term_comment
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","LONG_TEXT")
   GO TO exit_script
  ENDIF
 ENDIF
#update_afe_table
 UPDATE  FROM ap_ft_event fte
  SET fte.term_id = reqinfo->updt_id, fte.term_dt_tm = cnvtdatetime(curdate,curtime), fte
   .term_reason_cd = request->term_reason_cd,
   fte.term_accession_nbr = request->term_accession_nbr, fte.term_long_text_id = request->
   term_long_text_id, fte.updt_cnt = (fte_updt_cnt+ 1),
   fte.updt_dt_tm = cnvtdatetime(curdate,curtime), fte.updt_id = reqinfo->updt_id, fte.updt_task =
   reqinfo->updt_task,
   fte.updt_applctx = reqinfo->updt_applctx
  WHERE (request->followup_event_id=fte.followup_event_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL handle_errors("UPDATE","Z","TABLE","AP_FT_EVENT")
  SET reply->status_data.status = "F"
  SET failed = "T"
  GO TO exit_script
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
 SET reply->term_long_text_id = request->term_long_text_id
 IF (error_cnt > 0)
  CALL echo("<<<<< FAILURE <<<<<")
  CALL echo(error_cnt)
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
  CALL echo(">>>>> SUCCESS >>>>>")
 ENDIF
END GO
