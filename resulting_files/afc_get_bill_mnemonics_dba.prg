CREATE PROGRAM afc_get_bill_mnemonics:dba
 RECORD reply(
   1 bill_mnemonic_qual = i2
   1 bill_item_type_cd = f8
   1 bill_mnemonic[10]
     2 bill_item_mod_id = f8
     2 bill_mnem_type_cd = f8
     2 bill_mnem_type_disp = c40
     2 bill_mnem = vc
     2 bill_mnem_long = vc
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
 SET bill_item_type_cdf_mean = "MNEM"
 SET status_code_set = 48
 SET status_cdf_mean = "ACTIVE"
 SET bill_mnem_type_code_set = 13026
 SET active_status_cd = 0.0
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
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=status_code_set
   AND cv.cdf_meaning=status_cdf_mean
  DETAIL
   active_status_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value, b.bill_item_mod_id, b.key1,
  b.key2, b.key3
  FROM dummyt d,
   bill_item_modifier b,
   code_value cv
  PLAN (cv
   WHERE cv.code_set=bill_mnem_type_code_set)
   JOIN (d)
   JOIN (b
   WHERE (b.bill_item_id=request->bill_item_id)
    AND (b.bill_item_type_cd=reply->bill_item_type_cd)
    AND b.active_status_cd=active_status_cd
    AND cv.code_value=cnvtreal(b.key1))
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->bill_mnemonic,(count1+ 10))
   ENDIF
   reply->bill_mnemonic[count1].bill_item_mod_id = b.bill_item_mod_id, reply->bill_mnemonic[count1].
   bill_mnem_type_cd = cv.code_value, reply->bill_mnemonic[count1].bill_mnem = b.key2,
   reply->bill_mnemonic[count1].bill_mnem_long = b.key3
  WITH outerjoin = d, nocounter
 ;end select
 SET stat = alter(reply->bill_mnemonic,count1)
 SET reply->bill_mnemonic_qual = count1
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
