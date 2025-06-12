CREATE PROGRAM aps_get_dc_event:dba
 RECORD reply(
   1 event_id = f8
   1 init_eval_term_id = f8
   1 init_discrep_term_id = f8
   1 disagree_reason_cd = f8
   1 investigation_cd = f8
   1 resolution_cd = f8
   1 final_eval_term_id = f8
   1 final_discrep_term_id = f8
   1 long_text_id = f8
   1 long_text_text = vc
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
 SELECT
  IF ((request->prsnl_group_id > 0))INTO "nl:"
   ade.event_id, ade.init_eval_term_id, ade.init_discrep_term_id,
   ade.disagree_reason_cd, ade.investigation_cd, ade.resolution_cd,
   ade.final_eval_term_id, ade.final_discrep_term_id, ade.long_text_id
   FROM ap_dc_event ade
   PLAN (ade
    WHERE (request->study_id=ade.study_id)
     AND (request->case_id=ade.case_id)
     AND (request->correlate_case_id=ade.correlate_case_id)
     AND (request->prsnl_group_id=ade.prsnl_group_id)
     AND 0=ade.cancel_prsnl_id)
  ELSE INTO "nl:"
   ade.event_id, ade.init_eval_term_id, ade.init_discrep_term_id,
   ade.disagree_reason_cd, ade.investigation_cd, ade.resolution_cd,
   ade.final_eval_term_id, ade.final_discrep_term_id, ade.long_text_id
   FROM ap_dc_event ade,
    ap_dc_event_prsnl adep
   PLAN (ade
    WHERE (request->study_id=ade.study_id)
     AND (request->case_id=ade.case_id)
     AND (request->correlate_case_id=ade.correlate_case_id)
     AND 0=ade.cancel_prsnl_id)
    JOIN (adep
    WHERE ade.event_id=adep.event_id
     AND (request->prsnl_id=adep.prsnl_id))
  ENDIF
  DETAIL
   reply->event_id = ade.event_id, reply->init_eval_term_id = ade.init_eval_term_id, reply->
   init_discrep_term_id = ade.init_discrep_term_id,
   reply->disagree_reason_cd = ade.disagree_reason_cd, reply->investigation_cd = ade.investigation_cd,
   reply->resolution_cd = ade.resolution_cd,
   reply->final_eval_term_id = ade.final_eval_term_id, reply->final_discrep_term_id = ade
   .final_discrep_term_id, reply->long_text_id = ade.long_text_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  CALL handle_errors("SELECT","Z","TABLE","AP_DC_EVENT")
  GO TO exit_script
 ENDIF
 IF ((reply->long_text_id > 0))
  SELECT INTO "NL:"
   lt.long_text_id
   FROM long_text lt
   WHERE (reply->long_text_id=lt.long_text_id)
   DETAIL
    reply->long_text_text = lt.long_text
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   CALL handle_errors("SELECT","F","TABLE","LONG_TEXT")
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
  CALL echo("<<<<< F <<<<<")
  CALL echo(build("errors->",error_cnt))
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(">>>>> S >>>>>")
 ENDIF
 CALL echo("reply->event_id             ",0)
 CALL echo(reply->event_id)
 CALL echo("reply->init_eval_term_id    ",0)
 CALL echo(reply->init_eval_term_id)
 CALL echo("reply->init_discrep_term_id ",0)
 CALL echo(reply->init_discrep_term_id)
 CALL echo("reply->disagree_reason_cd   ",0)
 CALL echo(reply->disagree_reason_cd)
 CALL echo("reply->investigation_cd     ",0)
 CALL echo(reply->investigation_cd)
 CALL echo("reply->resolution_cd        ",0)
 CALL echo(reply->resolution_cd)
 CALL echo("reply->final_eval_term_id   ",0)
 CALL echo(reply->final_eval_term_id)
 CALL echo("reply->final_discrep_term_id",0)
 CALL echo(reply->final_discrep_term_id)
 CALL echo("reply->long_text_id         ",0)
 CALL echo(reply->long_text_id)
END GO
