CREATE PROGRAM act_get_synonyms_by_catalog:dba
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
 DECLARE mnemonic_cnt = i4 WITH public, noconstant(0)
 DECLARE catalog_cnt = i4 WITH public, noconstant(0)
 DECLARE filter_line = vc WITH public, noconstant(fillstring(1000," "))
 SET mnemonic_cnt = size(request->mnemonics,5)
 IF (mnemonic_cnt=1
  AND (request->mnemonics[1].mnemonic_type_cd=0))
  SET mnemonic_cnt = 0
 ENDIF
 SET catalog_cnt = size(request->catalogs,5)
 IF (catalog_cnt=1
  AND (request->catalogs[1].catalog_cd=0))
  SET catalog_cnt = 0
 ENDIF
 IF (mnemonic_cnt > 0
  AND catalog_cnt > 0)
  FOR (x = 1 TO catalog_cnt)
   IF (x=1)
    SET filter_line = concat(" (ocs.catalog_cd in (",cnvtstring(request->catalogs[1].catalog_cd))
   ELSE
    SET filter_line = concat(trim(filter_line),",",cnvtstring(request->catalogs[x].catalog_cd))
   ENDIF
   IF (x=catalog_cnt)
    SET filter_line = concat(trim(filter_line),") or ocs.mnemonic_type_cd in (")
   ENDIF
  ENDFOR
  FOR (x = 1 TO mnemonic_cnt)
   IF (x=1)
    SET filter_line = concat(trim(filter_line),cnvtstring(request->mnemonics[1].mnemonic_type_cd))
   ELSE
    SET filter_line = concat(trim(filter_line),",",cnvtstring(request->mnemonics[x].mnemonic_type_cd)
     )
   ENDIF
   IF (x=mnemonic_cnt)
    SET filter_line = concat(trim(filter_line),")) and ocs.active_ind+0 = 1")
   ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM order_catalog_synonym ocs
   PLAN (ocs
    WHERE parser(trim(filter_line)))
   ORDER BY ocs.catalog_cd
   HEAD ocs.synonym_id
    cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].synonym_id = ocs.synonym_id,
    reply->qual[cnt].catalog_cd = ocs.catalog_cd, reply->qual[cnt].dcp_clin_cat_cd = ocs
    .dcp_clin_cat_cd, reply->qual[cnt].mnemonic = ocs.mnemonic,
    reply->qual[cnt].mnemonic_type_cd = ocs.mnemonic_type_cd
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (catalog_cnt=0
  AND mnemonic_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT
  IF (mnemonic_cnt > 0)INTO "nl:"
   FROM (dummyt d  WITH seq = value(mnemonic_cnt)),
    order_catalog_synonym ocs
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.mnemonic_type_cd=request->mnemonics[d.seq].mnemonic_type_cd)
     AND ((ocs.active_ind+ 0)=1))
  ELSEIF (catalog_cnt > 0)INTO "nl:"
   FROM (dummyt d  WITH seq = value(catalog_cnt)),
    order_catalog_synonym ocs
   PLAN (d)
    JOIN (ocs
    WHERE (ocs.catalog_cd=request->catalogs[d.seq].catalog_cd)
     AND ((ocs.active_ind+ 0)=1))
  ELSE
  ENDIF
  ORDER BY ocs.catalog_cd
  HEAD ocs.synonym_id
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].synonym_id = ocs.synonym_id,
   reply->qual[cnt].catalog_cd = ocs.catalog_cd, reply->qual[cnt].dcp_clin_cat_cd = ocs
   .dcp_clin_cat_cd, reply->qual[cnt].mnemonic = ocs.mnemonic,
   reply->qual[cnt].mnemonic_type_cd = ocs.mnemonic_type_cd
  WITH nocounter
 ;end select
#exit_script
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
