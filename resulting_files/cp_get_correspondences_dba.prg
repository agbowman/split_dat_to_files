CREATE PROGRAM cp_get_correspondences:dba
 RECORD reply(
   1 item_list[*]
     2 event_id = f8
     2 linked_event_id = f8
     2 event_cd = f8
     2 event_cd_disp = c40
     2 collected_dt_tm = dq8
     2 action_dt_tm = dq8
     2 action_prsnl_id = f8
     2 comment = vc
     2 action_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 DECLARE endorse_cd = f8
 DECLARE event_id_cnt = i4
 DECLARE now = q8
 SET stat = uar_get_meaning_by_codeset(21,"ENDORSE",1,endorse_cd)
 SET event_id_cnt = size(request->event_ids,5)
 SET now = cnvtdatetime(curdate,curtime)
 IF (event_id_cnt > 0)
  SELECT INTO "nl:"
   FROM clinical_event ce,
    ce_event_prsnl cep,
    (dummyt d  WITH seq = value(event_id_cnt))
   PLAN (d)
    JOIN (ce
    WHERE (ce.event_id=request->event_ids[d.seq].event_id)
     AND ce.valid_from_dt_tm <= cnvtdatetime(now)
     AND ce.valid_until_dt_tm >= cnvtdatetime(now))
    JOIN (cep
    WHERE cep.event_id=ce.event_id
     AND cep.valid_from_dt_tm <= cnvtdatetime(now)
     AND cep.valid_until_dt_tm >= cnvtdatetime(now)
     AND cep.action_type_cd=endorse_cd
     AND cep.system_comment > " ")
   ORDER BY d.seq, cep.action_dt_tm
   HEAD REPORT
    actioncnt = 0
   DETAIL
    actioncnt = (actioncnt+ 1)
    IF (mod(actioncnt,10)=1)
     stat = alterlist(reply->item_list,(actioncnt+ 9))
    ENDIF
    reply->item_list[actioncnt].event_id = ce.event_id, reply->item_list[actioncnt].linked_event_id
     = cep.linked_event_id, reply->item_list[actioncnt].event_cd = ce.event_cd,
    reply->item_list[actioncnt].collected_dt_tm = ce.event_end_dt_tm, reply->item_list[actioncnt].
    action_dt_tm = cep.action_dt_tm, reply->item_list[actioncnt].action_prsnl_id = cep
    .action_prsnl_id,
    reply->item_list[actioncnt].action_tz = cep.action_tz, reply->item_list[actioncnt].comment = cep
    .system_comment
   FOOT REPORT
    stat = alterlist(reply->item_list,actioncnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.operationname = "Select"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "ErrorMessage"
   SET reply->status_data.targetobjectvalue = errmsg
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.operationname = "Select"
   SET reply->status_data.operationstatus = "Z"
   SET reply->status_data.targetobjectname = "Qualifications"
   SET reply->status_data.targetobjectvalue = "No matching records"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
