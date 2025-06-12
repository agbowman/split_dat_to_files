CREATE PROGRAM ce_event_prsnl_upd:dba
 RECORD reply(
   1 array_size = i4
   1 num_inserted = i4
   1 error_code = i4
   1 error_msg = vc
 )
 SET reply->array_size = size(request->lst,5)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 UPDATE  FROM ce_event_prsnl t,
   (dummyt d  WITH seq = value(reply->array_size))
  SET t.ce_event_prsnl_id = evaluate2(
    IF ((request->lst[d.seq].ce_event_prsnl_id=- (1))) 0
    ELSE request->lst[d.seq].ce_event_prsnl_id
    ENDIF
    ), t.event_id = evaluate2(
    IF ((request->lst[d.seq].event_id=- (1))) 0
    ELSE request->lst[d.seq].event_id
    ENDIF
    ), t.valid_until_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_until_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_until_dt_tm)
    ENDIF
    ),
   t.event_prsnl_id = evaluate2(
    IF ((request->lst[d.seq].event_prsnl_id=- (1))) 0
    ELSE request->lst[d.seq].event_prsnl_id
    ENDIF
    ), t.person_id = evaluate2(
    IF ((request->lst[d.seq].person_id=- (1))) 0
    ELSE request->lst[d.seq].person_id
    ENDIF
    ), t.valid_from_dt_tm = evaluate2(
    IF ((request->lst[d.seq].valid_from_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].valid_from_dt_tm)
    ENDIF
    ),
   t.action_type_cd = evaluate2(
    IF ((request->lst[d.seq].action_type_cd=- (1))) 0
    ELSE request->lst[d.seq].action_type_cd
    ENDIF
    ), t.request_dt_tm = evaluate2(
    IF ((request->lst[d.seq].request_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].request_dt_tm)
    ENDIF
    ), t.request_tz = request->lst[d.seq].request_tz,
   t.request_prsnl_id = evaluate2(
    IF ((request->lst[d.seq].request_prsnl_id=- (1))) 0
    ELSE request->lst[d.seq].request_prsnl_id
    ENDIF
    ), t.request_prsnl_ft = request->lst[d.seq].request_prsnl_ft, t.request_comment = request->lst[d
   .seq].request_comment,
   t.action_dt_tm = evaluate2(
    IF ((request->lst[d.seq].action_dt_tm_ind=1)) null
    ELSE cnvtdatetimeutc(request->lst[d.seq].action_dt_tm)
    ENDIF
    ), t.action_tz = request->lst[d.seq].action_tz, t.action_prsnl_id = evaluate2(
    IF ((request->lst[d.seq].action_prsnl_id=- (1))) 0
    ELSE request->lst[d.seq].action_prsnl_id
    ENDIF
    ),
   t.action_prsnl_ft = request->lst[d.seq].action_prsnl_ft, t.proxy_prsnl_id = evaluate2(
    IF ((request->lst[d.seq].proxy_prsnl_id=- (1))) 0
    ELSE request->lst[d.seq].proxy_prsnl_id
    ENDIF
    ), t.proxy_prsnl_ft = request->lst[d.seq].proxy_prsnl_ft,
   t.action_status_cd = evaluate2(
    IF ((request->lst[d.seq].action_status_cd=- (1))) 0
    ELSE request->lst[d.seq].action_status_cd
    ENDIF
    ), t.action_comment = request->lst[d.seq].action_comment, t.change_since_action_flag = evaluate2(
    IF ((request->lst[d.seq].change_since_action_flag_ind=1)) 0
    ELSE request->lst[d.seq].change_since_action_flag
    ENDIF
    ),
   t.updt_dt_tm = cnvtdatetimeutc(request->lst[d.seq].updt_dt_tm), t.updt_id = request->lst[d.seq].
   updt_id, t.updt_task = request->lst[d.seq].updt_task,
   t.updt_cnt = request->lst[d.seq].updt_cnt, t.updt_applctx = request->lst[d.seq].updt_applctx, t
   .long_text_id = evaluate2(
    IF ((request->lst[d.seq].long_text_id=- (1))) 0
    ELSE request->lst[d.seq].long_text_id
    ENDIF
    ),
   t.linked_event_id = evaluate2(
    IF ((request->lst[d.seq].linked_event_id=- (1))) 0
    ELSE request->lst[d.seq].linked_event_id
    ENDIF
    ), t.system_comment = request->lst[d.seq].system_comment, t.digital_signature_ident = request->
   lst[d.seq].digital_signature_ident,
   t.action_prsnl_group_id = request->lst[d.seq].action_prsnl_group_id, t.request_prsnl_group_id =
   request->lst[d.seq].request_prsnl_group_id, t.receiving_person_id = request->lst[d.seq].
   receiving_person_id,
   t.receiving_person_ft = request->lst[d.seq].receiving_person_ft, t.action_organization_id =
   evaluate2(
    IF ((validate(request->lst[d.seq].action_organization_id,t.action_organization_id)=- (1))) 0
    ELSE validate(request->lst[d.seq].action_organization_id,t.action_organization_id)
    ENDIF
    ), t.action_organization_ft = evaluate2(
    IF (validate(request->lst[d.seq].action_organization_ft,t.action_organization_ft)=" ") null
    ELSE validate(request->lst[d.seq].action_organization_ft,t.action_organization_ft)
    ENDIF
    )
  PLAN (d)
   JOIN (t
   WHERE (t.ce_event_prsnl_id=request->lst[d.seq].ce_event_prsnl_id))
  WITH rdbarrayinsert = 100, counter
 ;end update
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
