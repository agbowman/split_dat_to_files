CREATE PROGRAM ce_get_label:dba
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE nsize = i4 WITH constant(50)
 DECLARE ntotal2 = i4 WITH noconstant(0)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant(" ")
 DECLARE error_code = i4 WITH noconstant(0)
 SET ntotal2 = size(request->label_list,5)
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->label_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->label_list[idx].ce_dynamic_label_id = request->label_list[ntotal2].
   ce_dynamic_label_id
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  dl.ce_dynamic_label_id, dl.label_name, dl.label_prsnl_id,
  dl.label_status_cd, dl.label_seq_nbr, dl.valid_from_dt_tm,
  lt.long_text
  FROM ce_dynamic_label dl,
   long_text lt,
   (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize))))
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (dl
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),dl.ce_dynamic_label_id,request->label_list[idx].
    ce_dynamic_label_id))
   JOIN (lt
   WHERE dl.long_text_id=lt.long_text_id)
  ORDER BY dl.ce_dynamic_label_id
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].ce_dynamic_label_id = dl.ce_dynamic_label_id, reply->reply_list[cnt].
   label_name = dl.label_name, reply->reply_list[cnt].label_prsnl_id = dl.label_prsnl_id,
   reply->reply_list[cnt].label_status_cd = dl.label_status_cd, reply->reply_list[cnt].label_seq_nbr
    = dl.label_seq_nbr, reply->reply_list[cnt].valid_from_dt_tm = dl.valid_from_dt_tm,
   reply->reply_list[cnt].label_comment = lt.long_text
  WITH nocounter, memsort
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
