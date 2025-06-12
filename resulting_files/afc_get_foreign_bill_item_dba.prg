CREATE PROGRAM afc_get_foreign_bill_item:dba
 RECORD reply(
   1 bill_item_mod_qual = i2
   1 ext_description = vc
   1 bill_item_mod_id = f8
   1 bill_item_id = f8
   1 bill_item_type_cd = f8
   1 key1_id = f8
   1 key2_id = f8
   1 key3_id = f8
   1 key4_id = f8
   1 key5_id = f8
   1 key6 = vc
   1 key7 = vc
   1 key8 = vc
   1 key9 = vc
   1 key10 = vc
   1 key11 = vc
   1 key12 = vc
   1 key13 = vc
   1 key14 = vc
   1 key15 = vc
   1 active_ind = i2
   1 active_status_cd = f8
   1 active_status_dt_tm = dq8
   1 active_status_prsnl_id = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 updt_cnt = i2
   1 ext_parent_reference_id = f8
   1 ext_parent_contributor_cd = f8
   1 ext_child_reference_id = f8
   1 ext_child_contributor_cd = f8
   1 ext_short_desc = vc
   1 ext_owner_cd = f8
   1 ext_owner_disp = c40
   1 ext_owner_desc = c60
   1 ext_owner_mean = c12
   1 parent_qual_cd = f8
   1 careset_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET code_value = 0.0
 SET code_set = 13019
 SET bar_code_value = 0.0
 SET cdf_meaning = "BARCODE"
 EXECUTE cpm_get_cd_for_cdf
 SET bar_code_value = code_value
 SET count1 = 0
 SELECT INTO "nl:"
  b.bill_item_mod_id, bi.ext_description
  FROM bill_item_modifier b,
   bill_item bi
  PLAN (b
   WHERE (b.key6=request->foreign_bill_item_id)
    AND b.bill_item_type_cd=bar_code_value
    AND b.active_ind=1)
   JOIN (bi
   WHERE bi.bill_item_id=b.bill_item_id
    AND bi.active_ind=1)
  DETAIL
   count1 = (count1+ 1), reply->bill_item_mod_id = b.bill_item_mod_id, reply->bill_item_id = b
   .bill_item_id,
   reply->ext_description = bi.ext_description, reply->ext_parent_reference_id = bi
   .ext_parent_reference_id, reply->ext_parent_contributor_cd = bi.ext_parent_contributor_cd,
   reply->ext_child_reference_id = bi.ext_child_reference_id, reply->ext_child_contributor_cd = bi
   .ext_child_contributor_cd, reply->ext_short_desc = bi.ext_short_desc,
   reply->ext_owner_cd = bi.ext_owner_cd, reply->parent_qual_cd = bi.parent_qual_cd, reply->
   careset_ind = bi.careset_ind
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
