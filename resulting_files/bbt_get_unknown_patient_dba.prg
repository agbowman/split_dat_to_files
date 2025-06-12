CREATE PROGRAM bbt_get_unknown_patient:dba
 RECORD reply(
   1 unknown_patient_text = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.product_id, p.unknown_patient_text
  FROM patient_dispense p
  WHERE (p.product_id=request->product_id)
   AND p.active_ind=1
   AND p.unknown_patient_ind=1
   AND ((p.person_id < 0) OR (p.person_id=0))
  DETAIL
   reply->unknown_patient_text = p.unknown_patient_text
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt += 1
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "patient dispense"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to find emergency dispense info for product specified"
  SET reply->status_data.status = "Z"
  GO TO end_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
