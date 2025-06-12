CREATE PROGRAM ce_ins_upd_draft
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
 FREE RECORD ce_draft_reltn
 RECORD ce_draft_reltn(
   1 qual[*]
     2 ce_draft_reltn_id = f8
     2 event_id = f8
 )
 FREE RECORD m_dm2_seq_stat
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE insert_draft_ind = i2 WITH noconstant(1)
 DECLARE insert_draft_reltn_ind = i2 WITH noconstant(1)
 DECLARE entry_mode_code = f8 WITH noconstant(request->entry_mode_cd)
 DECLARE update_cnt = i2 WITH noconstant(0)
 DECLARE failed = vc WITH noconstant("F")
 DECLARE insert_event_id_list_size = i2 WITH noconstant(size(request->insert_event_id_list,5))
 DECLARE update_event_id_list_size = i2 WITH constant(size(request->update_event_id_list,5))
 DECLARE event_id_count = i2 WITH noconstant(insert_event_id_list_size)
 SET errmsg = fillstring(132," ")
 SET stat = alterlist(ce_draft_reltn->qual,insert_event_id_list_size)
 FOR (i = 1 TO insert_event_id_list_size)
   SET ce_draft_reltn->qual[i].event_id = request->insert_event_id_list[i].event_id
 ENDFOR
 SELECT INTO "nl:"
  FROM ce_draft rs
  WHERE (rs.ce_draft_id=request->ce_draft_id)
  DETAIL
   insert_draft_ind = 0, update_cnt = (rs.updt_cnt+ 1)
  WITH nocounter
 ;end select
 IF (insert_draft_ind=0
  AND update_event_id_list_size > 0)
  SELECT INTO "nl:"
   ce.event_id
   FROM clinical_event ce,
    (dummyt d  WITH seq = value(update_event_id_list_size))
   PLAN (d)
    JOIN (ce
    WHERE (ce.event_id=request->update_event_id_list[d.seq].event_id)
     AND  NOT ( EXISTS (
    (SELECT INTO "nl:"
     rs.event_id
     FROM ce_draft_reltn rs
     WHERE (rs.ce_draft_id=request->ce_draft_id)
      AND (rs.event_id=request->update_event_id_list[d.seq].event_id)))))
   DETAIL
    insert_event_id_list_size = (insert_event_id_list_size+ 1), stat = alterlist(ce_draft_reltn->qual,
     insert_event_id_list_size), ce_draft_reltn->qual[insert_event_id_list_size].event_id = ce
    .event_id
   WITH nocounter
  ;end select
 ENDIF
 IF (insert_event_id_list_size)
  EXECUTE dm2_dar_get_bulk_seq "ce_draft_reltn->qual", insert_event_id_list_size, "ce_draft_reltn_id",
  1, "ocf_seq"
  IF ((m_dm2_seq_stat->n_status != 1))
   SET errmsg = concat("ce_draft_reltn Sequence retrieval error: ",m_dm2_seq_stat->s_error_msg)
   SET failed = "T"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectvalue = errmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (insert_draft_ind=1)
  INSERT  FROM ce_draft rs
   SET rs.ce_draft_id = request->ce_draft_id, rs.entry_mode_cd = entry_mode_code, rs.create_dt_tm =
    cnvtdatetime(request->create_dt_tm),
    rs.last_modified_dt_tm = cnvtdatetime(request->create_dt_tm), rs.updt_applctx = reqinfo->
    updt_applctx, rs.updt_cnt = update_cnt,
    rs.updt_dt_tm = cnvtdatetime(curdate,curtime3), rs.updt_id = reqinfo->updt_id, rs.updt_task =
    reqinfo->updt_task
   WITH nocounter
  ;end insert
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->status_data.subeventstatus.operationname = "INSERT"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectname = "CE_DRAFT"
   SET reply->status_data.subeventstatus.targetobjectvalue = "Error inserting ce_draft row"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  UPDATE  FROM ce_draft rs
   SET rs.entry_mode_cd = entry_mode_code, rs.last_modified_dt_tm = cnvtdatetime(curdate,curtime3),
    rs.updt_applctx = reqinfo->updt_applctx,
    rs.updt_cnt = update_cnt, rs.updt_dt_tm = cnvtdatetime(curdate,curtime3), rs.updt_id = reqinfo->
    updt_id,
    rs.updt_task = reqinfo->updt_task
   WHERE (rs.ce_draft_id=request->ce_draft_id)
   WITH nocounter
  ;end update
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->status_data.subeventstatus.operationname = "UPDATE"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectname = "CE_DRAFT"
   SET reply->status_data.subeventstatus.targetobjectvalue = "Error updating CE_DRAFT row"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (insert_event_id_list_size > 0)
  INSERT  FROM ce_draft_reltn t,
    (dummyt d  WITH seq = value(insert_event_id_list_size))
   SET t.ce_draft_reltn_id = ce_draft_reltn->qual[d.seq].ce_draft_reltn_id, t.event_id =
    ce_draft_reltn->qual[d.seq].event_id, t.ce_draft_id = request->ce_draft_id,
    t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = 0, t.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task
   PLAN (d)
    JOIN (t)
   WITH nocounter
  ;end insert
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->status_data.subeventstatus.operationname = "INSERT"
   SET reply->status_data.subeventstatus.operationstatus = "F"
   SET reply->status_data.subeventstatus.targetobjectname = "CE_DRAFT_RELTN"
   SET reply->status_data.subeventstatus.targetobjectvalue = "Error inserting CE_DRAFT_RELTN row"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed != "T")
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
