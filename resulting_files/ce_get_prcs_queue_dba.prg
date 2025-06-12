CREATE PROGRAM ce_get_prcs_queue:dba
 IF (validate(reply,"-1")="-1")
  RECORD reply(
    1 reply_list[*]
      2 ce_prcs_queue_id = f8
      2 event_id = f8
      2 prsnl_id = f8
      2 encntr_id = f8
      2 order_id = f8
      2 event_cd = f8
    1 error_code = f8
    1 error_msg = vc
  )
 ENDIF
 DECLARE count = i4 WITH noconstant(0)
 DECLARE pending = f8 WITH constant(uar_get_code_by("MEANING",4001983,"PENDING"))
 DECLARE endorse = f8 WITH constant(uar_get_code_by("MEANING",4001982,"ENDORSE"))
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 SET max_date = cnvtdatetime("31-DEC-2100 00:00:00")
 SELECT INTO "nl:"
  FROM ce_prcs_queue cep,
   ce_event_action cea,
   clinical_event ce
  PLAN (cep
   WHERE cep.queue_type_cd=endorse
    AND cep.queue_status_cd=pending)
   JOIN (cea
   WHERE cep.ce_event_action_id=cea.ce_event_action_id)
   JOIN (ce
   WHERE cep.event_id=ce.event_id
    AND ce.valid_until_dt_tm=cnvtdatetime(max_date))
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->reply_list,5))
    stat = alterlist(reply->reply_list,(count+ 5))
   ENDIF
   reply->reply_list[count].ce_prcs_queue_id = cep.ce_prcs_queue_id, reply->reply_list[count].
   event_id = cep.event_id, reply->reply_list[count].prsnl_id = cea.action_prsnl_id,
   reply->reply_list[count].encntr_id = ce.encntr_id, reply->reply_list[count].order_id = ce.order_id,
   reply->reply_list[count].event_cd = ce.event_cd
  FOOT REPORT
   stat = alterlist(reply->reply_list,count)
  WITH nocounter
 ;end select
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
