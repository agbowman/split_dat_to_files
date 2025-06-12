CREATE PROGRAM act_get_orderable:dba
 RECORD reply(
   1 qual[*]
     2 synonym_id = f8
     2 catalog_cd = f8
     2 dcp_clin_cat_cd = f8
     2 mnemonic = vc
     2 mnemonic_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE type_cnt = i4 WITH public, noconstant(0)
 DECLARE ord_string = vc WITH public, noconstant(fillstring(500," "))
 DECLARE virtual_view_string = vc WITH public, noconstant(fillstring(200," "))
 SET type_cnt = size(request->types,5)
 IF (type_cnt=1
  AND (request->types[1].mnemonic_type_cd=0))
  SET type_cnt = 0
 ENDIF
 SET ord_string = cnvtupper(request->ord_string)
 SET ord_string = concat(trim(ord_string),"*")
 IF ((request->virtual_view > " "))
  SET virtual_view_string = concat('trim(ocs.virtual_view) = "',request->virtual_view,'"')
 ELSE
  SET virtual_view_string = "0 = 0"
 ENDIF
 SELECT
  IF (type_cnt > 0)INTO "nl:"
   FROM (dummyt d  WITH seq = value(type_cnt)),
    order_catalog_synonym ocs
   PLAN (d)
    JOIN (ocs
    WHERE ocs.mnemonic_key_cap=patstring(ord_string)
     AND (ocs.mnemonic_type_cd=request->types[d.seq].mnemonic_type_cd)
     AND parser(trim(virtual_view_string))
     AND ((ocs.active_ind+ 0)=1))
  ELSE INTO "nl:"
   FROM order_catalog_synonym ocs
   PLAN (ocs
    WHERE ocs.mnemonic_key_cap=patstring(ord_string)
     AND parser(trim(virtual_view_string))
     AND ((ocs.active_ind+ 0)=1))
  ENDIF
  ORDER BY ocs.catalog_cd
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].synonym_id = ocs.synonym_id,
   reply->qual[cnt].catalog_cd = ocs.catalog_cd, reply->qual[cnt].dcp_clin_cat_cd = ocs
   .dcp_clin_cat_cd, reply->qual[cnt].mnemonic = ocs.mnemonic,
   reply->qual[cnt].mnemonic_type_cd = ocs.mnemonic_type_cd
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
