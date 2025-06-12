CREATE PROGRAM afc_srv_get_charge_mod:dba
 RECORD reply(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = c200
     2 field2 = c200
     2 field3 = c200
     2 field4 = c200
     2 field5 = c200
     2 field6 = c200
     2 field7 = c200
     2 field8 = c200
     2 field9 = c200
     2 field10 = c200
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cm.charge_mod_id, cm.charge_mod_type_cd, cm.field1,
  cm.field2, cm.field3, cm.field4,
  cm.field5, cm.field6, cm.field7,
  cm.field8, cm.field9, cm.field10,
  cm.field1_id, cm.field2_id, cm.field3_id,
  cm.field4_id, cm.field5_id
  FROM charge_mod cm
  WHERE (cm.charge_item_id=request->charge_item_id)
  DETAIL
   CALL echo(build("charge_mod: ",cm.charge_mod_id)), count1 += 1, stat = alterlist(reply->charge_mod,
    count1),
   reply->charge_mod_qual = count1, reply->charge_mod[count1].charge_mod_id = cm.charge_mod_id, reply
   ->charge_mod[count1].charge_mod_type_cd = cm.charge_mod_type_cd,
   reply->charge_mod[count1].field1 = cm.field1, reply->charge_mod[count1].field2 = cm.field2, reply
   ->charge_mod[count1].field3 = cm.field3,
   reply->charge_mod[count1].field4 = cm.field4, reply->charge_mod[count1].field5 = cm.field5, reply
   ->charge_mod[count1].field6 = cm.field6,
   reply->charge_mod[count1].field7 = cm.field7, reply->charge_mod[count1].field8 = cm.field8, reply
   ->charge_mod[count1].field9 = cm.field9,
   reply->charge_mod[count1].field10 = cm.field10, reply->charge_mod[count1].field1_id = cm.field1_id,
   reply->charge_mod[count1].field2_id = cm.field2_id,
   reply->charge_mod[count1].field3_id = cm.field3_id, reply->charge_mod[count1].field4_id = cm
   .field4_id, reply->charge_mod[count1].field5_id = cm.field5_id
  WITH nocounter
 ;end select
 SET reply->charge_mod_qual = count1
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
