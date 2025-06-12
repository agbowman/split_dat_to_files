CREATE PROGRAM act_get_synonyms_by_cki:dba
 RECORD reply(
   1 synonym[*]
     2 synonym_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 oe_format_id = f8
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
 DECLARE cki_cnt = i4 WITH public, noconstant(0)
 SET cki_cnt = size(request->cki_list,5)
 IF (cki_cnt=1
  AND (request->cki_list[1].cki=""))
  SET cki_cnt = 0
 ENDIF
 IF (cki_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cki_cnt)),
   order_catalog_synonym ocs
  PLAN (d)
   JOIN (ocs
   WHERE (ocs.cki=request->cki_list[d.seq].cki)
    AND ((ocs.active_ind+ 0)=1))
  ORDER BY ocs.catalog_cd
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->synonym,cnt), reply->synonym[cnt].synonym_id = ocs
   .synonym_id,
   reply->synonym[cnt].catalog_cd = ocs.catalog_cd, reply->synonym[cnt].catalog_type_cd = ocs
   .catalog_type_cd, reply->synonym[cnt].activity_type_cd = ocs.activity_type_cd,
   reply->synonym[cnt].oe_format_id = ocs.oe_format_id, reply->synonym[cnt].dcp_clin_cat_cd = ocs
   .dcp_clin_cat_cd, reply->synonym[cnt].mnemonic = ocs.mnemonic,
   reply->synonym[cnt].mnemonic_type_cd = ocs.mnemonic_type_cd
  WITH nocounter
 ;end select
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
