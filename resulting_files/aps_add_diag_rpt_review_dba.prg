CREATE PROGRAM aps_add_diag_rpt_review:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 verified_dt_tm = dq8
   1 verified_prsnl_id = f8
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET x = 0
 SELECT INTO "nl:"
  ce.event_id
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.event_id=request->event_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   temp->verified_prsnl_id = ce.verified_prsnl_id, temp->verified_dt_tm = ce.verified_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  adrr.event_id
  FROM ap_diag_rpt_review adrr
  PLAN (adrr
   WHERE (adrr.event_id=request->event_id))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM ap_diag_rpt_review adrr
   SET adrr.event_id = request->event_id, adrr.prefix_id = request->prefix_id, adrr.verified_prsnl_id
     = temp->verified_prsnl_id,
    adrr.verified_dt_tm = cnvtdatetime(temp->verified_dt_tm), adrr.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), adrr.updt_id = reqinfo->updt_id,
    adrr.updt_task = reqinfo->updt_task, adrr.updt_applctx = reqinfo->updt_applctx, adrr.updt_cnt = (
    adrr.updt_cnt+ 1)
   WHERE (adrr.event_id=request->event_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
  ENDIF
 ELSE
  INSERT  FROM ap_diag_rpt_review adrr
   SET adrr.event_id = request->event_id, adrr.prefix_id = request->prefix_id, adrr.verified_prsnl_id
     = temp->verified_prsnl_id,
    adrr.verified_dt_tm = cnvtdatetime(temp->verified_dt_tm), adrr.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), adrr.updt_id = reqinfo->updt_id,
    adrr.updt_task = reqinfo->updt_task, adrr.updt_applctx = reqinfo->updt_applctx, adrr.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
