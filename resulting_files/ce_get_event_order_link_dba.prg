CREATE PROGRAM ce_get_event_order_link:dba
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE nsize = i4 WITH constant(50)
 DECLARE ntotal2 = i4 WITH noconstant(0)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 SET ntotal2 = size(request->event_list,5)
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->event_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->event_list[idx].event_id = request->event_list[ntotal2].event_id
 ENDFOR
 SELECT
  IF ((request->all_versions=0)
   AND (request->valid_from_dt_tm_ind=0))
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (eol
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),eol.event_id,request->event_list[idx].event_id,
     200)
     AND eol.valid_until_dt_tm >= cnvtdatetimeutc(request->valid_from_dt_tm)
     AND eol.valid_from_dt_tm <= cnvtdatetimeutc(request->valid_from_dt_tm))
  ELSEIF ((request->all_versions=0))
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (eol
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),eol.event_id,request->event_list[idx].event_id,
     200)
     AND eol.valid_until_dt_tm >= cnvtdatetimeutc(request->valid_from_dt_tm))
  ELSE
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
    JOIN (eol
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),eol.event_id,request->event_list[idx].event_id,
     200))
  ENDIF
  INTO "nl:"
  eol.event_id, valid_from_dt_tm_ind = nullind(eol.valid_from_dt_tm), valid_until_dt_tm_ind = nullind
  (eol.valid_until_dt_tm),
  updt_dt_tm_ind = nullind(eol.updt_dt_tm), updt_task_ind = nullind(eol.updt_task), updt_cnt_ind =
  nullind(eol.updt_cnt),
  updt_applctx_ind = nullind(eol.updt_applctx), eol.parent_order_ident
  FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   ce_event_order_link eol
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].event_id = eol.event_id, reply->reply_list[cnt].order_id = eol.order_id,
   reply->reply_list[cnt].order_action_sequence = eol.order_action_sequence,
   reply->reply_list[cnt].valid_from_dt_tm = eol.valid_from_dt_tm, reply->reply_list[cnt].
   valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->reply_list[cnt].valid_until_dt_tm = eol
   .valid_until_dt_tm,
   reply->reply_list[cnt].valid_until_dt_tm_ind = valid_until_dt_tm_ind, reply->reply_list[cnt].
   updt_dt_tm = eol.updt_dt_tm, reply->reply_list[cnt].updt_dt_tm_ind = updt_dt_tm_ind,
   reply->reply_list[cnt].updt_id = eol.updt_id, reply->reply_list[cnt].updt_task = eol.updt_task,
   reply->reply_list[cnt].updt_task_ind = updt_task_ind,
   reply->reply_list[cnt].updt_cnt = eol.updt_cnt, reply->reply_list[cnt].updt_cnt_ind = updt_cnt_ind,
   reply->reply_list[cnt].updt_applctx = eol.updt_applctx,
   reply->reply_list[cnt].updt_applctx_ind = updt_applctx_ind, reply->reply_list[cnt].
   parent_order_ident = eol.parent_order_ident, reply->reply_list[cnt].event_end_dt_tm = eol
   .event_end_dt_tm,
   reply->reply_list[cnt].person_id = eol.person_id, reply->reply_list[cnt].encntr_id = eol.encntr_id,
   reply->reply_list[cnt].catalog_type_cd = eol.catalog_type_cd,
   reply->reply_list[cnt].ce_event_order_link_id = eol.ce_event_order_link_id
   IF (eol.parent_order_ident != eol.order_id)
    reply->reply_list[cnt].template_order_id = eol.parent_order_ident
   ENDIF
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
