CREATE PROGRAM co_get_chi_none_from_form_act:dba
 RECORD reply(
   1 chronic_health_none_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa
  WHERE (dfa.person_id=request->person_id)
   AND dfa.form_dt_tm >= cnvtdatetime(request->beg_dt_tm)
   AND dfa.form_dt_tm < cnvtdatetime(request->end_dt_tm)
   AND dfa.flags=2
   AND cnvtupper(dfa.description) IN (cnvtupper("Adult Patient History ICU"), cnvtupper(
   "ICU Transfer Patient History"))
   AND ((dfa.encntr_id+ 0)=request->encntr_id)
   AND dfa.active_ind=1
  DETAIL
   reply->chronic_health_none_ind = 1
  WITH nocounter
 ;end select
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Success"
 SET reply->status_data.subeventstatus[1].operationname = "co_get_chi_none_from_form_act"
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
