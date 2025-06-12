CREATE PROGRAM bbt_get_ordered_product_orders:dba
 RECORD reply(
   1 qual[*]
     2 synonym_id = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 mnemonic = vc
     2 oe_format_id = f8
     2 order_id = f8
     2 orig_order_dt_tm = dq8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET ordered_status_code_set = 6004
 SET ordered_status_cdf_meaning = "ORDERED"
 SET ordered_status_cd = 0.0
 SET stat_size = 0
 SET qual_cnt = 0
 SET ordered_status_cd = get_code_value(ordered_status_code_set,ordered_status_cdf_meaning)
 SELECT INTO "nl:"
  o.synonym_id
  FROM orders o
  PLAN (o
   WHERE (o.product_id=request->product_id)
    AND o.order_status_cd=ordered_status_cd)
  HEAD REPORT
   qual_cnt = 0, select_ok_ind = 0, stat = alterlist(reply->qual,10)
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].synonym_id = o.synonym_id, reply->qual[qual_cnt].catalog_type_cd = o
   .catalog_type_cd, reply->qual[qual_cnt].catalog_cd = o.catalog_cd,
   reply->qual[qual_cnt].mnemonic = o.order_mnemonic, reply->qual[qual_cnt].oe_format_id = o
   .oe_format_id, reply->qual[qual_cnt].order_id = o.order_id,
   reply->qual[qual_cnt].orig_order_dt_tm = cnvtdatetime(o.orig_order_dt_tm), reply->qual[qual_cnt].
   updt_cnt = o.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->qual,qual_cnt), select_ok_ind = 1
  WITH nocounter, nullreport
 ;end select
 SET stat_size = size(reply->status_data.subeventstatus,5)
 SET count1 = (stat_size+ 1)
 IF (count1 > 1)
  SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
 ENDIF
 SET reply->status_data.subeventstatus[count1].operationname = "select on order table"
 SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_ordered_product_orders"
 IF (select_ok_ind=1)
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "No rows for on order table for product_id"
   GO TO exit_script
  ELSE
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "ERROR IN SCRIPT:  Select on order table failed"
 ENDIF
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
#exit_script
END GO
