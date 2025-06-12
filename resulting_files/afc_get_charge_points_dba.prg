CREATE PROGRAM afc_get_charge_points:dba
 RECORD reply(
   1 mod_qual = i4
   1 billitemtypecd = f8
   1 qual[*]
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 bill_item_type_disp = c40
     2 bill_item_type_desc = c60
     2 bill_item_type_mean = c12
     2 sched = f8
     2 charge_point = f8
     2 manual = f8
     2 charge_level = f8
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
 SET stat = alterlist(reply->qual,10)
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SET charge_point_schedule = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=13019
   AND cv.cdf_meaning="CHARGE POINT"
   AND cv.active_ind=1
  DETAIL
   charge_point_schedule = cv.code_value
  WITH nocounter
 ;end select
 SET reply->billitemtypecd = charge_point_schedule
 SELECT INTO "nl:"
  b.*
  FROM bill_item_modifier b
  WHERE (b.bill_item_id=request->bill_item_id)
   AND b.bill_item_type_cd=charge_point_schedule
   AND b.active_ind=1
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].bill_item_mod_id = b.bill_item_mod_id, reply->qual[count1].bill_item_id = b
   .bill_item_id, reply->qual[count1].bill_item_type_cd = b.bill_item_type_cd,
   reply->qual[count1].sched = b.key1_id, reply->qual[count1].charge_point = b.key2_id, reply->qual[
   count1].manual = b.key3_id,
   reply->qual[count1].charge_level = b.key4_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count1)
 SET reply->mod_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ORG"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
