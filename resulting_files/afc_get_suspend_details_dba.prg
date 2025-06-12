CREATE PROGRAM afc_get_suspend_details:dba
 IF ("Z"=validate(afc_get_suspend_details_vrsn,"Z"))
  DECLARE afc_get_suspend_details_vrsn = vc WITH noconstant("265113.003")
 ENDIF
 RECORD reply(
   1 charge_mod_qual = i2
   1 charge_mod_type_cd = f8
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 bill_code_type_cd = f8
     2 bill_code_type_disp = c40
     2 field1 = f8
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field1_id = f8
     2 field6 = vc
     2 field7 = vc
     2 field2_id = f8
     2 field3_id = f8
     2 nomen_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE bill_code_values = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,bill_code_values)
 SET count1 = 0
 SELECT INTO "nl:"
  cm.charge_mod_id, cm.charge_item_id, cm.field1,
  cm.field2, cm.field3, cm.field4
  FROM charge_mod cm
  WHERE (cm.charge_item_id=request->charge_item_id)
   AND cm.active_ind=1
   AND cm.charge_mod_type_cd=bill_code_values
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->charge_mod,count1), reply->charge_mod_type_cd = cm
   .charge_mod_type_cd,
   reply->charge_mod[count1].charge_mod_id = cm.charge_mod_id, reply->charge_mod[count1].
   bill_code_type_cd = cm.field1_id, reply->charge_mod[count1].field1 = cnvtreal(trim(cm.field1,3)),
   reply->charge_mod[count1].field1_id = cm.field1_id, reply->charge_mod[count1].field2 = cm.field2,
   reply->charge_mod[count1].field6 = cm.field6,
   reply->charge_mod[count1].field3 = cm.field3, reply->charge_mod[count1].field7 = cm.field7, reply
   ->charge_mod[count1].field4 = cm.field4,
   reply->charge_mod[count1].field2_id = cm.field2_id, reply->charge_mod[count1].field3_id = cm
   .field3_id, reply->charge_mod[count1].nomen_id = cm.nomen_id
  WITH nocounter
 ;end select
 SET reply->charge_mod_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CHARGE_MOD"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
