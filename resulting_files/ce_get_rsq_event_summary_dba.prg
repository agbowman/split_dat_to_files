CREATE PROGRAM ce_get_rsq_event_summary:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE (ce.person_id=request->person_id)
   AND ce.event_end_dt_tm >= cnvtdatetimeutc(request->min_date)
   AND ce.event_end_dt_tm <= cnvtdatetimeutc(request->max_date)
   AND ce.valid_until_dt_tm=cnvtdatetimeutc("31-dec-2100")
   AND ce.view_level > 0
   AND ce.publish_flag != 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->reply_list,(cnt+ 9))
   ENDIF
   reply->reply_list[cnt].event_id = ce.event_id, reply->reply_list[cnt].event_cd = ce.event_cd,
   reply->reply_list[cnt].normalcy_cd = ce.normalcy_cd,
   reply->reply_list[cnt].result_status_cd = ce.result_status_cd
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
 SET stat = alterlist(reply->reply_list,cnt)
END GO
