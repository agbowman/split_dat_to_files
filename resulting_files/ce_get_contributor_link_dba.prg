CREATE PROGRAM ce_get_contributor_link:dba
 DECLARE clvaliddttm = vc WITH public, noconstant("0=0")
 DECLARE cevaliddttm = vc WITH public, noconstant(" ce.valid_from_dt_tm = cl.ce_valid_from_dt_tm ")
 IF ((request->all_versions=0))
  IF ((request->valid_from_dt_tm_ind=0))
   SET clvaliddttm = " cl.valid_until_dt_tm >= cnvtdatetimeutc(request->valid_from_dt_tm) "
   SET clvaliddttm = concat(clvaliddttm,
    " and cl.valid_from_dt_tm <= cnvtdatetimeutc(request->valid_from_dt_tm) ")
   SET cevaliddttm = " ce.valid_from_dt_tm = cl.ce_valid_from_dt_tm "
  ENDIF
  IF ((request->valid_from_dt_tm_ind=1))
   SET clvaliddttm = " cl.valid_until_dt_tm >= cnvtdatetimeutc(request->valid_from_dt_tm) "
   SET cevaliddttm = " ( ce.valid_from_dt_tm = cl.ce_valid_from_dt_tm "
   SET cevaliddttm = concat(cevaliddttm,
    " OR ce.valid_until_dt_tm = cnvtdatetimeutc('31-DEC-2100') ) ")
  ENDIF
 ENDIF
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
  cl.event_id, cl.type_flag, cl.valid_from_dt_tm,
  valid_from_dt_tm_ind = nullind(cl.valid_from_dt_tm), cl.valid_until_dt_tm, valid_until_dt_tm_ind =
  nullind(cl.valid_until_dt_tm),
  cl.updt_dt_tm, updt_dt_tm_ind = nullind(cl.updt_dt_tm), cl.updt_id,
  cl.updt_task, updt_task_ind = nullind(cl.updt_task), cl.updt_cnt,
  updt_cnt_ind = nullind(cl.updt_cnt), cl.updt_applctx, updt_applctx_ind = nullind(cl.updt_applctx),
  cl.contributor_event_id, ce.valid_from_dt_tm, ce.valid_until_dt_tm,
  ce.result_val, ce.performed_prsnl_id, ce.event_end_dt_tm,
  ce.event_cd, ce.clinical_event_id, ce.event_class_cd,
  ce.result_status_cd, ce.event_end_tz
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   ce_contributor_link cl,
   clinical_event ce
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (cl
   WHERE expand(idx,nstart,(nstart+ (nsize - 1)),cl.event_id,request->event_list[idx].event_id)
    AND parser(clvaliddttm))
   JOIN (ce
   WHERE ce.event_id=cl.contributor_event_id
    AND parser(cevaliddttm))
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].event_id = cl.event_id, reply->reply_list[cnt].type_flag = cl.type_flag,
   reply->reply_list[cnt].valid_from_dt_tm = cl.valid_from_dt_tm,
   reply->reply_list[cnt].valid_from_dt_tm_ind = valid_from_dt_tm_ind, reply->reply_list[cnt].
   valid_until_dt_tm = cl.valid_until_dt_tm, reply->reply_list[cnt].valid_until_dt_tm_ind =
   valid_until_dt_tm_ind,
   reply->reply_list[cnt].updt_dt_tm = cl.updt_dt_tm, reply->reply_list[cnt].updt_dt_tm_ind =
   updt_dt_tm_ind, reply->reply_list[cnt].updt_id = cl.updt_id,
   reply->reply_list[cnt].updt_task = cl.updt_task, reply->reply_list[cnt].updt_task_ind =
   updt_task_ind, reply->reply_list[cnt].updt_cnt = cl.updt_cnt,
   reply->reply_list[cnt].updt_cnt_ind = updt_cnt_ind, reply->reply_list[cnt].updt_applctx = cl
   .updt_applctx, reply->reply_list[cnt].updt_applctx_ind = updt_applctx_ind,
   reply->reply_list[cnt].contributor_event_id = cl.contributor_event_id, reply->reply_list[cnt].
   ce_valid_from_dt_tm = ce.valid_from_dt_tm, reply->reply_list[cnt].ce_valid_until_dt_tm = ce
   .valid_until_dt_tm,
   reply->reply_list[cnt].ce_result_value = ce.result_val, reply->reply_list[cnt].
   ce_performed_prsnl_id = ce.performed_prsnl_id, reply->reply_list[cnt].ce_event_end_dt_tm = ce
   .event_end_dt_tm,
   reply->reply_list[cnt].ce_event_cd = ce.event_cd, reply->reply_list[cnt].ce_clinical_event_id = ce
   .clinical_event_id, reply->reply_list[cnt].ce_event_class_cd = ce.event_class_cd,
   reply->reply_list[cnt].ce_result_status_cd = ce.result_status_cd, reply->reply_list[cnt].
   ce_event_end_tz = ce.event_end_tz
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
