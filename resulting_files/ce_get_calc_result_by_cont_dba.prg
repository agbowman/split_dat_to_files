CREATE PROGRAM ce_get_calc_result_by_cont:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 DECLARE record_status_draft = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(48,"DRAFT",1,record_status_draft)
 IF (record_status_draft <= 0)
  SET reply->error_msg = "-E-UAR Error retrieving value 'DRAFT' from code set 48."
  GO TO exit_script
 ENDIF
 SET ntotal2 = value(size(request->event_list,5))
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->event_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->event_list[idx].contributor_event_id = request->event_list[ntotal2].
   contributor_event_id
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  cl.event_id
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   ce_contributor_link cl,
   clinical_event ce
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (cl
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),cl.contributor_event_id,request->event_list[idx].
    contributor_event_id)
    AND cl.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100"))
   JOIN (ce
   WHERE cl.event_id=ce.event_id
    AND ce.record_status_cd != record_status_draft)
  ORDER BY cl.event_id
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].calculation_event_id = cl.event_id
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
