CREATE PROGRAM aps_chg_dc_event_prsnl_grp:dba
 RECORD reply(
   1 event_id = f8
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
 SET event_id = 0.0
 SET updt_cnt = 0
 IF ((request->add_ind=1))
  CALL echo("add_ind = 1")
  SET new_seq_nbr = 0
  SELECT INTO "nl:"
   seq_nbr = seq(pathnet_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    event_id = cnvtreal(seq_nbr), reply->event_id = event_id
   WITH format, nocounter
  ;end select
  IF (curqual=0)
   CALL handle_errors("SELECT","F","TABLE","PATHNET_SEQ")
   GO TO exit_script
  ENDIF
  INSERT  FROM ap_dc_event ade
   SET ade.event_id = event_id, ade.study_id = request->study_id, ade.case_id = request->case_id,
    ade.correlate_case_id = request->correlate_case_id, ade.prsnl_group_id = request->prsnl_group_id,
    ade.initiated_prsnl_id = reqinfo->updt_id,
    ade.initiated_dt_tm = cnvtdatetime(curdate,curtime), ade.updt_dt_tm = cnvtdatetime(curdate,
     curtime), ade.updt_id = reqinfo->updt_id,
    ade.updt_task = reqinfo->updt_task, ade.updt_applctx = reqinfo->updt_applctx, ade.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","AP_DC_EVENT")
   GO TO exit_script
  ENDIF
 ELSE
  CALL echo("add_ind != 1")
  SELECT INTO "nl:"
   ade.event_id
   FROM ap_dc_event ade
   PLAN (ade
    WHERE (request->study_id=ade.study_id)
     AND (request->case_id=ade.case_id)
     AND (request->correlate_case_id=ade.correlate_case_id)
     AND (request->prsnl_group_id=ade.prsnl_group_id)
     AND 0=ade.cancel_prsnl_id)
   DETAIL
    event_id = ade.event_id, reply->event_id = event_id
   WITH nocounter, forupdate(ade)
  ;end select
  IF (curqual=0)
   CALL handle_errors("LOCK","F","TABLE","AP_DC_EVENT")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->add_cnt > 0))
  CALL echo("add_ind > 0")
  INSERT  FROM ap_dc_event_prsnl adep,
    (dummyt d  WITH seq = value(request->add_cnt))
   SET adep.event_id = event_id, adep.prsnl_group_id = request->prsnl_group_id, adep.prsnl_id =
    request->add_qual[d.seq].prsnl_id,
    adep.updt_dt_tm = cnvtdatetime(curdate,curtime), adep.updt_id = reqinfo->updt_id, adep.updt_task
     = reqinfo->updt_task,
    adep.updt_applctx = reqinfo->updt_applctx, adep.updt_cnt = 0
   PLAN (d)
    JOIN (adep)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","AP_DC_EVENT_PRSNL")
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo("event id -> ",0)
 CALL echo(event_id)
 IF ((request->del_cnt > 0))
  CALL echo("BYTE ME")
  DELETE  FROM ap_dc_event_prsnl adep,
    (dummyt d  WITH seq = value(request->del_cnt))
   SET adep.seq = 1
   PLAN (d)
    JOIN (adep
    WHERE event_id=adep.event_id
     AND (request->prsnl_group_id=adep.prsnl_group_id)
     AND (request->del_qual[d.seq].prsnl_id=adep.prsnl_id))
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL handle_errors("DELETE","F","TABLE","AP_DC_EVENT_PRSNL")
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->add_ind=0))
  UPDATE  FROM ap_dc_event ade
   SET ade.cancel_prsnl_id =
    IF ((request->cancel_ind=1)) reqinfo->updt_id
    ELSE ade.cancel_prsnl_id
    ENDIF
    , ade.cancel_dt_tm =
    IF ((request->cancel_ind=1)) cnvtdatetime(curdate,curtime)
    ELSE ade.cancel_dt_tm
    ENDIF
    , ade.updt_dt_tm = cnvtdatetime(curdate,curtime),
    ade.updt_id = reqinfo->updt_id, ade.updt_task = reqinfo->updt_task, ade.updt_applctx = reqinfo->
    updt_applctx,
    ade.updt_cnt = (ade.updt_cnt+ 1)
   WHERE event_id=ade.event_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   CALL handle_errors("UPDATE","F","TABLE","AP_DC_EVENT")
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
 CALL echo(reply->status_data.status)
END GO
