CREATE PROGRAM bbt_get_confirmation_info:dba
 RECORD reply(
   1 qual[*]
     2 product_cd = f8
     2 synonym_id = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 mnemonic = vc
     2 oe_format_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET idx = 0
 SELECT INTO "nl:"
  np.synonym_id
  FROM new_product np,
   (dummyt d_ocs  WITH seq = 1),
   order_catalog_synonym ocs
  PLAN (np
   WHERE (np.option_id=request->option_id)
    AND np.synonym_id != null
    AND np.synonym_id > 0.0)
   JOIN (d_ocs
   WHERE d_ocs.seq=1)
   JOIN (ocs
   WHERE ocs.synonym_id=np.synonym_id)
  DETAIL
   idx = (idx+ 1), stat = alterlist(reply->qual,idx), reply->qual[idx].product_cd = np.new_product_cd,
   reply->qual[idx].synonym_id = ocs.synonym_id, reply->qual[idx].catalog_type_cd = ocs
   .catalog_type_cd, reply->qual[idx].catalog_cd = ocs.catalog_cd,
   reply->qual[idx].mnemonic = ocs.mnemonic, reply->qual[idx].oe_format_id = ocs.oe_format_id
  WITH counter
 ;end select
 SET reply->status_data.status = "S"
END GO
