CREATE PROGRAM ce_get_events_by_label:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 reply_list[*]
     2 event_id = f8
     2 ce_dynamic_label_id = f8
     2 event_cd = f8
     2 event_end_dt_tm = dq8
     2 subtable_bit_map2 = i4
     2 security_label_list[*]
       3 sensitivity_reason_cd = f8
 )
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE seclbl_cnt = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE filteridx = i4
 DECLARE ntotal = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(25)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE repgroup = f8 WITH constant(uar_get_code_by("MEANING",255431,"REPGROUP"))
 DECLARE inerror = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE inerrornoview = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
 DECLARE inerrornomut = f8 WITH constant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
 DECLARE record_status_draft = f8 WITH noconstant(0.0)
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(48,"DRAFT",1,record_status_draft)
 DECLARE draft_clause = vc WITH noconstant(build("ce.record_status_cd != ",record_status_draft))
 IF (validate(request->return_draft))
  IF ((request->return_draft=1))
   SET draft_clause = "1 = 1"
  ENDIF
 ENDIF
 SET ntotal2 = value(size(request->label_list,5))
 IF (validate(request->filter_list) > 0)
  DECLARE filtersize = i4 WITH constant(size(request->filter_list,5))
  IF (filtersize > 0)
   SELECT INTO "nl:"
    FROM ce_dynamic_label cdl
    WHERE expand(idx,1,ntotal2,cdl.ce_dynamic_label_id,request->label_list[idx].ce_dynamic_label_id)
     AND expand(filteridx,1,filtersize,cdl.label_status_cd,request->filter_list[filteridx].
     label_status_cd)
    HEAD REPORT
     pos = 0
    DETAIL
     pos = 0
     WHILE (assign(pos,locateval(idx,(pos+ 1),ntotal2,cdl.ce_dynamic_label_id,request->label_list[idx
       ].ce_dynamic_label_id)) > 0)
       request->label_list[pos].ce_dynamic_label_id = 0.0
     ENDWHILE
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET stat = alterlist(request->label_list,ntotal)
 FOR (idx = (ntotal2+ 1) TO ntotal)
   SET request->label_list[idx].ce_dynamic_label_id = request->label_list[ntotal2].
   ce_dynamic_label_id
 ENDFOR
 SET error_msg = fillstring(132," ")
 SET error_code = 0
 SET sec_label_exists = checkdic("CLINICAL_EVENT_SEC_LBL","T",0)
 SELECT
  IF (sec_label_exists > 0)INTO "nl:"
   ce.event_id, ce.ce_dynamic_label_id, subtable_bit_map2 = ce.subtable_bit_map2,
   sensitivity_reason_cd = csl.sensitivity_reason_cd
   FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    clinical_event ce,
    (left JOIN clinical_event_sec_lbl csl ON ce.event_id=csl.event_id
     AND csl.active_ind=1)
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
    JOIN (ce
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ce.ce_dynamic_label_id,request->label_list[idx].
     ce_dynamic_label_id)
     AND ce.ce_dynamic_label_id != 0.0
     AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
     AND  NOT (ce.result_status_cd IN (inerror, inerrornoview, inerrornomut))
     AND parser(draft_clause)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM ce_result_set_link rsl
     WHERE rsl.event_id=ce.event_id
      AND rsl.entry_type_cd=repgroup
      AND rsl.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")))))
    JOIN (csl)
  ELSE INTO "nl:"
   ce.event_id, ce.ce_dynamic_label_id, subtable_bit_map2 = 0,
   sensitivity_reason_cd = 0
   FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
    clinical_event ce
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
    JOIN (ce
    WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ce.ce_dynamic_label_id,request->label_list[idx].
     ce_dynamic_label_id)
     AND ce.ce_dynamic_label_id != 0.0
     AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
     AND  NOT (ce.result_status_cd IN (inerror, inerrornoview, inerrornomut))
     AND parser(draft_clause)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM ce_result_set_link rsl
     WHERE rsl.event_id=ce.event_id
      AND rsl.entry_type_cd=repgroup
      AND rsl.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")))))
  ENDIF
  ORDER BY ce.ce_dynamic_label_id, ce.event_id, sensitivity_reason_cd
  HEAD ce.event_id
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].event_id = ce.event_id, reply->reply_list[cnt].ce_dynamic_label_id = ce
   .ce_dynamic_label_id, reply->reply_list[cnt].event_cd = ce.event_cd,
   reply->reply_list[cnt].event_end_dt_tm = ce.event_end_dt_tm, reply->reply_list[cnt].
   subtable_bit_map2 = subtable_bit_map2
  HEAD sensitivity_reason_cd
   IF (sensitivity_reason_cd > 0)
    seclbl_cnt += 1
    IF (mod(seclbl_cnt,10)=1)
     stat = alterlist(reply->reply_list[cnt].security_label_list,(seclbl_cnt+ 9))
    ENDIF
    reply->reply_list[cnt].security_label_list[seclbl_cnt].sensitivity_reason_cd =
    sensitivity_reason_cd
   ENDIF
  FOOT  ce.event_id
   IF (seclbl_cnt > 0)
    stat = alterlist(reply->reply_list[cnt].security_label_list,seclbl_cnt), seclbl_cnt = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SET stat = alterlist(reply->reply_list,cnt)
 ENDIF
 SET error_code = error(error_msg,0)
 IF (error_code > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.subeventstatus.targetobjectname = "CLINICAL_EVENT"
  SET reply->status_data.subeventstatus.targetobjectvalue = error_msg
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "SELECT"
  SET reply->status_data.subeventstatus.operationstatus = "Z"
  SET reply->status_data.subeventstatus.targetobjectname = "CLINICAL_EVENT"
  SET reply->status_data.subeventstatus.targetobjectvalue = "No Results were retrieved"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
