CREATE PROGRAM act_get_synonyms_by_id:dba
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
 DECLARE synonym_cnt = i4 WITH public, noconstant(0)
 SET synonym_cnt = size(request->synonyms,5)
 IF (synonym_cnt=1
  AND (request->synonyms[1].synonym_id=0))
  SET synonym_cnt = 0
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(synonym_cnt)),
   order_catalog_synonym ocs
  PLAN (d)
   JOIN (ocs
   WHERE (ocs.synonym_id=request->synonyms[d.seq].synonym_id)
    AND ((ocs.active_ind+ 0)=1))
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
