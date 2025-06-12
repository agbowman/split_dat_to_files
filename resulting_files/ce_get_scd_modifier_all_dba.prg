CREATE PROGRAM ce_get_scd_modifier_all:dba
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
 SELECT INTO "nl:"
  ss.event_id, st.concept_cki, sp.phrase_string,
  stt.display, ss.updt_dt_tm, updt_dt_tm_ind = nullind(ss.updt_dt_tm),
  ss.updt_id, ss.updt_task, updt_task_ind = nullind(ss.updt_task),
  ss.updt_cnt, updt_cnt_ind = nullind(ss.updt_cnt), ss.updt_applctx,
  updt_applctx_ind = nullind(ss.updt_applctx)
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   scd_story ss,
   scd_term st,
   scr_phrase sp,
   scr_term_text stt,
   clinical_event ce
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (ss
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ss.event_id,request->event_list[idx].event_id)
    AND ss.active_ind=1)
   JOIN (st
   WHERE ss.scd_story_id=st.scd_story_id)
   JOIN (sp
   WHERE st.scr_phrase_id=sp.scr_phrase_id)
   JOIN (stt
   WHERE st.scr_term_id=stt.scr_term_id)
   JOIN (ce
   WHERE ce.event_id=ss.event_id
    AND ce.modifier_long_text_id > 0)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].event_id = ss.event_id, reply->reply_list[cnt].concept_cki = st.concept_cki,
   reply->reply_list[cnt].phrase = sp.phrase_string,
   reply->reply_list[cnt].display = stt.display, reply->reply_list[cnt].updt_dt_tm = ss.updt_dt_tm,
   reply->reply_list[cnt].updt_dt_tm_ind = updt_dt_tm_ind,
   reply->reply_list[cnt].updt_id = ss.updt_id, reply->reply_list[cnt].updt_task = ss.updt_task,
   reply->reply_list[cnt].updt_task_ind = updt_task_ind,
   reply->reply_list[cnt].updt_cnt = ss.updt_cnt, reply->reply_list[cnt].updt_cnt_ind = updt_cnt_ind,
   reply->reply_list[cnt].updt_applctx = ss.updt_applctx,
   reply->reply_list[cnt].updt_applctx_ind = updt_applctx_ind, reply->reply_list[cnt].
   valid_from_dt_tm = ce.valid_from_dt_tm
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
