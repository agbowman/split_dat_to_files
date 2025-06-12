CREATE PROGRAM ce_get_events_to_endorse:dba
 DECLARE action_status_completed = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(103,"COMPLETED",1,action_status_completed)
 DECLARE action_status_refused = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(103,"REFUSED",1,action_status_refused)
 DECLARE action_type_order = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(21,"ORDER",1,action_type_order)
 DECLARE action_type_sign = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(21,"SIGN",1,action_type_sign)
 DECLARE action_type_review = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(21,"REVIEW",1,action_type_review)
 DECLARE action_type_endorse = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(21,"ENDORSE",1,action_type_endorse)
 DECLARE event_class_placeholder = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(53,"PLACEHOLDER",1,event_class_placeholder)
 DECLARE event_class_group = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(53,"GRP",1,event_class_group)
 DECLARE elsize = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 DECLARE actiondttmrange1 = vc WITH public, noconstant("0=0")
 DECLARE actiondttmrange2 = vc WITH public, noconstant("0=0")
 IF ((request->date_ind=1))
  SET actiondttmrange1 = "cep.action_dt_tm > cnvtdatetimeutc(request->min_date)"
  SET actiondttmrange2 = "cep.action_dt_tm < cnvtdatetimeutc(request->max_date)"
 ENDIF
 DECLARE eventlistcnt = i4 WITH noconstant(0)
 DECLARE eventid = vc WITH public, noconstant("0=0")
 DECLARE actionstatuscd = vc WITH public, noconstant("0=0")
 DECLARE validuntildttm = vc WITH public, noconstant("0=0")
 DECLARE actionprsnlid = vc WITH public, noconstant("0=0")
 SET eventlistcnt = size(request->event_list,5)
 SET actionstatuscd = "cep.action_status_cd=ACTION_STATUS_COMPLETED"
 SET validuntildttm = "cep.valid_until_dt_tm+0 = cnvtdatetimeutc('31-dec-2100')"
 SET actionprsnlid = "cep.action_prsnl_id = request->prsnl_list[d.seq].action_prsnl_id"
 IF (eventlistcnt > 0)
  SET eventid = "cep.event_id = request->event_list[d2.seq].event_id"
  SET actionstatuscd = "cep.action_status_cd+0=ACTION_STATUS_COMPLETED"
  SET validuntildttm = "cep.valid_until_dt_tm=cnvtdatetimeutc('31-dec-2100')"
  SET actionprsnlid = "cep.action_prsnl_id+0=request->prsnl_list[d.seq].action_prsnl_id"
 ENDIF
 DECLARE personid = vc WITH public, noconstant("0=0")
 IF ((request->person_id > 0))
  SET personid = "cep.person_id = request->person_id"
 ENDIF
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE prsnl_cnt = i4 WITH noconstant(0)
 SELECT DISTINCT INTO "nl:"
  ce.event_class_cd, ce.event_tag, ce.result_status_cd,
  ce.person_id, p.name_full_formatted, ce.clinsig_updt_dt_tm,
  ce.updt_dt_tm, ce.event_cd, ce.normalcy_cd,
  ce.event_id, cep.action_prsnl_id, ce.event_title_text,
  ce.order_id
  FROM clinical_event ce,
   person p,
   ce_event_prsnl cep,
   (dummyt d  WITH seq = value(size(request->prsnl_list,5))),
   (dummyt d2  WITH seq = value(size(request->event_list,5)))
  PLAN (d)
   JOIN (d2)
   JOIN (cep
   WHERE parser(actionstatuscd)
    AND parser(validuntildttm)
    AND parser(actionprsnlid)
    AND ((cep.action_type_cd+ 0)=action_type_order)
    AND parser(actiondttmrange1)
    AND parser(actiondttmrange2)
    AND parser(personid)
    AND parser(eventid))
   JOIN (ce
   WHERE ((ce.event_id=cep.event_id) OR (ce.parent_event_id=cep.event_id))
    AND ce.verified_prsnl_id != cep.action_prsnl_id
    AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100")
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM ce_event_prsnl cep2
    WHERE ce.clinsig_updt_dt_tm <= cep2.updt_dt_tm
     AND ((cep2.action_status_cd+ 0) IN (action_status_completed, action_status_refused))
     AND cep2.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100")
     AND ((cep2.action_prsnl_id+ 0)=request->prsnl_list[d.seq].action_prsnl_id)
     AND ((cep2.action_type_cd+ 0) IN (action_type_sign, action_type_review, action_type_endorse))
     AND cep2.event_id=ce.event_id)))
    AND ce.view_level > 0
    AND ce.publish_flag=1
    AND ce.event_class_cd != event_class_placeholder
    AND ce.event_class_cd != event_class_group)
   JOIN (p
   WHERE p.person_id=ce.person_id
    AND p.active_ind=1)
  ORDER BY cep.action_prsnl_id, ce.event_id
  HEAD REPORT
   prsnl_cnt += 1, stat = alterlist(reply->reply_list,prsnl_cnt)
  DETAIL
   cnt += 1
   IF ((cep.action_prsnl_id != reply->reply_list[prsnl_cnt].prsnl_id))
    IF (cnt > 1)
     stat = alterlist(reply->reply_list[prsnl_cnt].event_list,(cnt - 1)), cnt = 1, prsnl_cnt += 1,
     stat = alterlist(reply->reply_list,prsnl_cnt)
    ENDIF
    reply->reply_list[prsnl_cnt].prsnl_id = cep.action_prsnl_id
   ENDIF
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list[prsnl_cnt].event_list,(cnt+ 9))
   ENDIF
   reply->reply_list[prsnl_cnt].event_list[cnt].event_id = ce.event_id, reply->reply_list[prsnl_cnt].
   event_list[cnt].event_class_cd = ce.event_class_cd, reply->reply_list[prsnl_cnt].event_list[cnt].
   event_class_cd_disp = uar_get_code_display(ce.event_class_cd),
   reply->reply_list[prsnl_cnt].event_list[cnt].event_class_cd_mean = uar_get_code_meaning(ce
    .event_class_cd), reply->reply_list[prsnl_cnt].event_list[cnt].event_tag = trim(ce.event_tag),
   reply->reply_list[prsnl_cnt].event_list[cnt].result_status_cd = ce.result_status_cd,
   reply->reply_list[prsnl_cnt].event_list[cnt].result_status_cd_disp = uar_get_code_display(ce
    .result_status_cd), reply->reply_list[prsnl_cnt].event_list[cnt].result_status_cd_mean =
   uar_get_code_display(ce.result_status_cd), reply->reply_list[prsnl_cnt].event_list[cnt].person_id
    = ce.person_id,
   reply->reply_list[prsnl_cnt].event_list[cnt].name_full_formatted = trim(p.name_full_formatted),
   reply->reply_list[prsnl_cnt].event_list[cnt].clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm, reply->
   reply_list[prsnl_cnt].event_list[cnt].updt_dt_tm = ce.updt_dt_tm,
   reply->reply_list[prsnl_cnt].event_list[cnt].event_cd = ce.event_cd, reply->reply_list[prsnl_cnt].
   event_list[cnt].normalcy_cd = ce.normalcy_cd, reply->reply_list[prsnl_cnt].event_list[cnt].
   event_title_text = ce.event_title_text,
   reply->reply_list[prsnl_cnt].event_list[cnt].order_id = ce.order_id
  WITH nocounter
 ;end select
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 IF (cnt > 0)
  SET stat = alterlist(reply->reply_list[prsnl_cnt].event_list,cnt)
 ENDIF
END GO
