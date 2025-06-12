CREATE PROGRAM afc_get_bill_codes:dba
 RECORD reply(
   1 bill_code_qual = i2
   1 bill_item_type_cd = f8
   1 bill_codes[*]
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_code_type_cd = f8
     2 bill_code_type_disp = c40
     2 bill_code_type_desc = c60
     2 bill_code_type_mean = c12
     2 bill_code = vc
     2 priority = f8
     2 description = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
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
   reply->bill_item_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  b.bill_item_mod_id, b.bill_item_id, b.bill_item_type_cd,
  b.key1_id, b.key6, b.key2_id,
  b.key7
  FROM bill_item_modifier b
  WHERE (b.bill_item_id=request->bill_item_id)
   AND b.active_ind=1
   AND (b.bill_item_type_cd=reply->bill_item_type_cd)
  HEAD REPORT
   stat = alterlist(reply->bill_codes,10)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->bill_codes,(count1+ 10))
   ENDIF
   reply->bill_codes[count1].bill_item_mod_id = b.bill_item_mod_id, reply->bill_codes[count1].
   bill_item_id = b.bill_item_id, reply->bill_codes[count1].bill_code_type_cd = b.key1_id,
   reply->bill_codes[count1].bill_code = b.key6, reply->bill_codes[count1].priority = b.key2_id,
   reply->bill_codes[count1].description = b.key7,
   reply->bill_codes[count1].beg_effective_dt_tm = b.beg_effective_dt_tm, reply->bill_codes[count1].
   end_effective_dt_tm = b.end_effective_dt_tm
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->bill_codes,count1)
 SET reply->bill_code_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM_MODIFIER"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
