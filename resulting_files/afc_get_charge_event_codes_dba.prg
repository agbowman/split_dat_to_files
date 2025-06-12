CREATE PROGRAM afc_get_charge_event_codes:dba
 RECORD reply(
   1 charge_event_mod_qual = i2
   1 charge_event_mod_type_cd = f8
   1 charge_event_mod[10]
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field1_id = f8
     2 field6 = vc
     2 field2_id = f8
     2 field7 = f8
     2 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET bill_item_type_code_set = 13019
 SET bill_item_type_cdf_mean = "BILL CODE"
 SET status_code_set = 48
 SET status_cdf_mean = "ACTIVE"
 SET bill_code_type_code_set = 14002
 SET bill_item_type_cd = 0
 SET active_status_cd = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=bill_item_type_code_set
   AND cv.cdf_meaning=bill_item_type_cdf_mean
  DETAIL
   reply->charge_event_mod_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.charge_event_mod_id, c.charge_event_id, c.field1,
  c.field2, c.field3, c.field4,
  c.field1_id, c.field6, c.field2_id,
  c.field7, cd.cdf_meaning, cd.code_value
  FROM charge_event_mod c,
   code_value cd
  WHERE (c.charge_event_mod_type_cd=reply->charge_event_mod_type_cd)
   AND (c.charge_event_id=request->charge_event_id)
   AND cd.code_set=bill_code_type_code_set
   AND cnvtreal(c.field1)=cd.code_value
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->charge_event_mod,(count1+ 10))
   ENDIF
   reply->charge_event_mod[count1].field1 = c.field1, reply->charge_event_mod[count1].field2 = c
   .field2, reply->charge_event_mod[count1].field3 = c.field3,
   reply->charge_event_mod[count1].field4 = c.field4, reply->charge_event_mod[count1].field1_id = c
   .field1_id, reply->charge_event_mod[count1].field6 = c.field6,
   reply->charge_event_mod[count1].field2_id = c.field2_id, reply->charge_event_mod[count1].field7 =
   c.field7, reply->charge_event_mod[count1].meaning = cd.cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alter(reply->charge_event_mod,count1)
 SET reply->charge_event_mod_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CHARGE_EVENT_MOD"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
