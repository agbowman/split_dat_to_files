CREATE PROGRAM afc_get_bill_item_mapping:dba
 RECORD reply(
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 ext_description = vc
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 bill_item_type_disp = c40
     2 bill_item_type_desc = c60
     2 bill_item_type_mean = c12
     2 key1_id = f8
     2 key2_id = f8
     2 key3_id = f8
     2 key4_id = f8
     2 key5_id = f8
     2 key6 = vc
     2 key7 = vc
     2 key8 = vc
     2 key9 = vc
     2 key10 = vc
     2 key11 = vc
     2 key12 = vc
     2 key13 = vc
     2 key14 = vc
     2 key15 = vc
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
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
 SELECT INTO "nl:"
  b.*, bi.ext_description
  FROM bill_item_modifier b,
   bill_item bi
  PLAN (b
   WHERE (b.bill_item_type_cd=request->bill_item_type_cd)
    AND b.active_ind=1)
   JOIN (bi
   WHERE bi.bill_item_id=b.bill_item_id
    AND bi.active_ind=1)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->bill_item_modifier,count1), reply->
   bill_item_modifier[count1].bill_item_mod_id = b.bill_item_mod_id,
   reply->bill_item_modifier[count1].bill_item_id = b.bill_item_id, reply->bill_item_modifier[count1]
   .bill_item_type_cd = b.bill_item_type_cd, reply->bill_item_modifier[count1].ext_description = bi
   .ext_description,
   reply->bill_item_modifier[count1].key1_id = b.key1_id, reply->bill_item_modifier[count1].key2_id
    = b.key2_id, reply->bill_item_modifier[count1].key3_id = b.key3_id,
   reply->bill_item_modifier[count1].key4_id = b.key4_id, reply->bill_item_modifier[count1].key5_id
    = b.key5_id, reply->bill_item_modifier[count1].key6 = b.key6,
   reply->bill_item_modifier[count1].key7 = b.key7, reply->bill_item_modifier[count1].key8 = b.key8,
   reply->bill_item_modifier[count1].key9 = b.key9,
   reply->bill_item_modifier[count1].key10 = b.key10, reply->bill_item_modifier[count1].active_ind =
   b.active_ind, reply->bill_item_modifier[count1].active_status_cd = b.active_status_cd,
   reply->bill_item_modifier[count1].active_status_dt_tm = b.active_status_dt_tm, reply->
   bill_item_modifier[count1].active_status_prsnl_id = b.active_status_prsnl_id, reply->
   bill_item_modifier[count1].beg_effective_dt_tm = b.beg_effective_dt_tm,
   reply->bill_item_modifier[count1].end_effective_dt_tm = b.end_effective_dt_tm, reply->
   bill_item_modifier[count1].updt_cnt = b.updt_cnt
  WITH nocounter
 ;end select
 SET reply->bill_item_modifier_qual = count1
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
