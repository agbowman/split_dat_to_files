CREATE PROGRAM aps_chg_dc_event:dba
 RECORD reply(
   1 long_text_id = f8
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
 SET ade_updt_cnt = 0
 SET new_seq_nbr = 0.0
 IF (textlen(request->long_text) > 0)
  IF ((request->long_text_id=0))
   SET new_seq_nbr = 0.0
   SELECT INTO "nl:"
    seq_nbr = seq(long_data_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_seq_nbr = seq_nbr
    WITH format, counter
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","LONG_DATA_SEQ")
    GO TO exit_script
   ENDIF
   INSERT  FROM long_text lt
    SET lt.long_text_id = new_seq_nbr, lt.parent_entity_name = "AP_DC_EVENT", lt.parent_entity_id =
     request->event_id,
     lt.long_text = request->long_text, lt.active_ind = 1, lt.active_status_cd = reqdata->
     active_status_cd,
     lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
     updt_id, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
     lt.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL handle_errors("INSERT","F","TABLE","LONG_TEXT")
    GO TO exit_script
   ENDIF
   SET reply->long_text_id = new_seq_nbr
  ELSE
   SET lt_updt_cnt = 0
   SELECT INTO "nl:"
    lt.long_text_id
    FROM long_text lt
    WHERE (request->long_text_id=lt.long_text_id)
    DETAIL
     lt_updt_cnt = lt.updt_cnt
    WITH nocounter, forupdate(lt)
   ;end select
   IF (curqual=0)
    CALL handle_errors("LOCK","F","TABLE","LONG_TEXT")
    GO TO exit_script
   ENDIF
   UPDATE  FROM long_text lt
    SET lt.long_text = request->long_text, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id
      = reqinfo->updt_id,
     lt.updt_task = reqinfo->updt_task, lt.updt_cnt = (lt_updt_cnt+ 1)
    WHERE (request->long_text_id=lt.long_text_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL handle_errors("UPDATE","F","TABLE","LONG_TEXT")
    GO TO exit_script
   ENDIF
   SET reply->long_text_id = request->long_text_id
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  ade.event_id
  FROM ap_dc_event ade
  WHERE (request->event_id=ade.event_id)
  DETAIL
   ade_updt_cnt = ade.updt_cnt
  WITH nocounter, forupdate(ade)
 ;end select
 IF (curqual=0)
  CALL handle_errors("LOCK","F","TABLE","AP_dc_EVENT")
  SET reply->status_data.status = "F"
 ENDIF
 UPDATE  FROM ap_dc_event a
  SET a.init_eval_term_id = request->init_eval_term_id, a.init_discrep_term_id = request->
   init_discrep_term_id, a.disagree_reason_cd = request->disagree_reason_cd,
   a.investigation_cd = request->investigation_cd, a.resolution_cd = request->resolution_cd, a
   .final_eval_term_id = request->final_eval_term_id,
   a.final_discrep_term_id = request->final_discrep_term_id, a.long_text_id = reply->long_text_id, a
   .prsnl_group_id = request->prsnl_group_id,
   a.complete_prsnl_id =
   IF ((request->complete_ind=1)) reqinfo->updt_id
   ELSE a.complete_prsnl_id
   ENDIF
   , a.complete_dt_tm =
   IF ((request->complete_ind=1)) cnvtdatetime(curdate,curtime)
   ELSE a.complete_dt_tm
   ENDIF
   , a.updt_dt_tm = cnvtdatetime(curdate,curtime),
   a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
   updt_applctx,
   a.updt_cnt = (ade_updt_cnt+ 1)
  WHERE (request->event_id=a.event_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL handle_errors("UPDATE","F","TABLE","AP_FT_EVENT")
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
 IF (error_cnt > 0)
  SET reqinfo->commit_ind = 0
  CALL echo("<<<<< F <<<<<")
  CALL echo(build("errors->",error_cnt))
  CALL echo(reply->status_data.subeventstatus[1].operationname)
  CALL echo(reply->status_data.subeventstatus[1].targetobjectvalue)
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  CALL echo(">>>>> S >>>>>")
 ENDIF
END GO
