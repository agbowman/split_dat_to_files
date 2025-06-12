CREATE PROGRAM ce_get_deficient_results:dba
 DECLARE record_status_deleted = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,record_status_deleted)
 DECLARE record_status_draft = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(48,"DRAFT",1,record_status_draft)
 DECLARE result_status_inerror = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(8,"INERROR",1,result_status_inerror)
 DECLARE result_status_inerrnoview = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(8,"INERRNOVIEW",1,result_status_inerrnoview)
 DECLARE result_status_inerrnomut = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(8,"INERRNOMUT",1,result_status_inerrnomut)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 SET ntotal2 = value(size(request->action_status_cd_list,5))
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->action_status_cd_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->action_status_cd_list[idx].action_status_cd = request->action_status_cd_list[ntotal2]
   .action_status_cd
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  ce.event_id
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   clinical_event ce,
   ce_event_prsnl ep
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (ep
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ep.action_status_cd,request->action_status_cd_list[
    idx].action_status_cd)
    AND (ep.action_prsnl_id=request->action_prsnl_id)
    AND ep.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100"))
   JOIN (ce
   WHERE ce.event_id=ep.event_id
    AND  NOT (ce.record_status_cd IN (record_status_deleted, record_status_draft))
    AND  NOT (ce.result_status_cd IN (result_status_inerror, result_status_inerrnoview,
   result_status_inerrnomut))
    AND ce.encntr_id > 0
    AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100"))
  ORDER BY ce.event_id
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].encntr_id = ce.encntr_id, reply->reply_list[cnt].person_id = ce.person_id,
   reply->reply_list[cnt].event_cd = ce.event_cd
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
