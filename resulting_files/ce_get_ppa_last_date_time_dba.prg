CREATE PROGRAM ce_get_ppa_last_date_time:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 SET ntotal2 = value(size(request->person_list,5))
 SET ntotal = (ntotal2+ (nsize - mod(ntotal2,nsize)))
 SET stat = alterlist(request->person_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->person_list[idx].person_id = request->person_list[ntotal2].person_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   person_prsnl_activity ppa
  PLAN (d1
   WHERE assign(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (ppa
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ppa.person_id,request->person_list[idx].person_id,
    200)
    AND (ppa.prsnl_id=request->prsnl_id)
    AND (ppa.ppa_type_cd=request->ppa_type_cd)
    AND ppa.active_ind=1)
  ORDER BY ppa.person_id
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   IF (cnt > 1
    AND (reply->reply_list[(cnt - 1)].person_id=ppa.person_id))
    cnt -= 1
   ENDIF
   reply->reply_list[cnt].person_id = ppa.person_id, reply->reply_list[cnt].ppa_last_dt_tm = ppa
   .ppa_last_dt_tm
  WITH nocounter
 ;end select
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET reply->qual = cnt
 SET stat = alterlist(reply->reply_list,cnt)
END GO
