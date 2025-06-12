CREATE PROGRAM bbt_get_synonym_from_order:dba
 RECORD reply(
   1 synonym_id = f8
   1 catalog_type_cd = f8
   1 catalog_cd = f8
   1 mnemonic = vc
   1 oe_format_id = f8
   1 order_id = f8
   1 updt_cnt = i4
   1 status_data
     2 status = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET syn_id = 0.0
 SET cat_type_cd = 0.0
 SET cat_cd = 0.0
 SET mnemonic = ""
 SET oe_format_id = 0.0
 SET order_id = 0.0
 SET updt_cnt = 0
 SELECT INTO "nl:"
  o.synonym_id
  FROM orders o
  PLAN (o
   WHERE (o.product_id=request->product_id))
  DETAIL
   syn_id = o.synonym_id, cat_type_cd = o.catalog_type_cd, cat_cd = o.catalog_cd,
   mnemonic = o.order_mnemonic, oe_format_id = o.oe_format_id, order_id = o.order_id,
   updt_cnt = o.updt_cnt
  WITH counter
 ;end select
 SET reply->synonym_id = syn_id
 SET reply->catalog_type_cd = cat_type_cd
 SET reply->catalog_cd = cat_cd
 SET reply->mnemonic = mnemonic
 SET reply->oe_format_id = oe_format_id
 SET reply->order_id = order_id
 SET reply->updt_cnt = updt_cnt
 SET reply->status_data.status = "S"
END GO
