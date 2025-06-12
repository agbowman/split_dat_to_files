CREATE PROGRAM ce_get_event_prsnl:dba
 DECLARE epdttm = vc WITH public, noconstant(' ep.valid_until_dt_tm=cnvtdatetime("31-dec-2100") ')
 DECLARE list_index = i4
 DECLARE edigital_signature_mode = i4 WITH constant(1073741824)
 IF ((request->valid_from_dt_tm_ind=0))
  SET epdttm = concat("ep.valid_from_dt_tm+0 <= cnvtdatetimeutc(request->valid_from_dt_tm)",
   " and ep.valid_until_dt_tm >= cnvtdatetimeutc(request->valid_from_dt_tm) ")
 ENDIF
 IF (request->all_versions)
  SET epdttm = " 1=1 "
 ENDIF
 FREE RECORD longtxtidlist
 RECORD longtxtidlist(
   1 from_ep_rec[*]
     2 long_text_id = f8
 )
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE cnt2 = i4 WITH noconstant(0)
 DECLARE eprepindex = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE actiontypelist = vc WITH public, noconstant(" ")
 DECLARE actiontypelistsize = i4 WITH public, constant(size(request->action_type_cd_list,5))
 DECLARE actionidx = i4
 DECLARE stat_f8 = f8 WITH protect, noconstant(0.0)
 DECLARE stat_vc = vc WITH protect, noconstant("")
 IF (actiontypelistsize=1)
  SET actiontypelist = concat("ep.action_type_cd = request->action_type_cd_list[1]->action_type_cd")
 ELSEIF (actiontypelistsize > 1)
  SET actiontypelist = concat("(expand (actionIdx, 1, actionTypeListSize, ",
   " ep.action_type_cd, request->action_type_cd_list[actionIdx]->action_type_cd)) ")
 ELSE
  SET actiontypelist = " 1=1 "
 ENDIF
 SET ntotal2 = value(size(request->event_list,5))
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->event_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->event_list[idx].event_id = request->event_list[ntotal2].event_id
 ENDFOR
 SELECT INTO "nl:"
  ep.ce_event_prsnl_id, ep.event_id, ep.valid_until_dt_tm,
  valid_until_dt_tm_ind = nullind(ep.valid_until_dt_tm), ep.event_prsnl_id, ep.person_id,
  ep.valid_from_dt_tm, valid_from_dt_tm_ind = nullind(ep.valid_from_dt_tm), ep.action_type_cd,
  ep.request_dt_tm, request_dt_tm_ind = nullind(ep.request_dt_tm), ep.request_tz,
  ep.request_prsnl_id, ep.request_prsnl_ft, ep.request_comment,
  ep.action_dt_tm, action_dt_tm_ind = nullind(ep.action_dt_tm), ep.action_tz,
  ep.action_prsnl_id, ep.action_prsnl_ft, ep.proxy_prsnl_id,
  ep.proxy_prsnl_ft, ep.action_status_cd, ep.action_comment,
  ep.change_since_action_flag, ep.updt_dt_tm, updt_dt_tm_ind = nullind(ep.updt_dt_tm),
  ep.updt_id, ep.updt_task, updt_task_ind = nullind(ep.updt_task),
  ep.updt_cnt, updt_cnt_ind = nullind(ep.updt_cnt), ep.updt_applctx,
  updt_applctx_ind = nullind(ep.updt_applctx), ep.long_text_id, ep.linked_event_id,
  ep.system_comment, ep.digital_signature_ident, ep.action_prsnl_group_id,
  ep.request_prsnl_group_id, ep.receiving_person_id, ep.receiving_person_ft,
  ep.action_organization_id, ep.action_organization_ft
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   ce_event_prsnl ep
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (ep
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ep.event_id,request->event_list[idx].event_id)
    AND parser(epdttm)
    AND parser(actiontypelist))
  ORDER BY ep.long_text_id
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   IF (ep.long_text_id > 0)
    cnt2 += 1
    IF (mod(cnt2,10)=1)
     stat = alterlist(longtxtidlist->from_ep_rec,(cnt2+ 9))
    ENDIF
    longtxtidlist->from_ep_rec[cnt2].long_text_id = ep.long_text_id
   ENDIF
   reply->reply_list[cnt].ce_event_prsnl_id = ep.ce_event_prsnl_id, reply->reply_list[cnt].person_id
    = ep.person_id, reply->reply_list[cnt].request_comment = ep.request_comment,
   reply->reply_list[cnt].action_comment = ep.action_comment, reply->reply_list[cnt].
   change_since_action_flag = ep.change_since_action_flag, reply->reply_list[cnt].updt_dt_tm = ep
   .updt_dt_tm,
   reply->reply_list[cnt].updt_dt_tm_ind = updt_dt_tm_ind, reply->reply_list[cnt].updt_id = ep
   .updt_id, reply->reply_list[cnt].updt_task = ep.updt_task,
   reply->reply_list[cnt].updt_task_ind = updt_task_ind, reply->reply_list[cnt].updt_cnt = ep
   .updt_cnt, reply->reply_list[cnt].updt_cnt_ind = updt_cnt_ind,
   reply->reply_list[cnt].updt_applctx = ep.updt_applctx, reply->reply_list[cnt].updt_applctx_ind =
   updt_applctx_ind, reply->reply_list[cnt].long_text_id = ep.long_text_id,
   reply->reply_list[cnt].event_id = ep.event_id, reply->reply_list[cnt].valid_until_dt_tm = ep
   .valid_until_dt_tm, reply->reply_list[cnt].valid_until_dt_tm_ind = valid_until_dt_tm_ind,
   reply->reply_list[cnt].event_prsnl_id = ep.event_prsnl_id, reply->reply_list[cnt].valid_from_dt_tm
    = ep.valid_from_dt_tm, reply->reply_list[cnt].valid_from_dt_tm_ind = valid_from_dt_tm_ind,
   reply->reply_list[cnt].action_type_cd = ep.action_type_cd, reply->reply_list[cnt].request_dt_tm =
   ep.request_dt_tm, reply->reply_list[cnt].request_dt_tm_ind = request_dt_tm_ind,
   reply->reply_list[cnt].request_tz = ep.request_tz, reply->reply_list[cnt].request_prsnl_id = ep
   .request_prsnl_id, reply->reply_list[cnt].request_prsnl_ft = ep.request_prsnl_ft,
   reply->reply_list[cnt].action_dt_tm = ep.action_dt_tm, reply->reply_list[cnt].action_dt_tm_ind =
   action_dt_tm_ind, reply->reply_list[cnt].action_tz = ep.action_tz,
   reply->reply_list[cnt].action_prsnl_id = ep.action_prsnl_id, reply->reply_list[cnt].
   action_prsnl_ft = ep.action_prsnl_ft, reply->reply_list[cnt].proxy_prsnl_id = ep.proxy_prsnl_id,
   reply->reply_list[cnt].proxy_prsnl_ft = ep.proxy_prsnl_ft, reply->reply_list[cnt].action_status_cd
    = ep.action_status_cd, reply->reply_list[cnt].linked_event_id = ep.linked_event_id,
   reply->reply_list[cnt].system_comment = ep.system_comment, reply->reply_list[cnt].
   action_prsnl_group_id = ep.action_prsnl_group_id, reply->reply_list[cnt].request_prsnl_group_id =
   ep.request_prsnl_group_id,
   reply->reply_list[cnt].receiving_person_id = ep.receiving_person_id, reply->reply_list[cnt].
   receiving_person_ft = ep.receiving_person_ft, stat_f8 = assign(validate(reply->reply_list[cnt].
     action_organization_id,0),ep.action_organization_id),
   stat_vc = assign(validate(reply->reply_list[cnt].action_organization_ft,""),ep
    .action_organization_ft)
   IF (band(request->query_mode,edigital_signature_mode))
    reply->reply_list[cnt].digital_signature_ident = ep.digital_signature_ident
   ENDIF
  WITH nocounter
 ;end select
 SET nstart = 1
 SET stat = alterlist(longtxtidlist->from_ep_rec,cnt2)
 SET ntotal2 = cnt2
 IF (ntotal2 < 1)
  GO TO skip_long_text
 ENDIF
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(longtxtidlist->from_ep_rec,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET longtxtidlist->from_ep_rec[idx].long_text_id = longtxtidlist->from_ep_rec[ntotal2].
   long_text_id
 ENDFOR
 SELECT INTO "nl:"
  lt.long_text
  FROM (dummyt d2  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   long_text lt
  PLAN (d2
   WHERE initarray(nstart,evaluate(d2.seq,1,1,(nstart+ nsize))))
   JOIN (lt
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),lt.long_text_id,longtxtidlist->from_ep_rec[idx].
    long_text_id))
  ORDER BY lt.long_text_id
  DETAIL
   IF (eprepindex < cnt)
    eprepindex += 1
   ENDIF
   WHILE (eprepindex < cnt
    AND (lt.long_text_id != reply->reply_list[eprepindex].long_text_id))
     eprepindex += 1
   ENDWHILE
   IF (eprepindex <= cnt)
    reply->reply_list[eprepindex].long_text = lt.long_text
   ENDIF
   WHILE (eprepindex < cnt
    AND (reply->reply_list[eprepindex].long_text_id=reply->reply_list[(eprepindex+ 1)].long_text_id))
    eprepindex += 1,reply->reply_list[eprepindex].long_text = lt.long_text
   ENDWHILE
  WITH nocounter
 ;end select
#skip_long_text
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
