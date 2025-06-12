CREATE PROGRAM afc_get_bill_code_history:dba
 RECORD reply(
   1 bill_item_mod_qual = i2
   1 bill_item_modifier[*]
     2 bill_item_mod_id = f8
     2 key1_id = f8
     2 key6 = vc
     2 key7 = vc
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
 SET count1 = 0
 SET stat = alterlist(reply->bill_item_modifier,count1)
 DECLARE bill_code = f8
 DECLARE cdf_meaning = c12
 DECLARE code_set = i4
 SET cdf_meaning = "BILL CODE"
 SET code_set = 13019
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,bill_code)
 CALL echo(build("BILL_CODE: ",bill_code))
 SELECT INTO "nl:"
  FROM bill_item_modifier b
  WHERE (b.bill_item_id=request->bill_item_id)
   AND b.bill_item_type_cd=bill_code
   AND b.active_ind=1
  ORDER BY b.key1_id, b.beg_effective_dt_tm
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->bill_item_modifier,count1), reply->
   bill_item_modifier[count1].bill_item_mod_id = b.bill_item_mod_id,
   reply->bill_item_modifier[count1].key1_id = b.key1_id, reply->bill_item_modifier[count1].key6 = b
   .key6, reply->bill_item_modifier[count1].key7 = b.key7,
   reply->bill_item_modifier[count1].beg_effective_dt_tm = cnvtdatetime(b.beg_effective_dt_tm), reply
   ->bill_item_modifier[count1].end_effective_dt_tm = cnvtdatetime(b.end_effective_dt_tm),
   CALL echo(build("Key6 ",b.key6))
  WITH nocounter
 ;end select
 SET reply->bill_item_mod_qual = count1
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
