CREATE PROGRAM ce_get_result_set:dba
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
 DECLARE event_class_placeholder = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(53,"PLACEHOLDER",1,event_class_placeholder)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 DECLARE entrytypecd = vc WITH public, noconstant("0=0")
 IF ((request->entry_type_cd > 0))
  SET entrytypecd = " rsl.entry_type_cd = request->entry_type_cd "
 ENDIF
 SELECT INTO "nl:"
  ce.event_id, ce.person_id, ce.event_cd,
  ce.event_end_dt_tm, ce.entry_mode_cd
  FROM ce_result_set_link rsl,
   clinical_event ce
  PLAN (rsl
   WHERE (rsl.result_set_id=request->result_set_id)
    AND rsl.valid_until_dt_tm >= cnvtdatetimeutc("31-DEC-2100")
    AND parser(entrytypecd))
   JOIN (ce
   WHERE ce.event_id=rsl.event_id
    AND ce.valid_until_dt_tm >= cnvtdatetimeutc("31-DEC-2100")
    AND  NOT (ce.result_status_cd IN (result_status_inerror, result_status_inerrnoview,
   result_status_inerrnomut))
    AND ce.event_class_cd != event_class_placeholder
    AND  NOT (ce.record_status_cd IN (record_status_deleted, record_status_draft))
    AND ce.valid_until_dt_tm >= cnvtdatetimeutc("31-DEC-2100"))
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].event_id = ce.event_id, reply->reply_list[cnt].person_id = ce.person_id,
   reply->reply_list[cnt].event_cd = ce.event_cd,
   reply->reply_list[cnt].event_end_dt_tm = ce.event_end_dt_tm, reply->reply_list[cnt].entry_mode_cd
    = ce.entry_mode_cd
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
