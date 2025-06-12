CREATE PROGRAM ce_get_new_results:dba
 DECLARE action_status_completed = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(103,"COMPLETED",1,action_status_completed)
 DECLARE action_status_refused = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(103,"REFUSED",1,action_status_refused)
 DECLARE action_type_sign = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(21,"SIGN",1,action_type_sign)
 DECLARE action_type_endorse = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(21,"ENDORSE",1,action_type_endorse)
 DECLARE action_type_review = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(21,"REVIEW",1,action_type_review)
 DECLARE event_class_placeholder = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(53,"PLACEHOLDER",1,event_class_placeholder)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 SET ntotal2 = value(size(request->event_list,5))
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->event_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->event_list[idx].event_id = request->event_list[ntotal2].event_id
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  ce.event_id
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   clinical_event ce
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (ce
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ce.event_id,request->event_list[idx].event_id)
    AND (ce.verified_prsnl_id != request->action_prsnl_id)
    AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100")
    AND ce.event_class_cd != event_class_placeholder
    AND (ce.clinsig_updt_dt_tm >
   (SELECT
    max(cep2.updt_dt_tm)
    FROM ce_event_prsnl cep2
    WHERE ((((cep2.action_status_cd+ 0) IN (action_status_completed, action_status_refused))
     AND cep2.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100")
     AND ((cep2.action_prsnl_id+ 0)=request->action_prsnl_id)
     AND ((cep2.action_type_cd+ 0) IN (action_type_sign, action_type_review, action_type_endorse))
     AND cep2.event_id=ce.event_id) OR (cep2.ce_event_prsnl_id=0.0)) )))
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].event_id = ce.event_id
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
