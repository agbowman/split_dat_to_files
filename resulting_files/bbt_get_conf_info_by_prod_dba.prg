CREATE PROGRAM bbt_get_conf_info_by_prod:dba
 RECORD reply(
   1 synonym_id = f8
   1 catalog_type_cd = f8
   1 catalog_cd = f8
   1 mnemonic = vc
   1 oe_format_id = f8
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
 SELECT INTO "nl:"
  p.synonym_id
  FROM product_index p,
   (dummyt d_ocs  WITH seq = 1),
   order_catalog_synonym ocs
  PLAN (p
   WHERE (p.product_cd=request->product_cd)
    AND p.synonym_id != null
    AND p.synonym_id > 0.0)
   JOIN (d_ocs
   WHERE d_ocs.seq=1)
   JOIN (ocs
   WHERE ocs.synonym_id=p.synonym_id)
  DETAIL
   syn_id = ocs.synonym_id, cat_type_cd = ocs.catalog_type_cd, cat_cd = ocs.catalog_cd,
   mnemonic = ocs.mnemonic, oe_format_id = ocs.oe_format_id
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->synonym_id = syn_id
  SET reply->catalog_type_cd = cat_type_cd
  SET reply->catalog_cd = cat_cd
  SET reply->mnemonic = mnemonic
  SET reply->oe_format_id = oe_format_id
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
